import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The product mark in the shell's top chrome row.
///
/// Sits above the navigation rail in the shell's left column, beside
/// [AppTopBar] on the right. The icon column matches [AppNavRail]
/// destination rows exactly — same slot width, same gap, same left inset.
class ShellBrandHeader extends StatelessWidget {
  const ShellBrandHeader({required this.extended, super.key});

  /// Whether the rail beside this header is showing labels.
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final scheme = context.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          right: BorderSide(color: colors.hairline),
          bottom: BorderSide(color: colors.hairline),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          spacing.sm,
          spacing.sm,
          spacing.sm,
          spacing.sm,
        ),
        child: Align(
          alignment: extended
              ? AlignmentDirectional.centerStart
              : Alignment.center,
          child: ShellBrandMark(extended: extended),
        ),
      ),
    );
  }
}

/// Product mark drawn for the shell header and the collapsed rail.
///
/// Extended: a brand glyph in the navigation icon column plus the library
/// name and tagline — no raised tile, so the header reads as part of the
/// rail rather than a separate badge.
///
/// Collapsed: a centred monogram tile, because at 64px there is no room for
/// labels and the square is the whole identity.
class ShellBrandMark extends StatelessWidget {
  const ShellBrandMark({required this.extended, super.key});

  /// Whether the rail is showing labels beside its icons.
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final scheme = context.colorScheme;
    final metrics = context.appMetrics;
    final l10n = context.l10n;

    if (!extended) {
      return Tooltip(
        message: l10n.appName,
        child: _Monogram(scheme: scheme),
      );
    }

    return Row(
      children: [
        SizedBox(
          width: metrics.iconNav,
          child: Center(
            child: AppIcon(
              AppIcons.openBook,
              size: metrics.iconNav,
              color: colors.brand,
            ),
          ),
        ),
        SizedBox(width: spacing.navIconGap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.appName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.appTextStyles.bodyLarge.copyWith(
                  color: colors.ink100,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                  height: 1.2,
                ),
              ),
              SizedBox(height: spacing.xxs / 2),
              Text(
                l10n.appTagline,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.appTextStyles.micro.copyWith(
                  color: colors.ink500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Monogram extends StatelessWidget {
  const _Monogram({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;

    return Container(
      width: spacing.xlg,
      height: spacing.xlg,
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(context.appRadius.container),
        boxShadow: context.appShadows.raised,
      ),
      alignment: Alignment.center,
      child: AppIcon(
        AppIcons.openBook,
        size: context.appMetrics.iconLarge,
        color: scheme.onPrimary,
      ),
    );
  }
}
