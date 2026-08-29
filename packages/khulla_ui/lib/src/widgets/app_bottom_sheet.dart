import 'package:khulla_ui/khulla_ui.dart';

/// Shared modal bottom sheet chrome: rounded top corners, a title row with a
/// close button, and keyboard-safe padding.
///
/// Pass [actions] to pin a button row to the bottom of the sheet. Actions sit
/// outside the scrolling body, so a sheet whose content grows — an extra field,
/// a photo picker — never scrolls its confirm button out of reach.
///
/// Use [AppBottomSheet.show] to present a sheet with this chrome. The sheet's
/// corner radius and background also come from [ThemeData.bottomSheetTheme],
/// so a raw `showModalBottomSheet` call picks up the same rounding even
/// without this wrapper.
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    required this.title,
    required this.child,
    this.caption,
    this.titleTrailing,
    this.actions,
    this.expandBody = false,
    super.key,
  });

  final String title;
  final String? caption;

  /// Optional control pinned to the trailing edge of the title row.
  final Widget? titleTrailing;
  final Widget child;

  /// Pinned below the scrolling body, typically a cancel/confirm button row.
  final Widget? actions;

  /// When true, the body expands to fill a fixed-height sheet.
  final bool expandBody;

  /// Default fraction of screen height for sheets with scrollable content.
  static const double defaultHeightFactor = 0.7;

  /// Presents [child] (built lazily via [builder]) wrapped in the standard
  /// sheet chrome, and resolves to whatever the sheet is popped with.
  ///
  /// [heightFactor] sets a fixed sheet height as a fraction of the screen
  /// (e.g. [defaultHeightFactor] or `0.8` for a tall picker). Omit for the
  /// default intrinsic height — only suitable for short, non-scrolling content.
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required WidgetBuilder builder,
    String? caption,
    WidgetBuilder? titleTrailingBuilder,
    WidgetBuilder? actionsBuilder,
    bool isScrollControlled = true,
    double? heightFactor,
  }) => showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    builder: (sheetContext) {
      final expandBody = heightFactor != null;
      final sheet = AppBottomSheet(
        title: title,
        caption: caption,
        titleTrailing: titleTrailingBuilder == null
            ? null
            : Builder(builder: titleTrailingBuilder),
        expandBody: expandBody,
        actions: actionsBuilder == null
            ? null
            : Builder(builder: actionsBuilder),
        child: Builder(builder: builder),
      );
      if (heightFactor == null) return sheet;

      return SizedBox(
        height: MediaQuery.sizeOf(sheetContext).height * heightFactor,
        child: sheet,
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final captionText = caption;
    final trailing = titleTrailing;
    final actionRow = actions;

    return SizedBox(
      width: double.infinity,
      height: expandBody ? double.infinity : null,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  spacing.page,
                  spacing.md,
                  spacing.page,
                  spacing.md,
                ),
                child: Column(
                  mainAxisSize: expandBody
                      ? MainAxisSize.max
                      : MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.2,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                        ?trailing,
                        SizedBox(
                          width: trailing == null
                              ? spacing.sm + _AppBottomSheetCloseButton.diameter
                              : spacing.xxs +
                                    _AppBottomSheetCloseButton.diameter,
                        ),
                      ],
                    ),
                    if (captionText != null) ...[
                      SizedBox(height: spacing.xxs),
                      Text(
                        captionText,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                    SizedBox(height: spacing.md),
                    if (expandBody) Expanded(child: child) else child,
                    if (actionRow != null) ...[
                      SizedBox(height: spacing.md),
                      actionRow,
                    ],
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -_AppBottomSheetCloseButton.diameter / 2,
            right: spacing.page,
            child: _AppBottomSheetCloseButton(
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppBottomSheetCloseButton extends StatelessWidget {
  const _AppBottomSheetCloseButton({required this.onTap});

  static const double _iconPadding = 8;
  static const double _iconSize = 18;
  static const double diameter = _iconPadding * 2 + _iconSize;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Material(
      color: scheme.surface,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(_iconPadding),
          child: Icon(
            Icons.close_rounded,
            size: _iconSize,
            color: scheme.onSurface,
          ),
        ),
      ),
    );
  }
}
