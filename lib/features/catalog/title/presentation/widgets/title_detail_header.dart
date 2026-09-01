import 'package:khulla/features/catalog/shared/presentation/catalog_labels.dart';
import 'package:khulla/features/catalog/shared/presentation/placeholder/catalog_title.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// A title's identity block: what the work is, how it stands, and the one
/// thing the page is for.
///
/// Secondary actions sit behind [AppMenuButton] rather than becoming a row of
/// equal buttons, and the destructive one is inside that menu — never beside
/// the primary action.
class TitleDetailHeader extends StatelessWidget {
  const TitleDetailHeader({
    required this.title,
    required this.onEdit,
    required this.menuActions,
    super.key,
  });

  final CatalogTitle title;
  final VoidCallback onEdit;
  final List<AppMenuAction> menuActions;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final isAvailable = title.available > 0;
    final subtitle = title.subtitle;

    final identity = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title.title,
          style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w500,
            letterSpacing: -0.5,
            color: context.appColors.textHigh,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: spacing.xxs),
          Text(
            subtitle,
            style: context.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
        SizedBox(height: spacing.xs),
        Text(
          title.author,
          style: context.textTheme.bodyMedium?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: spacing.sm),
        Wrap(
          spacing: spacing.xs,
          runSpacing: spacing.xs,
          children: [
            AppStatusBadge(
              label: isAvailable ? l10n.statusAvailable : l10n.statusOnLoan,
              tone: isAvailable ? AppStatusTone.success : AppStatusTone.brand,
              icon: isAvailable
                  ? Icons.check_circle_outline_rounded
                  : Icons.swap_horiz_rounded,
            ),
            AppStatusBadge(
              label: title.format.label(l10n),
              icon: title.format.icon,
            ),
            AppStatusBadge(
              label: l10n.titlesCopiesOf(
                '${title.available}',
                '${title.copies}',
              ),
              icon: Icons.inventory_2_outlined,
            ),
            if (!title.lendable)
              AppStatusBadge(
                label: l10n.titlesReferenceOnly,
                tone: AppStatusTone.warning,
                icon: Icons.lock_outline_rounded,
              ),
          ],
        ),
      ],
    );

    final actions = [
      AppMenuButton(actions: menuActions, tooltip: l10n.commonMoreActions),
      SizedBox(width: spacing.xs),
      AppButton(
        size: AppButtonSize.medium,
        onPressed: onEdit,
        child: Text(l10n.titleDetailEdit),
      ),
    ];

    return AppCard(
      child: context.formFactor.isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                identity,
                SizedBox(height: spacing.md),
                Row(children: actions),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: identity),
                SizedBox(width: spacing.lg),
                Row(mainAxisSize: MainAxisSize.min, children: actions),
              ],
            ),
    );
  }
}
