import 'package:khulla/features/users/domain/user_role.dart';
import 'package:khulla/features/users/presentation/user_labels.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Every permission against every role.
///
/// A grid rather than four lists, because the question an administrator asks
/// is comparative — "who else can waive a fine" — and four lists make that a
/// memory exercise. The grid scrolls horizontally on a narrow window rather
/// than dropping columns: a matrix missing a role is worse than one you have
/// to push sideways.
class PermissionMatrix extends StatelessWidget {
  const PermissionMatrix({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final scheme = context.colorScheme;

    const labelWidth = 240.0;
    const roleWidth = 132.0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: labelWidth + roleWidth * 4,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(context.appRadius.control),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.sm,
                  vertical: spacing.xs + 2,
                ),
                child: Row(
                  children: [
                    const SizedBox(width: labelWidth),
                    for (final role in UserRole.values)
                      SizedBox(
                        width: roleWidth,
                        child: Text(
                          role.label(l10n),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.appTextStyles.columnHeader.copyWith(
                            color: colors.textMuted,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            for (final permission in StaffPermission.values)
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: colors.hairline),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.sm,
                    vertical: spacing.sm,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: labelWidth,
                        child: Text(
                          permission.label(l10n),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: colors.textHigh,
                          ),
                        ),
                      ),
                      for (final role in UserRole.values)
                        SizedBox(
                          width: roleWidth,
                          child: Center(
                            child:
                                (rolePermissions[role] ??
                                        const <StaffPermission>{})
                                    .contains(permission)
                                ? Icon(
                                    Icons.check_circle_rounded,
                                    size: spacing.md + 2,
                                    color: colors.success,
                                  )
                                : Icon(
                                    Icons.remove_rounded,
                                    size: spacing.md + 2,
                                    color: colors.hairlineStrong,
                                  ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
