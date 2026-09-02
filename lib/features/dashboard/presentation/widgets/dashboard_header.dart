import 'package:go_router/go_router.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/users/presentation/placeholder/users_placeholder.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The dashboard's greeting, its period switch and its one primary action.
///
/// The greeting is not decoration: on a shared desk machine it is the second
/// place — after the account chip — that says who the till is open as. The
/// period switch governs every figure on the board below, so it belongs
/// here rather than repeated on each card.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    required this.period,
    required this.onPeriodChanged,
    super.key,
  });

  /// Which period the board's figures cover.
  final DashboardPeriod period;

  /// Called when the operator picks another period.
  final ValueChanged<DashboardPeriod> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final stacked = context.formFactor.isCompact;
    final firstName = signedInStaff.name.split(' ').first;

    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.dashboardGreeting(firstName),
          style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.8,
            color: colors.textHigh,
          ),
        ),
        SizedBox(height: spacing.xxs),
        Text(
          l10n.dashboardSubtitle,
          style: context.textTheme.bodyMedium?.copyWith(
            color: colors.textMuted,
            height: 1.4,
          ),
        ),
      ],
    );

    final controls = [
      AppSegmentedControl<DashboardPeriod>(
        value: period,
        items: DashboardPeriod.values,
        itemLabel: (item) => switch (item) {
          DashboardPeriod.today => l10n.commonToday,
          DashboardPeriod.week => l10n.commonThisWeek,
          DashboardPeriod.month => l10n.commonThisMonth,
        },
        onChanged: onPeriodChanged,
      ),
      AppButton(
        size: AppButtonSize.medium,
        icon: Icons.qr_code_scanner_rounded,
        onPressed: () => context.go(Routes.circulationCheckOut),
        child: Text(l10n.dashboardCheckOut),
      ),
    ];

    if (stacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          title,
          SizedBox(height: spacing.md),
          controls.first,
          SizedBox(height: spacing.xs),
          controls.last,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: title),
        SizedBox(width: spacing.lg),
        Padding(
          padding: EdgeInsets.only(top: spacing.xxs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              controls.first,
              SizedBox(width: spacing.xs),
              controls.last,
            ],
          ),
        ),
      ],
    );
  }
}

/// The window of time the board's figures cover.
enum DashboardPeriod { today, week, month }
