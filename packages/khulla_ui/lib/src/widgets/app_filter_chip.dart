import 'package:khulla_ui/khulla_ui.dart';

/// {@template app_filter_chip}
/// One toggleable filter in a toolbar's chip row, with an optional count.
///
/// Chips are additive filters that can all be off at once; when exactly one
/// choice must always be active, that is [AppSegmentedControl] instead.
/// {@endtemplate}
class AppFilterChip extends StatelessWidget {
  /// {@macro app_filter_chip}
  const AppFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.count,
    this.icon,
    this.tone = AppStatusTone.brand,
    super.key,
  });

  /// The filter's localized name.
  final String label;

  /// Whether the filter is currently applied.
  final bool selected;

  /// Called with the next state. Null disables the chip.
  final ValueChanged<bool>? onSelected;

  /// How many records match, shown after the label. Null hides the count —
  /// which is the right choice while the count is still loading, rather than
  /// showing a zero that is not yet true.
  final int? count;

  /// Optional leading glyph.
  final IconData? icon;

  /// Which semantic family the selected state draws from. Use
  /// [AppStatusTone.danger] for an *Overdue* chip so the row reads at a
  /// glance.
  final AppStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final accent = tone.foreground(context);
    final glyph = icon;
    final total = count;

    return FilterChip(
      selected: selected,
      onSelected: onSelected,
      showCheckmark: false,
      avatar: glyph == null
          ? null
          : Icon(
              glyph,
              size: spacing.md,
              color: selected ? accent : scheme.onSurfaceVariant,
            ),
      label: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: label),
            if (total != null)
              TextSpan(
                text: '  $total',
                style: TextStyle(
                  color: (selected ? accent : scheme.onSurfaceVariant)
                      .withValues(alpha: 0.7),
                ),
              ),
          ],
        ),
      ),
      labelStyle: context.textTheme.labelSmall?.copyWith(
        color: selected ? accent : scheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
      backgroundColor: scheme.surface,
      selectedColor: tone.background(context),
      side: BorderSide(
        color: selected ? accent.withValues(alpha: 0.4) : scheme.outlineVariant,
      ),
    );
  }
}
