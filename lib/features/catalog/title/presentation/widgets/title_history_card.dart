import 'package:khulla/features/catalog/title/presentation/placeholder/title_history_entry.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/components/section_card.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Who has borrowed this work, most recent first.
class TitleHistoryCard extends StatelessWidget {
  const TitleHistoryCard({required this.entries, super.key});

  final List<TitleHistoryEntry> entries;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = context.colorScheme;

    return SectionCard(
      title: l10n.titleDetailHistoryTitle,
      subtitle: l10n.titleDetailHistorySubtitle,
      icon: Icons.history_rounded,
      child: entries.isEmpty
          ? AppEmptyView(
              variant: AppFeedbackVariant.inline,
              title: l10n.titleDetailHistoryEmptyTitle,
              message: l10n.titleDetailHistoryEmptyBody,
            )
          : AppTable<TitleHistoryEntry>(
              items: entries,
              columns: [
                AppTableColumn<TitleHistoryEntry>(
                  id: 'member',
                  label: l10n.loansColumnMember,
                  flex: 3,
                  cellBuilder: (context, entry) => Text(entry.member),
                ),
                AppTableColumn<TitleHistoryEntry>(
                  id: 'barcode',
                  label: l10n.loansColumnBarcode,
                  flex: 2,
                  showFrom: FormFactor.expanded,
                  cellBuilder: (context, entry) => Text(
                    entry.barcode,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                AppTableColumn<TitleHistoryEntry>(
                  id: 'borrowed',
                  label: l10n.loansColumnIssued,
                  flex: 2,
                  showFrom: FormFactor.medium,
                  cellBuilder: (context, entry) => Text(entry.borrowed),
                ),
                AppTableColumn<TitleHistoryEntry>(
                  id: 'status',
                  label: l10n.commonStatus,
                  width: 130,
                  alignment: Alignment.centerRight,
                  cellBuilder: (context, entry) => AppStatusBadge(
                    dense: true,
                    label: entry.returned == null
                        ? l10n.statusOnLoan
                        : l10n.statusReturned,
                    tone: entry.returned == null
                        ? AppStatusTone.brand
                        : (entry.wasLate
                              ? AppStatusTone.warning
                              : AppStatusTone.success),
                  ),
                ),
              ],
            ),
    );
  }
}
