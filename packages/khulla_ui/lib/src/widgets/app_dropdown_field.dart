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
    final metrics = context.appMetrics;
    final fieldLabel = label;
    final error = errorText;

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
        _DropdownFieldControl<T>(
          value: value,
          items: items,
          itemLabel: itemLabel,
          onChanged: onChanged,
          hintText: hintText,
          enabled: enabled,
          itemIcon: itemIcon,
        ),
        if (error != null) ...[
          SizedBox(height: context.appSpacing.xxs + 2),
          AppFieldError(message: error),
        ],
      ],
    );
  }
}

class _DropdownFieldControl<T> extends StatefulWidget {
  const _DropdownFieldControl({
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.hintText,
    this.enabled = true,
    this.itemIcon,
  });

  final T? value;
  final List<T> items;
  final String Function(T value) itemLabel;
  final ValueChanged<T?> onChanged;
  final String? hintText;
  final bool enabled;
  final AppIconSpec? Function(T value)? itemIcon;

  @override
  State<_DropdownFieldControl<T>> createState() =>
      _DropdownFieldControlState<T>();
}

class _DropdownFieldControlState<T> extends State<_DropdownFieldControl<T>> {
  final _layerLink = LayerLink();

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final metrics = context.appMetrics;
    final typography = context.appTextStyles;
    final popupTheme = Theme.of(context).popupMenuTheme;
    final iconFor = widget.itemIcon;
    final selected = widget.value;
    final hasValue = selected != null;
    final selectedIcon = hasValue ? iconFor?.call(selected) : null;
    final radius = context.appRadius.container;
    final itemRadius = context.appRadius.item;
    final hairline = context.appBorders.hairline;
    final enabled = widget.enabled;
    final menuElevation = popupTheme.elevation ?? 6;
    final menuShadowColor =
        popupTheme.shadowColor ?? context.appShadows.raised.first.color;

    ButtonStyle menuItemStyleFor(bool isSelected) {
      return MenuItemButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.xs,
          vertical: spacing.xs + 2,
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(itemRadius),
        ),
      ).copyWith(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (!enabled) return Colors.transparent;
          if (isSelected ||
              states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.pressed)) {
            return colors.tints.menuItemFocus;
          }
          return Colors.transparent;
        }),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final fieldWidth = constraints.maxWidth;
        final menuInset = spacing.xxs;
        final itemWidth = fieldWidth - menuInset * 2;

        return MenuAnchor(
          layerLink: _layerLink,
          crossAxisUnconstrained: false,
          reservedPadding: EdgeInsets.zero,
          alignmentOffset: Offset(0, -hairline),
          style: MenuStyle(
            backgroundColor: WidgetStatePropertyAll(popupTheme.color),
            elevation: WidgetStatePropertyAll(menuElevation),
            shadowColor: WidgetStatePropertyAll(menuShadowColor),
            surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
            padding: WidgetStatePropertyAll(
              EdgeInsets.fromLTRB(menuInset, 0, menuInset, menuInset),
            ),
            minimumSize: WidgetStatePropertyAll(Size(fieldWidth, 0)),
            maximumSize: WidgetStatePropertyAll(
              Size(fieldWidth, double.infinity),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(radius),
                  bottomRight: Radius.circular(radius),
                ),
                side: BorderSide(color: colors.hairline),
              ),
            ),
          ),
          menuChildren: [
            for (final item in widget.items)
              MenuItemButton(
                style: menuItemStyleFor(item == selected).merge(
                  MenuItemButton.styleFrom(
                    minimumSize: Size(itemWidth, 0),
                    maximumSize: Size(itemWidth, double.infinity),
                  ),
                ),
                onPressed: enabled ? () => widget.onChanged(item) : null,
                child: _DropdownMenuRow(
                  icon: iconFor?.call(item),
                  label: widget.itemLabel(item),
                  selected: item == selected,
                ),
              ),
          ],
          builder: (context, controller, child) {
            return MouseRegion(
              cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: enabled
                    ? () {
                        if (controller.isOpen) {
                          controller.close();
                        } else {
                          controller.open();
                        }
                      }
                    : null,
                child: child,
              ),
            );
          },
          child: SizedBox(
            height: metrics.fieldHeight,
            width: fieldWidth,
            child: InputDecorator(
              expands: true,
              isEmpty: !hasValue,
              decoration: InputDecoration(
                isDense: true,
                hintText: widget.hintText,
                enabled: enabled,
                contentPadding: EdgeInsetsDirectional.only(
                  start: spacing.sm,
                  end: spacing.sm,
                  top: spacing.xs,
                  bottom: spacing.xs,
                ),
              ),
              child: Row(
                children: [
                  if (selectedIcon != null) ...[
                    AppIcon(
                      selectedIcon,
                      size: metrics.icon,
                      color: colors.ink500,
                    ),
                    SizedBox(width: spacing.menuIconGap),
                  ],
                  Expanded(
                    child: hasValue
                        ? Text(
                            widget.itemLabel(selected),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: typography.body.copyWith(
                              color: enabled ? colors.ink100 : colors.ink500,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  AppIcon(
                    AppIcons.chevronDown,
                    size: metrics.icon,
                    color: colors.ink500,
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
