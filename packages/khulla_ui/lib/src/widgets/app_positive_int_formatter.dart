import 'package:flutter/services.dart';

/// Digits-only whole numbers, capped at [max], with leading zeros stripped.
///
/// Empty is allowed so the field can be cleared and retyped. A lone `0` is
/// kept so the caller can show a validation error instead of silently
/// rewriting the value.
class AppPositiveIntFormatter extends TextInputFormatter {
  /// Creates a formatter that accepts `''` or an integer in `0…max`.
  const AppPositiveIntFormatter({this.max = 999});

  /// Inclusive upper bound. Edits that would exceed it are rejected.
  final int max;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text;
    if (raw.isEmpty) return newValue;
    if (!RegExp(r'^\d+$').hasMatch(raw)) return oldValue;
    final parsed = int.parse(raw);
    if (parsed > max) return oldValue;
    final normalized = parsed.toString();
    if (normalized == raw) return newValue;
    return TextEditingValue(
      text: normalized,
      selection: TextSelection.collapsed(offset: normalized.length),
    );
  }
}
