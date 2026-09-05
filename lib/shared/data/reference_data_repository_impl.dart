import 'package:injectable/injectable.dart';
import 'package:khulla/features/catalog/title/data/title_format_local_data_source.dart';
import 'package:khulla/features/catalog/title/domain/models/title_format.dart';
import 'package:khulla/features/members/data/member_type_local_data_source.dart';
import 'package:khulla/features/members/domain/models/member_type.dart';
import 'package:khulla/features/settings/data/loan_rules_local_data_source.dart';
import 'package:khulla/features/settings/data/loan_rules_repository_impl.dart';
import 'package:khulla/shared/domain/reference_data_repository.dart';
import 'package:uuid/uuid.dart';

@LazySingleton(as: ReferenceDataRepository)
class ReferenceDataRepositoryImpl implements ReferenceDataRepository {
  ReferenceDataRepositoryImpl(
    this._formats,
    this._memberTypes,
    this._loanRules,
  );

  final TitleFormatLocalDataSource _formats;
  final MemberTypeLocalDataSource _memberTypes;
  final LoanRulesLocalDataSource _loanRules;

  static const Uuid _uuid = Uuid();

  static const _formatCodes = [
    'book',
    'journal',
    'magazine',
    'audiobook',
    'video',
    'ebook',
    'other',
  ];

  static const _memberTypeCodes = [
    'student',
    'teacher',
    'public',
    'child',
    'other',
  ];

  @override
  Future<void> ensureDefaults({
    required String Function(String code) formatName,
    required String Function(String code) memberTypeName,
  }) async {
    final now = DateTime.now();

    if (await _formats.countFormats() == 0) {
      for (var i = 0; i < _formatCodes.length; i++) {
        final code = _formatCodes[i];
        await _formats.insertFormat(
          TitleFormat(
            id: _uuid.v4(),
            code: code,
            name: formatName(code),
            sortOrder: i,
            isSystem: true,
            createdAt: now,
          ),
        );
      }
    }

    if (await _memberTypes.countMemberTypes() == 0) {
      for (var i = 0; i < _memberTypeCodes.length; i++) {
        final code = _memberTypeCodes[i];
        await _memberTypes.insertMemberType(
          MemberType(
            id: _uuid.v4(),
            code: code,
            name: memberTypeName(code),
            sortOrder: i,
            isSystem: true,
            createdAt: now,
          ),
        );
      }
    }

    if (await _loanRules.findRules() == null) {
      await _loanRules.saveRules(
        LoanRulesRepositoryImpl.defaults(updatedAt: now),
      );
    }
  }

  @override
  Future<List<TitleFormat>> findActiveFormats() => _formats.findActiveFormats();

  @override
  Future<List<MemberType>> findActiveMemberTypes() =>
      _memberTypes.findActiveMemberTypes();
}
