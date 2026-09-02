import 'package:khulla_ui/khulla_ui.dart';

/// {@template app_side_sheet}
/// A modal editor panel that enters from the trailing edge on a window and
/// from the bottom on a phone.
///
/// One call for both, because the same *Edit member* form is reached from a
/// desktop rail and a phone browser tab, and a sheet that slides up on a
/// 1600px monitor wastes the room the form needs. Below
/// [FormFactor.medium] it hands off to [AppBottomSheet] unchanged, so the
/// compact behaviour stays exactly what the rest of the app does.
///
/// Actions are pinned below the scrolling body: a form that grows an extra
/// field must never scroll its *Save* out of reach.
/// {@endtemplate}
class AppSideSheet extends StatelessWidget {
  /// {@macro app_side_sheet}
  const AppSideSheet({
    required this.title,
    required this.child,
    required this.closeTooltip,
    this.caption,
    this.actions,
    this.width = 480,
    super.key,
  });

  /// The panel heading, already localized.
  final String title;

  /// The scrolling body — typically a [Column] of [AppFormSection]s.
  final Widget child;

  /// Tooltip on the close control.
  final String closeTooltip;

  /// Supporting line under [title].
  final String? caption;

  /// Pinned action row, primary trailing.
  final Widget? actions;

  /// Panel width on a wide window. It never exceeds 90% of the window, so a
  /// half-size window still shows the page behind it.
  final double width;

  /// Presents the panel and resolves to whatever it is popped with.
  ///
  /// Uses a bottom sheet below [FormFactor.medium] and a trailing-edge panel
  /// above it.
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String closeTooltip,
    required WidgetBuilder builder,
    String? caption,
    WidgetBuilder? actionsBuilder,
    double width = 480,
    bool barrierDismissible = true,
    String barrierLabel = 'Dismiss',
  }) {
    if (!context.formFactor.usesNavigationRail) {
      return AppBottomSheet.show<T>(
        context: context,
        title: title,
        caption: caption,
        builder: builder,
        actionsBuilder: actionsBuilder,
        heightFactor: AppBottomSheet.defaultHeightFactor,
      );
    }

    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (dialogContext, _, _) => Align(
        alignment: AlignmentDirectional.centerEnd,
        child: AppSideSheet(
          title: title,
          caption: caption,
          closeTooltip: closeTooltip,
          width: width,
          actions: actionsBuilder == null
              ? null
              : Builder(builder: actionsBuilder),
          child: Builder(builder: builder),
        ),
      ),
      transitionBuilder: (context, animation, _, child) => SlideTransition(
        position:
            Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final radius = context.appRadius;
    final captionText = caption;
    final actionRow = actions;
    final panelWidth = width.clamp(0.0, MediaQuery.sizeOf(context).width * 0.9);

    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.horizontal(
          start: Radius.circular(radius.banner),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: panelWidth,
        height: double.infinity,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.2,
                              color: scheme.onSurface,
                            ),
                          ),
                          if (captionText != null) ...[
                            SizedBox(height: spacing.xxs),
                            Text(
                              captionText,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(width: spacing.sm),
                    AppIconButton(
                      icon: Icons.close_rounded,
                      tooltip: closeTooltip,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                SizedBox(height: spacing.lg),
                Expanded(child: SingleChildScrollView(child: child)),
                if (actionRow != null) ...[
                  SizedBox(height: spacing.md),
                  actionRow,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
