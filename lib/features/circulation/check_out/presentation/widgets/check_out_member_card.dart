import 'package:khulla/core/money/money.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/components/section_card.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Who the copies are going home with.
///
/// Empty first, on purpose: the loan period, the borrowing limit and whether
/// the desk may lend at all come from the member's category, so the screen
/// asks for the card before it asks for a barcode.
class CheckOutMemberCard extends StatelessWidget {
  const CheckOutMemberCard({
    required this.onSearchChanged,
    required this.onChangeMember,
    required this.memberName,
    required this.memberCard,
    required this.memberCategory,
    required this.outstandingFines,
    required this.initials,
    super.key,
  });

  /// Reports the lookup query. A cubit debounces it and runs the search.
  final ValueChanged<String> onSearchChanged;

  /// Clears the chosen member and returns the card to its lookup state.
  final VoidCallback onChangeMember;

  /// The chosen member, or null while none has been picked.
  final String? memberName;

  final String? memberCard;
  final String? memberCategory;

  /// What they already owe — the thing a desk needs to see before lending
  /// again, not after.
  final Money outstandingFines;

  /// Two ready-made letters for the avatar.
  final String? initials;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final name = memberName;

    return SectionCard(
      title: l10n.checkOutMemberSection,
      trailing: name == null
          ? null
          : AppTextButton(
              onPressed: onChangeMember,
              child: Text(l10n.checkOutChangeMember),
            ),
      child: name == null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppSearchField(
                  hintText: l10n.checkOutMemberHint,
                  clearTooltip: l10n.commonClearSearch,
                  onChanged: onSearchChanged,
                ),
                SizedBox(height: spacing.md),
                AppEmptyView(
                  variant: AppFeedbackVariant.inline,
                  title: l10n.checkOutMemberEmptyTitle,
                  message: l10n.checkOutMemberEmptyBody,
                ),
              ],
            )
          : Row(
              children: [
                AppAvatar(initials: initials ?? '', size: 48),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: scheme.onSurface,
                        ),
                      ),
                      SizedBox(height: spacing.xxs),
                      Text(
                        '${memberCard ?? ''} · ${memberCategory ?? ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (outstandingFines.isPositive)
                  AppStatusBadge(
                    label: outstandingFines.display(),
                    tone: AppStatusTone.danger,
                    icon: AppIcons.wallet,
                  ),
              ],
            ),
    );
  }
}
