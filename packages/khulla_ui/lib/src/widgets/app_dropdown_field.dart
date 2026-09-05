import 'package:khulla_ui/khulla_ui.dart';

/// {@template app_dropdown_field}
/// A labelled select, decorated to match [AppTextField] so a form of mixed
/// controls lines up.
///
/// Generic over the value so a caller keeps its own enum or domain type all
/// the way to `onChanged` — no string round trip, no parsing back. [itemLabel]
/// is how a value becomes text, which keeps localization on the app side.
///
/// Choices open in the same popup menu as [AppMenuButton] and the shell
/// account menu — not Material's built-in dropdown sheet.
/// {@endtemplate}
class AppDropdownField<T> extends StatelessWidget {
  /// {@macro app_dropdown_field}
  const AppDropdownField({
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.label,
    this.hintText,
    this.errorText,
    this.required = false,
    this.enabled = true,
    this.itemIcon,
    super.key,
  });

  /// The current selection. Null shows [hintText].
  final T? value;

  /// The choices, in display order.
  final List<T> items;

  /// Turns a choice into its localized label.
  final String Function(T value) itemLabel;

  /// Called when a choice is made.
  final ValueChanged<T?> onChanged;

  /// Label shown above the control.
  final String? label;

  /// Placeholder while nothing is selected.
  final String? hintText;

  /// Validation message shown under the control.
  final String? errorText;

  /// When true, the label shows a required asterisk.
  final bool required;

  /// Whether the control accepts input.
  final bool enabled;

  /// Optional per-choice glyph — a status dot, a format icon.
  final AppIconSpec? Function(T value)? itemIcon;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final metrics = context.appMetrics;
    final typography = context.appTextStyles;
    final popupTheme = Theme.of(context).popupMenuTheme;
    final fieldLabel = label;
    final iconFor = itemIcon;
    final error = errorText;
    final selected = value;
    final hasValue = selected != null;
    final radius = context.appRadius.container;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (fieldLabel != null) ...[
          AppFieldLabel(
            label: fieldLabel,
            required: required,
            hasError: error != null,
          ),
          SizedBox(height: metrics.labelToControlGap),
        ],
        SizedBox(
          height: metrics.fieldHeight,
          width: double.infinity,
          child: MenuAnchor(
            crossAxisUnconstrained: false,
            style: MenuStyle(
              backgroundColor: WidgetStatePropertyAll(popupTheme.color),
              elevation: WidgetStatePropertyAll(popupTheme.elevation),
              shadowColor: WidgetStatePropertyAll(popupTheme.shadowColor),
              surfaceTintColor: const WidgetStatePropertyAll(
                Colors.transparent,
              ),
              padding: WidgetStatePropertyAll(popupTheme.menuPadding),
              shape: WidgetStatePropertyAll(
                popupTheme.shape is OutlinedBorder
                    ? popupTheme.shape! as OutlinedBorder
                    : RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(radius),
                        side: BorderSide(color: colors.hairline),
                      ),
              ),
            ),
            alignmentOffset: Offset(0, spacing.xxs / 2),
            menuChildren: [
              for (final item in items)
                MenuItemButton(
                  style: MenuItemButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.xs,
                      vertical: spacing.xs + 2,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: enabled ? () => onChanged(item) : null,
                  child: _DropdownMenuRow(
                    icon: iconFor?.call(item),
                    label: itemLabel(item),
                    selected: item == selected,
                  ),
                ),
            ],
            builder: (context, controller, child) {
              return InkWell(
                onTap: enabled
                    ? () {
                        if (controller.isOpen) {
                          controller.close();
                        } else {
                          controller.open();
                        }
                      }
                    : null,
                borderRadius: BorderRadius.circular(radius),
                child: child,
              );
            },
            child: InputDecorator(
              expands: true,
              isEmpty: !hasValue,
              decoration: InputDecoration(
                hintText: hintText,
                enabled: enabled,
                suffixIcon: AppFieldAffix(
                  child: AppIcon(
                    AppIcons.chevronDown,
                    size: metrics.icon,
                    color: colors.ink500,
                  ),
                ),
              ),
              child: hasValue
                  ? Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Row(
                        children: [
                          if (iconFor?.call(selected) case final glyph?) ...[
                            AppIcon(
                              glyph,
                              size: metrics.icon,
                              color: colors.ink500,
                            ),
                            SizedBox(width: spacing.menuIconGap),
                          ],
                          Expanded(
                            child: Text(
                              itemLabel(selected),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: typography.body.copyWith(
                                color: enabled ? colors.ink100 : colors.ink500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : null,
            ),
          ),
        ),
        if (error != null) ...[
          SizedBox(height: spacing.xxs + 2),
          AppFieldError(message: error),
        ],
      ],
    );
  }
}

class _DropdownMenuRow extends StatelessWidget {
  const _DropdownMenuRow({
    required this.label,
    required this.selected,
    this.icon,
  });

  final AppIconSpec? icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final metrics = context.appMetrics;
    final foreground = context.colorScheme.onSurface;
    final glyph = icon;

    return Row(
      children: [
        if (glyph != null) ...[
          AppIcon(glyph, size: metrics.icon, color: colors.ink500),
          SizedBox(width: spacing.menuIconGap),
        ],
        Expanded(
          child: Text(
            label,
            style: context.appTextStyles.label.copyWith(color: foreground),
          ),
        ),
        if (selected) ...[
          SizedBox(width: spacing.xs),
          AppIcon(
            AppIcons.check,
            size: metrics.icon,
            color: colors.brand,
          ),
        ],
      ],
    );
  }
}
