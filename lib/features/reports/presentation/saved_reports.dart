import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// One report a committee or a council asks for.
class SavedReport {
  const SavedReport({
    required this.title,
    required this.body,
    required this.icon,
    required this.tone,
  });

  /// What the report is called.
  final String title;

  /// What it contains.
  final String body;

  /// The tile's glyph.
  final AppIconSpec icon;

  /// The tile's tone.
  final AppStatusTone tone;
}

/// The reports that can be exported as CSV, in the order the page lists
/// them.
///
/// Fixed, not derived from data: these are the six shapes a report can take,
/// not six rows of a table. [ReportsExportKind] is what a tap on one of them
/// tells `ReportsPage` to export.
enum ReportsExportKind {
  circulation,
  collection,
  members,
  fines,
  overdue,
  acquisitions,
}

List<SavedReport> reportsSaved(AppLocalizations l10n) => [
  SavedReport(
    title: l10n.reportsSavedCirculation,
    body: l10n.reportsSavedCirculationBody,
    icon: AppIcons.transfer,
    tone: AppStatusTone.brand,
  ),
  SavedReport(
    title: l10n.reportsSavedCollection,
    body: l10n.reportsSavedCollectionBody,
    icon: AppIcons.inventory,
    tone: AppStatusTone.info,
  ),
  SavedReport(
    title: l10n.reportsSavedMembers,
    body: l10n.reportsSavedMembersBody,
    icon: AppIcons.people,
    tone: AppStatusTone.success,
  ),
  SavedReport(
    title: l10n.reportsSavedFines,
    body: l10n.reportsSavedFinesBody,
    icon: AppIcons.wallet,
    tone: AppStatusTone.warning,
  ),
  SavedReport(
    title: l10n.reportsSavedOverdue,
    body: l10n.reportsSavedOverdueBody,
    icon: AppIcons.error,
    tone: AppStatusTone.danger,
  ),
  SavedReport(
    title: l10n.reportsSavedAcquisitions,
    body: l10n.reportsSavedAcquisitionsBody,
    icon: AppIcons.delivery,
    tone: AppStatusTone.neutral,
  ),
];

/// [ReportsExportKind] in the same order [reportsSaved] lists them, so a
/// tile's index maps directly to what it exports.
const List<ReportsExportKind> reportsExportKinds = [
  ReportsExportKind.circulation,
  ReportsExportKind.collection,
  ReportsExportKind.members,
  ReportsExportKind.fines,
  ReportsExportKind.overdue,
  ReportsExportKind.acquisitions,
];
