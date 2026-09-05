import 'package:khulla/features/catalog/title/domain/models/title_format.dart';
import 'package:khulla/features/members/domain/models/member_type.dart';

/// Seeds and reads reference rows shared across features.
abstract interface class ReferenceDataRepository {
  /// Inserts default formats, member types and loan rules when absent.
  Future<void> ensureDefaults({
    required String Function(String code) formatName,
    required String Function(String code) memberTypeName,
  });

  Future<List<TitleFormat>> findActiveFormats();

  Future<List<MemberType>> findActiveMemberTypes();
}
