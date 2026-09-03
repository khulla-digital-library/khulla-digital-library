import 'package:khulla/features/reports/presentation/placeholder/reports_placeholder.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/components/section_card.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Fines raised, collected and waived over the period.
///
/// Three bars on one scale rather than three tiles: what a council asks is
/// what proportion of what was charged actually came in, and that is a
/// comparison, not three separate figures.
class ReportsFinesCard extends StatelessWidget {
  const ReportsFinesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final totals = reportsFineTotals(l10n);

    return SectionCard(
      title: l10n.reportsFinesTitle,
      subtitle: l10n.reportsFinesSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (index, total) in totals.indexed) ...[
            if (index > 0) SizedBox(height: spacing.md),
            AppProgressBar(
              value: total.share,
              label: total.label,
              valueLabel: total.amount.display(),
              tone: total.tone,
            ),
          ],
        ],
      ),
    );
  }
}
