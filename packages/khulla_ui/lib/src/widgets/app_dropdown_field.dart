import 'package:flutter/services.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// How many choices a menu may carry before it grows a search header.
const int kAppDropdownSearchThreshold = 8;

/// Visible rows in a scrollable menu before the list scrolls.
const int kAppDropdownVisibleRows = 5;

/// {@template app_dropdown_field}
/// A labelled select, decorated to match [AppTextField] so a form of mixed
/// controls lines up.
///
/// Generic over the value so a caller keeps its own enum or domain type all
/// the way to `onChanged` — no string round trip, no parsing back. [itemLabel]
/// is how a value becomes text, which keeps localization on the app side.
///
/// Long lists open in a capped panel: a fixed search header when
/// [searchable] is true or once [items] exceeds [searchThreshold], then a
/// scrollable list underneath. Short lists skip search and still cap height
/// when they would overflow [menuMaxHeight].
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
    this.searchable,
    this.searchHint,
    this.clearSearchTooltip,
    this.emptySearchMessage,
    this.searchThreshold = kAppDropdownSearchThreshold,
    this.itemMatchesSearch,
    this.menuMaxHeight,
    super.key,
  }) : assert(
         searchable != true || searchHint != null,
         'searchHint is required when searchable is true',
       );

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

  /// Whether the menu carries a fixed search header. Defaults to true once
  /// [items] exceeds [searchThreshold].
  final bool? searchable;

  /// Placeholder in the menu search field. Required when [searchable] is true.
  final String? searchHint;

  /// Tooltip on the search clear button.
  final String? clearSearchTooltip;

  /// Shown when search filters every item out.
  final String? emptySearchMessage;

  /// Item count above which search is offered automatically.
  final int searchThreshold;

  /// Custom filter for search. `query` is lowercased and trimmed.
  ///
  /// Defaults to a case-insensitive match on the label callback.
  final bool Function(T item, String query)? itemMatchesSearch;

  /// Cap on the scrollable list height inside the menu.
  final double? menuMaxHeight;

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
          searchable: searchable,
          searchHint: searchHint,
          clearSearchTooltip: clearSearchTooltip,
          emptySearchMessage: emptySearchMessage,
          searchThreshold: searchThreshold,
          itemMatchesSearch: itemMatchesSearch,
          menuMaxHeight: menuMaxHeight,
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
    this.searchable,
    this.searchHint,
    this.clearSearchTooltip,
    this.emptySearchMessage,
    this.searchThreshold = kAppDropdownSearchThreshold,
    this.itemMatchesSearch,
    this.menuMaxHeight,
  });

  final T? value;
  final List<T> items;
  final String Function(T value) itemLabel;
  final ValueChanged<T?> onChanged;
  final String? hintText;
  final bool enabled;
  final AppIconSpec? Function(T value)? itemIcon;
  final bool? searchable;
  final String? searchHint;
  final String? clearSearchTooltip;
  final String? emptySearchMessage;
  final int searchThreshold;
  final bool Function(T item, String query)? itemMatchesSearch;
  final double? menuMaxHeight;

  @override
  State<_DropdownFieldControl<T>> createState() =>
      _DropdownFieldControlState<T>();
}

class _DropdownFieldControlState<T> extends State<_DropdownFieldControl<T>> {
  final _layerLink = LayerLink();
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  final _fieldFocus = FocusNode();
  OverlayEntry? _overlay;
  ScrollController? _scrollController;
  String _query = '';
  double _fieldWidth = 0;

  bool get _isSearchable =>
      widget.searchable ?? widget.items.length > widget.searchThreshold;

  double _itemExtent(BuildContext context) =>
      context.appMetrics.fieldHeight - 4;

  double _menuMaxHeight(BuildContext context) =>
      widget.menuMaxHeight ?? _itemExtent(context) * kAppDropdownVisibleRows;

  List<T> get _filteredItems {
    if (!_isSearchable || _query.trim().isEmpty) return widget.items;

    final needle = _query.trim().toLowerCase();
    final matches = widget.itemMatchesSearch;
    if (matches != null) {
      return widget.items.where((item) => matches(item, needle)).toList();
    }

    return widget.items
        .where(
          (item) => widget.itemLabel(item).toLowerCase().contains(needle),
        )
        .toList();
  }

