import 'package:khulla/features/catalog/title/domain/models/title_format.dart';
import 'package:khulla/features/members/domain/models/member_type.dart';

/// Seeds and reads reference rows shared across catalogue, members and settings.
///
/// One contract for rows that several features need but none owns alone:
/// formats, member types, and the default loan-rules row at first run.
abstract interface class ReferenceDataRepository {
  /// Inserts default formats, member types and loan rules when absent.
  ///
  /// Called once from bootstrap; [formatName] and [memberTypeName] supply
  /// localized labels for the seeded system codes.
  Future<void> ensureDefaults({
    required String Function(String code) formatName,
    required String Function(String code) memberTypeName,
  });

  /// Active title formats in display order.
  Future<List<TitleFormat>> findActiveFormats();

  /// Active member types in display order.
  Future<List<MemberType>> findActiveMemberTypes();
}
