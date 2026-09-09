// Copyright (c) 2026 Khulla Digital Library contributors.
// SPDX-License-Identifier: MIT

import 'package:khulla_ui/khulla_ui.dart';

/// The floating panel an [AppDropdownFieldControl] opens: an optional fixed
/// search header, the scrollable choice list, and an optional pinned footer
/// action.
///
/// Positioned by [layerLink] under the field; everything it shows arrives as
/// ready-made strings and callbacks, so this file stays free of domain and
/// localization.
class AppDropdownMenu<T> extends StatelessWidget {
  const AppDropdownMenu({
    required this.layerLink,
    required this.fieldWidth,
    required this.searchFocus,
    required this.searchController,
    required this.scrollController,
    required this.searchable,
    required this.items,
    required this.itemLabel,
    required this.itemExtent,
    required this.menuMaxHeight,
    required this.enabled,
    required this.onQueryChanged,
    required this.onSelected,
    required this.onClose,
    this.searchHint,
    this.clearSearchTooltip,
    this.emptySearchMessage,
    this.selected,
    this.itemIcon,
    this.footerActionLabel,
    this.onFooterAction,
    this.footerActionIcon,
    super.key,
  });

  final LayerLink layerLink;
  final double fieldWidth;
  final FocusNode searchFocus;
  final TextEditingController searchController;
  final ScrollController scrollController;
  final bool searchable;
  final String? searchHint;
  final String? clearSearchTooltip;
  final String? emptySearchMessage;
  final List<T> items;
  final T? selected;
  final String Function(T value) itemLabel;
  final AppIconSpec? Function(T value)? itemIcon;
  final double itemExtent;
  final double menuMaxHeight;
  final bool enabled;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<T> onSelected;
  final VoidCallback onClose;
  final String? footerActionLabel;
  final VoidCallback? onFooterAction;
  final AppIconSpec? footerActionIcon;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final popupTheme = Theme.of(context).popupMenuTheme;
    final radius = context.appRadius.container;
    final itemRadius = context.appRadius.item;
    final hairline = context.appBorders.hairline;
    final menuElevation = popupTheme.elevation ?? 6;
    final menuShadowColor =
        popupTheme.shadowColor ?? context.appShadows.raised.first.color;
    final menuInset = spacing.sm;
    final iconFor = itemIcon;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onClose,
          ),
        ),
        CompositedTransformFollower(
          link: layerLink,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomLeft,
          offset: Offset(0, -hairline),
          child: TapRegion(
            onTapOutside: (_) => onClose(),
            child: Material(
              elevation: menuElevation,
              shadowColor: menuShadowColor,
              color: popupTheme.color,
              surfaceTintColor: Colors.transparent,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(radius),
                  bottomRight: Radius.circular(radius),
                ),
                side: BorderSide(color: colors.hairline),
              ),
              child: SizedBox(
                width: fieldWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (searchable && searchHint != null) ...[
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          menuInset,
                          menuInset,
                          menuInset,
                          spacing.xxs,
                        ),
                        child: AppSearchField(
                          controller: searchController,
                          focusNode: searchFocus,
                          hintText: searchHint!,
                          clearTooltip: clearSearchTooltip,
                          dense: true,
                          autofocus: true,
                          onChanged: onQueryChanged,
                        ),
                      ),
                    ],
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: menuMaxHeight),
                      child: items.isEmpty
                          ? (emptySearchMessage == null
                                ? const SizedBox.shrink()
                                : AppDropdownEmptyState(
                                    message: emptySearchMessage,
                                    itemExtent: itemExtent,
                                  ))
                          : Scrollbar(
                              controller: scrollController,
                              thumbVisibility: true,
                              child: ListView.builder(
                                controller: scrollController,
                                shrinkWrap: true,
                                padding: EdgeInsets.fromLTRB(
                                  menuInset,
                                  0,
                                  menuInset,
                                  footerActionLabel == null
                                      ? menuInset
                                      : spacing.xxs,
                                ),
                                itemExtent: itemExtent,
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  final item = items[index];
                                  final isSelected = item == selected;
                                  return AppDropdownMenuItem(
                                    label: itemLabel(item),
                                    icon: iconFor?.call(item),
                                    selected: isSelected,
                                    enabled: enabled,
                                    itemRadius: itemRadius,
                                    onTap: enabled
                                        ? () => onSelected(item)
                                        : null,
                                  );
                                },
                              ),
                            ),
                    ),
                    if (footerActionLabel != null &&
                        onFooterAction != null) ...[
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          menuInset,
                          spacing.xxs,
                          menuInset,
                          menuInset,
                        ),
                        child: AppButton(
                          expand: true,
                          variant: AppButtonVariant.secondary,
                          icon: footerActionIcon ?? AppIcons.add,
                          onPressed: () {
                            onClose();
                            onFooterAction?.call();
                          },
                          child: Text(footerActionLabel ?? ''),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
