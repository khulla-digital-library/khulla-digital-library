import 'package:khulla_ui/khulla_ui.dart';

/// {@template app_pagination}
/// The footer under a table: which rows are showing, and the controls to
/// move a page either way.
///
/// [rangeLabel] arrives ready-made — "1–25 of 1,204" is a sentence with a
/// locale's number grouping in it, which the design system does not own.
/// Pass null to [onPrevious] or [onNext] at the ends of the range rather than
/// hiding the control, so the footer does not change width as it is used.
/// {@endtemplate}
class AppPagination extends StatelessWidget {
  /// {@macro app_pagination}
  const AppPagination({
    required this.rangeLabel,
    required this.onPrevious,
    required this.onNext,
    required this.previousTooltip,
    required this.nextTooltip,
    this.pageSizeControl,
    super.key,
  });

  /// Which rows are on screen, already formatted.
  final String rangeLabel;

  /// Moves back one page. Null on the first page.
  final VoidCallback? onPrevious;

  /// Moves forward one page. Null on the last page.
  final VoidCallback? onNext;

  /// Tooltip for the back control.
  final String previousTooltip;

  /// Tooltip for the forward control.
  final String nextTooltip;

  /// Optional rows-per-page control, typically an [AppDropdownField].
  final Widget? pageSizeControl;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final sizeControl = pageSizeControl;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.xs,
      ),
      child: Row(
        children: [
          if (sizeControl != null) ...[
            sizeControl,
            SizedBox(width: spacing.md),
          ],
          Expanded(
            child: Text(
              rangeLabel,
              style: context.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          AppIconButton(
            icon: Icons.chevron_left_rounded,
            tooltip: previousTooltip,
            onPressed: onPrevious,
          ),
          SizedBox(width: spacing.xxs),
          AppIconButton(
            icon: Icons.chevron_right_rounded,
            tooltip: nextTooltip,
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}
