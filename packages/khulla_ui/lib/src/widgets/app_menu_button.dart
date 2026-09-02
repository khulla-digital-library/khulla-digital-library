import 'package:khulla_ui/khulla_ui.dart';

/// {@template app_menu_button}
/// The overflow menu: an icon button that opens a list of [AppMenuAction]s.
/// {@endtemplate}
class AppMenuButton extends StatelessWidget {
  /// {@macro app_menu_button}
  const AppMenuButton({
    required this.actions,
    required this.tooltip,
    this.icon = Icons.more_horiz_rounded,
    super.key,
  });

  /// The entries, in order, destructive ones last.
  final List<AppMenuAction> actions;

  /// What the menu holds, already localized — "More actions".
  final String tooltip;

  /// The trigger glyph.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;

    return PopupMenuButton<AppMenuAction>(
      tooltip: tooltip,
      icon: Icon(icon, size: spacing.md + 4, color: scheme.onSurfaceVariant),
      position: PopupMenuPosition.under,
      onSelected: (action) => action.onSelected(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.appRadius.card),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      color: scheme.surface,
      elevation: 3,
      itemBuilder: (menuContext) => [
        for (final action in actions)
          PopupMenuItem<AppMenuAction>(
            value: action,
            enabled: action.enabled,
            child: _MenuActionRow(action: action),
          ),
      ],
    );
  }
}

class _MenuActionRow extends StatelessWidget {
  const _MenuActionRow({required this.action});

  final AppMenuAction action;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final foreground = action.isDestructive ? scheme.error : scheme.onSurface;
    final glyph = action.icon;

    return Row(
      children: [
        if (glyph != null) ...[
          Icon(glyph, size: spacing.md + 2, color: foreground),
          SizedBox(width: spacing.sm),
        ],
        Text(
          action.label,
          style: context.textTheme.bodyMedium?.copyWith(color: foreground),
        ),
      ],
    );
  }
}
