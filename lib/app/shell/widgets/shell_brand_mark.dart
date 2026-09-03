import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Product mark pinned to the top of the navigation rail.
///
/// Collapses to the monogram alone when the rail is not [extended], so it
/// keeps the rail's width rather than forcing it wider. The mark is drawn
/// rather than shipped as an asset: a glyph on the flat brand square reads at
/// 32px, which a raster logo does not.
///
/// Flat, not gradient. The brand is one colour in this design, and a gradient
/// on the one square that represents the product is exactly the kind of
/// decoration the rest of the chrome refuses.
class ShellBrandMark extends StatelessWidget {
  const ShellBrandMark({required this.extended, super.key});

  /// Whether the rail is showing labels beside its icons.
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final l10n = context.l10n;

    final monogram = Container(
      width: spacing.xlg,
      height: spacing.xlg,
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(context.appRadius.container),
      ),
      alignment: Alignment.center,
      child: AppIcon(
        AppIcons.openBook,
        size: context.appMetrics.iconLarge,
        color: scheme.onPrimary,
      ),
    );

    if (!extended) {
      return Tooltip(message: l10n.appName, child: monogram);
    }

    return Row(
      children: [
        monogram,
        SizedBox(width: spacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.appName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.appTextStyles.sectionTitle.copyWith(
                  color: context.appColors.ink100,
                ),
              ),
              Text(
                l10n.appTagline,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.appTextStyles.micro.copyWith(
                  color: context.appColors.ink500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
