import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The reader's search box, and the subjects they can start from.
///
/// It is deliberately the loudest thing on the screen. A public catalogue is
/// used by someone standing up, at a shared machine, for about forty seconds;
/// the search field has to be the obvious target from across the room, and
/// the subject chips have to give the reader who does not know what to type
/// somewhere to go.
class OpacSearchPanel extends StatelessWidget {
  const OpacSearchPanel({
    required this.controller,
    required this.onChanged,
    required this.availableOnly,
    required this.onAvailableOnlyChanged,
    required this.subjects,
    required this.selectedSubject,
    required this.onSubjectSelected,
    super.key,
  });

  /// Drives the search field from the page, so a subject chip can fill it.
  final TextEditingController controller;

  /// Called on every keystroke.
  final ValueChanged<String> onChanged;

  /// Whether results are limited to what is on the shelf now.
  final bool availableOnly;

  /// Toggles that limit.
  final ValueChanged<bool> onAvailableOnlyChanged;

  /// The subjects offered as starting points.
  final List<String> subjects;

  /// The subject currently filtering the results, if any.
  final String? selectedSubject;

  /// Called with a subject, or null to clear it.
  final ValueChanged<String?> onSubjectSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final colors = context.appColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.appRadius.control),
        border: Border.all(color: colors.hairline),
      ),
      child: Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.opacHeading,
              style: context.appTextStyles.title.copyWith(
                color: colors.ink100,
              ),
            ),
            SizedBox(height: spacing.xxs),
            Text(
              l10n.opacSubtitle,
              style: context.appTextStyles.body.copyWith(
                color: colors.mutedForeground,
              ),
            ),
            SizedBox(height: spacing.md),
            AppSearchField(
              controller: controller,
              hintText: l10n.opacSearchHint,
              clearTooltip: l10n.commonClearSearch,
              onChanged: onChanged,
            ),
            SizedBox(height: spacing.sm),
            Wrap(
              spacing: spacing.xs,
              runSpacing: spacing.xs,
              children: [
                AppFilterChip(
                  label: l10n.opacFilterAvailableOnly,
                  icon: Icons.check_circle_outline_rounded,
                  tone: AppStatusTone.success,
                  selected: availableOnly,
                  onSelected: onAvailableOnlyChanged,
                ),
                for (final subject in subjects)
                  AppFilterChip(
                    label: subject,
                    selected: subject == selectedSubject,
                    onSelected: (selected) =>
                        onSubjectSelected(selected ? subject : null),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
