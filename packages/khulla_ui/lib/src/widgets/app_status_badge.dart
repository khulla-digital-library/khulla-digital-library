import 'package:khulla_ui/khulla_ui.dart';

/// {@template app_status_badge}
/// A pill stating one record's standing — *Available*, *Overdue*, *Reserved*.
///
/// It takes a ready-made [label] and an [AppStatusTone]; deciding that an
/// overdue loan is [AppStatusTone.danger] is the feature's job, because the
/// design system does not know what a loan is.
/// {@endtemplate}
class AppStatusBadge extends StatelessWidget {
  /// {@macro app_status_badge}
  const AppStatusBadge({
    required this.label,
    this.tone = AppStatusTone.neutral,
    this.icon,
    this.dense = false,
    super.key,
  });

  /// The standing, already localized.
  final String label;

  /// Which semantic family the badge draws from.
  final AppStatusTone tone;

  /// Optional leading glyph, for a status that repeats down a dense table
  /// where colour alone is not enough to tell two rows apart.
  final IconData? icon;

  /// Tightens the pill for use inside a table row.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final foreground = tone.foreground(context);
    final glyph = icon;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tone.background(context),
        borderRadius: BorderRadius.circular(context.appRadius.pill),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: dense ? spacing.xs : spacing.sm,
          vertical: dense ? spacing.xxs / 2 : spacing.xxs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (glyph != null) ...[
              Icon(glyph, size: spacing.sm, color: foreground),
              SizedBox(width: spacing.xxs),
            ],
            Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
