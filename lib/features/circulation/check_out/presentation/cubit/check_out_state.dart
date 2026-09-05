import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:khulla/core/error/app_exception.dart';
import 'package:khulla/features/catalog/copy/domain/models/copy.dart';
import 'package:khulla/features/circulation/shared/domain/models/effective_loan_rules.dart';
import 'package:khulla/features/members/domain/models/member.dart';

part 'check_out_state.freezed.dart';

@freezed
abstract class CheckOutState with _$CheckOutState {
  const factory CheckOutState({
    Member? member,
    EffectiveLoanRules? rules,
    @Default(<Copy>[]) List<Copy> basket,
    @Default(false) bool isSubmitting,
    @Default(false) bool isLookingUpMember,
    AppException? error,
  }) = _CheckOutState;

  const CheckOutState._();

  bool get canConfirm => member != null && basket.isNotEmpty && !isSubmitting;

  int get borrowingLimit => rules?.borrowingLimit ?? 0;

  int get loanPeriodDays => rules?.loanPeriodDays ?? 0;

  int get copiesAfterCheckout => (member?.loansOut ?? 0) + basket.length;

  bool get isOverBorrowingLimit =>
      rules != null && copiesAfterCheckout > rules!.borrowingLimit;
}
