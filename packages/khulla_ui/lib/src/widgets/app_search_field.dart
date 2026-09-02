import 'package:khulla_ui/khulla_ui.dart';

/// The search input above a collection, and the global one in the top bar.
///
/// It does **not** debounce. The cubit owns that, because only the cubit
/// knows whether the query costs a `LIKE` over ten thousand rows or a filter
/// over a list already in memory.
///
/// The field is filled rather than outlined: on a page made of white cards, a
/// filled control is the one that reads as "type here" without adding another
/// hairline to a screen that already has forty.
class AppSearchField extends StatefulWidget {
  const AppSearchField({
    required this.hintText,
    required this.onChanged,
    this.controller,
    this.clearTooltip,
    this.onSubmitted,
    this.focusNode,
    this.trailing,
    this.autofocus = false,
    this.enabled = true,
    this.dense = false,
    super.key,
  });

  /// Placeholder copy — say what is searched, not "Search".
  final String hintText;

  /// Called on every keystroke.
  final ValueChanged<String> onChanged;

  /// Supply one to drive the field from outside; otherwise it owns its own.
  final TextEditingController? controller;

  /// Tooltip for the clear button. Null hides the button entirely.
  final String? clearTooltip;

  /// Called when the user commits the query.
  final ValueChanged<String>? onSubmitted;

  /// External focus, for a screen that focuses search on open.
  final FocusNode? focusNode;

  /// A control pinned inside the trailing edge — a scope switch, a filter
  /// glyph. Replaced by the clear button while the field has text.
  final Widget? trailing;

  /// Whether to take focus on mount.
  final bool autofocus;

  /// Whether the field accepts input.
  final bool enabled;

  /// Tightens the field to sit inside a toolbar row.
  final bool dense;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  TextEditingController? _ownedController;
  late TextEditingController _controller = _resolveController();

  TextEditingController _resolveController() {
    final supplied = widget.controller;
    if (supplied != null) return supplied;
    return _ownedController = TextEditingController();
  }

  @override
  void didUpdateWidget(covariant AppSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _ownedController?.dispose();
      _ownedController = null;
      _controller = _resolveController();
    }
  }

  @override
  void dispose() {
    _ownedController?.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final colors = context.appColors;
    final clearLabel = widget.clearTooltip;
    final radius = BorderRadius.circular(context.appRadius.field);

    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: color, width: width),
        );

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (context, value, _) => TextField(
        controller: _controller,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        enabled: widget.enabled,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        textInputAction: TextInputAction.search,
        style: context.textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
        decoration: InputDecoration(
          isDense: widget.dense,
          hintText: widget.hintText,
          filled: true,
          fillColor: scheme.surfaceContainerLow,
          prefixIcon: Icon(
            Icons.search_rounded,
            size: spacing.md + 2,
            color: colors.textMuted,
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: spacing.xlg + spacing.xxs,
            minHeight: spacing.xlg,
          ),
          suffixIcon: value.text.isNotEmpty && clearLabel != null
              ? AppIconButton(
                  icon: Icons.close_rounded,
                  tooltip: clearLabel,
                  onPressed: _clear,
                )
              : widget.trailing,
          border: border(colors.hairline),
          enabledBorder: border(colors.hairline),
          focusedBorder: border(scheme.primary, 1.5),
          contentPadding: EdgeInsets.symmetric(
            vertical: widget.dense ? spacing.xs + 2 : spacing.sm,
          ),
        ),
      ),
    );
  }
}