  @override
  void dispose() {
    _closeMenu();
    _searchController.dispose();
    _searchFocus.dispose();
    _fieldFocus.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    if (_overlay != null) {
      _closeMenu();
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    _query = '';
    _searchController.clear();
    _scrollController?.dispose();
    _scrollController = ScrollController(
      initialScrollOffset: _initialScrollOffset(),
    );

    _overlay = OverlayEntry(
      builder: (overlayContext) => _DropdownMenuOverlay<T>(
        layerLink: _layerLink,
        fieldWidth: _fieldWidth,
        searchFocus: _searchFocus,
        searchController: _searchController,
        scrollController: _scrollController!,
        searchable: _isSearchable,
        searchHint: widget.searchHint,
        clearSearchTooltip: widget.clearSearchTooltip,
        emptySearchMessage: widget.emptySearchMessage,
        items: _filteredItems,
        selected: widget.value,
        itemLabel: widget.itemLabel,
        itemIcon: widget.itemIcon,
        itemExtent: _itemExtent(overlayContext),
        menuMaxHeight: _menuMaxHeight(overlayContext),
        enabled: widget.enabled,
        onQueryChanged: (query) {
          _query = query;
          _scrollController?.jumpTo(0);
          _overlay?.markNeedsBuild();
        },
        onSelected: (item) {
          widget.onChanged(item);
          _closeMenu();
        },
        onClose: _closeMenu,
      ),
    );

    Overlay.of(context).insert(_overlay!);

    if (_isSearchable) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_overlay != null) _searchFocus.requestFocus();
      });
    }
  }

  double _initialScrollOffset() {
    final selected = widget.value;
    if (selected == null) return 0;

    final index = widget.items.indexOf(selected);
    if (index <= 0) return 0;

    final extent = _itemExtent(context);
    return ((index - 2) * extent).clamp(0.0, double.infinity);
  }

  void _closeMenu() {
    _overlay?.remove();
    _overlay = null;
    _scrollController?.dispose();
    _scrollController = null;
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final metrics = context.appMetrics;
    final typography = context.appTextStyles;
    final iconFor = widget.itemIcon;
    final selected = widget.value;
    final hasValue = selected != null;
    final selectedIcon = hasValue ? iconFor?.call(selected) : null;
    final enabled = widget.enabled;

    return LayoutBuilder(
      builder: (context, constraints) {
        _fieldWidth = constraints.maxWidth;

        return CompositedTransformTarget(
          link: _layerLink,
          child: Focus(
            focusNode: _fieldFocus,
            onKeyEvent: (node, event) {
              if (!enabled) return KeyEventResult.ignored;
              if (event is! KeyDownEvent) return KeyEventResult.ignored;

              if (event.logicalKey == LogicalKeyboardKey.escape) {
                if (_overlay != null) {
                  _closeMenu();
                  return KeyEventResult.handled;
                }
              }

              if (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.space) {
                _toggleMenu();
                return KeyEventResult.handled;
              }

              return KeyEventResult.ignored;
            },
            child: MouseRegion(
              cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: enabled ? _toggleMenu : null,
                child: SizedBox(
                  height: metrics.fieldHeight,
                  width: _fieldWidth,
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
                                    color: enabled
                                        ? colors.ink100
                                        : colors.ink500,
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
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DropdownMenuOverlay<T> extends StatelessWidget {
  const _DropdownMenuOverlay({
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
                                : _DropdownEmptyState(
                                    message: emptySearchMessage,
                                    itemExtent: itemExtent,
                                  ))
                          : ListView.builder(
                              controller: scrollController,
                              padding: EdgeInsets.fromLTRB(
                                menuInset,
                                0,
                                menuInset,
                                menuInset,
                              ),
                              itemExtent: itemExtent,
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];
                                final isSelected = item == selected;
                                return _DropdownMenuItem(
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

class _DropdownEmptyState extends StatelessWidget {
  const _DropdownEmptyState({
    required this.itemExtent,
    this.message,
  });

  final String? message;
  final double itemExtent;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colors = context.appColors;

    return SizedBox(
      height: itemExtent * 2,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.sm),
          child: Text(
            message ?? '',
            textAlign: TextAlign.center,
            style: context.appTextStyles.caption.copyWith(
              color: colors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _DropdownMenuItem extends StatelessWidget {
  const _DropdownMenuItem({
    required this.label,
    required this.selected,
    required this.itemRadius,
    this.icon,
    this.enabled = true,
    this.onTap,
  });

  final String label;
  final AppIconSpec? icon;
  final bool selected;
  final bool enabled;
  final double itemRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final metrics = context.appMetrics;
    final foreground = context.colorScheme.onSurface;
    final glyph = icon;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(itemRadius),
        splashFactory: NoSplash.splashFactory,
        hoverColor: enabled ? colors.tints.menuItemFocus : Colors.transparent,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.xs,
            vertical: spacing.xs + 2,
          ),
          child: Row(
            children: [
              if (glyph != null) ...[
                AppIcon(glyph, size: metrics.icon, color: colors.ink500),
                SizedBox(width: spacing.menuIconGap),
              ],
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.appTextStyles.label.copyWith(
                    color: foreground,
                  ),
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
          ),
        ),
      ),
    );
  }
}
