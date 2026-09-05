import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:khulla/core/error/app_exception.dart';
import 'package:khulla/core/format/app_date_format.dart';
import 'package:khulla/features/catalog/copy/domain/copy_repository.dart';
import 'package:khulla/features/catalog/copy/domain/models/copy.dart';
import 'package:khulla/features/circulation/check_out/presentation/cubit/check_out_state.dart';
import 'package:khulla/features/circulation/shared/domain/circulation_fine.dart';
import 'package:khulla/features/circulation/shared/domain/circulation_repository.dart';
import 'package:khulla/features/circulation/shared/domain/models/effective_loan_rules.dart';
import 'package:khulla/features/circulation/shared/domain/resolve_loan_rules.dart';
import 'package:khulla/features/members/data/member_type_local_data_source.dart';
import 'package:khulla/features/members/domain/member_repository.dart';
import 'package:khulla/features/members/domain/models/member_query.dart';
import 'package:khulla/features/settings/domain/loan_rules_repository.dart';

@injectable
class CheckOutCubit extends Cubit<CheckOutState> {
  CheckOutCubit(
    this._circulationRepository,
    this._copyRepository,
    this._memberRepository,
    this._loanRulesRepository,
    this._memberTypes,
  ) : super(const CheckOutState());

  final CirculationRepository _circulationRepository;
  final CopyRepository _copyRepository;
  final MemberRepository _memberRepository;
  final LoanRulesRepository _loanRulesRepository;
  final MemberTypeLocalDataSource _memberTypes;

  Timer? _memberLookupTimer;

  String dueDateLabel() {
    final rules = state.rules;
    if (rules == null) return '';
    final dueAt = addCalendarDays(
      dateOnly(DateTime.now()),
      rules.loanPeriodDays,
    );
    return AppDateFormat.format(dueAt);
  }

  void memberSearchChanged(String value) {
    _memberLookupTimer?.cancel();
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      emit(state.copyWith(member: null, rules: null, error: null));
      return;
    }
    _memberLookupTimer = Timer(const Duration(milliseconds: 300), () {
      unawaited(lookupMember(trimmed));
    });
  }

  Future<void> lookupMember(String query) async {
    emit(state.copyWith(isLookingUpMember: true, error: null));
    try {
      final trimmed = query.trim();
      var member = await _memberRepository.findMemberByCardNumber(trimmed);
      if (member == null) {
        final results = await _memberRepository.findMembers(
          MemberQuery(search: trimmed, limit: 2),
        );
        if (results.items.length == 1) {
          member = results.items.first;
        }
      }
      if (isClosed) return;
      if (member == null) {
        emit(
          state.copyWith(
            member: null,
            rules: null,
            isLookingUpMember: false,
            error: const NotFoundException('That member was not found.'),
          ),
        );
        return;
      }
      final rules = await _loadEffectiveRules(member.memberTypeId);
      if (isClosed) return;
      emit(
        state.copyWith(
          member: member,
          rules: rules,
          isLookingUpMember: false,
          error: null,
        ),
      );
    } on AppException catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          member: null,
          rules: null,
          isLookingUpMember: false,
          error: error,
        ),
      );
    }
  }

  void clearMember() {
    _memberLookupTimer?.cancel();
    emit(
      state.copyWith(
        member: null,
        rules: null,
        basket: const [],
        error: null,
      ),
    );
  }

  Future<void> addCopyByBarcode(String barcode) async {
    final trimmed = barcode.trim();
    if (trimmed.isEmpty) return;

    try {
      final copy = await _copyRepository.findCopyByBarcode(trimmed);
      if (isClosed) return;
      if (copy == null) {
        throw const NotFoundException('No copy matches that barcode.');
      }
      if (state.basket.any((item) => item.id == copy.id)) {
        throw const ConflictException('That copy is already in the basket.');
      }
      emit(state.copyWith(basket: [...state.basket, copy], error: null));
    } on AppException catch (error) {
      if (isClosed) return;
      emit(state.copyWith(error: error));
      rethrow;
    }
  }

  void removeCopy(Copy copy) {
    emit(
      state.copyWith(
        basket: state.basket.where((item) => item.id != copy.id).toList(),
        error: null,
      ),
    );
  }

  Future<void> checkOutCopies() async {
    final member = state.member;
    if (member == null || state.basket.isEmpty) return;

    emit(state.copyWith(isSubmitting: true, error: null));
    try {
      for (final copy in state.basket) {
        await _circulationRepository.checkOutCopy(
          memberId: member.id,
          barcode: copy.barcode,
        );
        if (isClosed) return;
      }
      emit(const CheckOutState());
    } on AppException catch (error) {
      if (isClosed) return;
      emit(state.copyWith(isSubmitting: false, error: error));
      rethrow;
    }
  }

  Future<EffectiveLoanRules> _loadEffectiveRules(String memberTypeId) async {
    final defaults = await _loanRulesRepository.findRules();
    if (defaults == null) {
      throw const NotFoundException('Loan rules have not been configured.');
    }
    final memberType = await _memberTypes.findMemberTypeById(memberTypeId);
    if (memberType == null) {
      throw const NotFoundException('That member type was not found.');
    }
    return resolveLoanRules(defaults, memberType);
  }

  @override
  Future<void> close() {
    _memberLookupTimer?.cancel();
    return super.close();
  }
}
