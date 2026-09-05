import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/widgets/app_logo.dart';
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
/// Extended: the horizontal wordmark plus the product tagline — the wordmark
/// already carries the name, so no duplicate title line.
///
/// Collapsed: the submark centred in the rail width, because at 64px there is
/// no room for the wordmark.
class ShellBrandMark extends StatelessWidget {
  const ShellBrandMark({required this.extended, super.key});

  /// Whether the rail is showing labels beside its icons.
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final l10n = context.l10n;

    if (!extended) {
      return Tooltip(
        message: l10n.appName,
        child: AppLogo.submark(size: spacing.lg),
      );
    }

    return AppLogo.primaryFull(height: spacing.xlg + spacing.md);
  }
}
