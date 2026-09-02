import 'package:khulla_ui/khulla_ui.dart';

/// {@template app_search_field}
/// The search input: a pill-shaped field with a leading glyph and a clear
/// button that appears once there is something to clear.
///
/// It does not debounce. Debouncing is a data-layer concern with a duration
/// that depends on how expensive the query is, so the cubit owns it — this
/// widget reports every keystroke and stays dumb.
/// {@endtemplate}
class AppSearchField extends StatefulWidget {
  /// {@macro app_search_field}
  const AppSearchField({
    required this.hintText,
    required this.onChanged,
    this.controller,
    this.clearTooltip,
    this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    super.key,
  });

  /// Placeholder describing what is searched — "Search titles, authors, ISBN".
  final String hintText;

  /// Called on every keystroke and when the field is cleared.
  final ValueChanged<String> onChanged;

  /// Controller for a query the caller also writes to — restoring a saved
  /// search, or clearing from an empty state's *Clear filters* button.
  final TextEditingController? controller;

  /// Tooltip on the clear button. Required by [AppIconButton] semantics, so
  /// pass it wherever the field can be cleared.
  final String? clearTooltip;

  /// Called when Enter is pressed.
  final ValueChanged<String>? onSubmitted;

  /// Focus node, for a screen that focuses search on open — the accession
  /// desk's default landing state.
  final FocusNode? focusNode;

  /// Whether the field takes focus on first build.
  final bool autofocus;

  /// Whether the field accepts input.
  final bool enabled;

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
    final clearLabel = widget.clearTooltip;

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
          hintText: widget.hintText,
          prefixIcon: Icon(
            Icons.search_rounded,
            size: spacing.md + 4,
            color: scheme.onSurfaceVariant,
          ),
          suffixIcon: value.text.isEmpty || clearLabel == null
              ? null
              : AppIconButton(
                  icon: Icons.close_rounded,
                  tooltip: clearLabel,
                  onPressed: _clear,
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.appRadius.bar),
            borderSide: BorderSide(color: scheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.appRadius.bar),
            borderSide: BorderSide(color: scheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.appRadius.bar),
            borderSide: BorderSide(color: scheme.primary, width: 1.5),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: spacing.xs + 2),
        ),
      ),
    );
  }
}
