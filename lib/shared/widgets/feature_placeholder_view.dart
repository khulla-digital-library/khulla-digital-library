import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Stands in for a shell destination that has no feature behind it yet.
///
/// Every branch of the router points here today. Replacing one is a two-line
/// change: build `features/<name>/`, then swap this widget for that feature's
/// page in `app_router.dart`.
class FeaturePlaceholderView extends StatelessWidget {
  const FeaturePlaceholderView({
    required this.section,
    required this.icon,
    super.key,
  });

  /// Localized destination name, e.g. the catalogue.
  final String section;

  /// The destination's glyph, matching its navigation entry.
  final AppIconSpec icon;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;

    return Scaffold(
      body: AppPageBody(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(spacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcon(
                  icon,
                  size: spacing.xxlg,
                  color: scheme.onSurfaceVariant,
                ),
                SizedBox(height: spacing.md),
                Text(
                  l10n.sectionComingSoonTitle(section),
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: spacing.xs),
                Text(
                  l10n.sectionComingSoonBody,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
