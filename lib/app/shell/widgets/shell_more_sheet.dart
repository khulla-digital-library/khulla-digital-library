import 'package:go_router/go_router.dart';
import 'package:khulla/app/shell/widgets/shell_destinations.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Opens the sheet listing every section, for a window too narrow to show
/// them all in the bottom bar.
///
/// A bottom bar holds four destinations before the labels start eating each
/// other; this app has eight. Rather than dropping the four that did not fit,
/// the bar keeps the daily ones and this sheet carries the whole list —
/// including the sub-sections, which the bar could never have shown at all.
Future<void> showShellMoreSheet(
  BuildContext context, {
  required List<ShellDestination> destinations,
  required String current,
}) => AppBottomSheet.show<void>(
  context: context,
  title: context.l10n.shellMoreTitle,
  heightFactor: AppBottomSheet.defaultHeightFactor,
  builder: (sheetContext) => _MoreList(
    destinations: destinations,
    current: current,
  ),
);

class _MoreList extends StatelessWidget {
  const _MoreList({required this.destinations, required this.current});

  final List<ShellDestination> destinations;
  final String current;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final destination in destinations) ...[
          _MoreRow(
            label: destination.label,
            icon: destination.icon,
            selected: Routes.isUnder(current, destination.route),
            route: destination.route,
          ),
          for (final child in destination.children)
            Padding(
              padding: EdgeInsets.only(left: spacing.xlg),
              child: _MoreRow(
                label: child.label,
                icon: AppIcons.subEntry,
                selected: Routes.isUnder(current, child.route),
                route: child.route,
              ),
            ),
          SizedBox(height: spacing.xxs),
        ],
      ],
    );
  }
}

class _MoreRow extends StatelessWidget {
  const _MoreRow({
    required this.label,
    required this.icon,
    required this.selected,
    required this.route,
  });

  final String label;
  final AppIconSpec icon;
  final bool selected;
  final String route;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final scheme = context.colorScheme;
    final radius = BorderRadius.circular(context.appRadius.control);

    return Material(
      color: selected ? colors.brandSoft : Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
          context.go(route);
        },
        borderRadius: radius,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.sm,
            vertical: spacing.sm,
          ),
          child: Row(
            children: [
              AppIcon(
                icon,
                size: spacing.md + 2,
                color: selected ? scheme.primary : colors.textMuted,
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: selected ? scheme.primary : colors.textHigh,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
