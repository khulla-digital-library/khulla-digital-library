import 'package:flutter/material.dart';

/// Raw color literals for the design system.
///
/// This is the **only** hex boundary in the repo. Do not import this file
/// from outside `packages/khulla_ui`. Widgets read color through
/// [ThemeData.colorScheme] or `context.appColors`.
///
/// Rebranding the product is a matter of editing this one file: every token,
/// component theme, and widget downstream resolves from these values.
abstract final class AppPalette {
  /// Khulla's deep reading-room teal, used to seed [ColorScheme].
  ///
  /// Chosen over the default Material blue because a catalogue is dense with
  /// links and state colors — a desaturated teal stays legible next to the
  /// blue of a hyperlink and the red of an overdue badge.
  static const Color brandSeed = Color(0xFF0F6E68);

  /// Deeper brand teal for emphasis and ink ripples on light surfaces.
  static const Color brandDeepLight = Color(0xFF0A4F4A);

  /// Lifted brand teal for the same role on dark surfaces.
  static const Color brandDeepDark = Color(0xFF5CCDC3);

  /// High-emphasis text that sits above [ColorScheme.onSurface].
  static const Color textHighLight = Color(0xFF14181A);

  /// High-emphasis text on dark surfaces.
  static const Color textHighDark = Color(0xFFF2F4F4);

  /// Neutral white surface for cards, sheets, and tables.
  static const Color surfaceLight = Color(0xFFFFFFFF);

  /// Cool gray muted container for chips, tiles, and raised surfaces.
  static const Color surfaceMutedLight = Color(0xFFF1F3F3);

  /// Neutral hairline / outline on light surfaces.
  static const Color outlineLight = Color(0xFFDBDEDE);

  /// Neutral dark surface.
  static const Color surfaceDark = Color(0xFF101314);

  /// Raised dark container.
  static const Color surfaceMutedDark = Color(0xFF1A1E1F);

  /// Neutral hairline / outline on dark surfaces.
  static const Color outlineDark = Color(0xFF333A3B);

  /// Warm parchment used for long-form reading surfaces.
  ///
  /// Theme-invariant: the same in light and dark so a reading pane reads as a
  /// deliberate material — a page — rather than a themed background. Dark mode
  /// dims the chrome around it, not the page itself.
  static const Color paper = Color(0xFFF6F1E7);

  /// Raised warm parchment, the light end of a [paper] gradient.
  static const Color paperElevated = Color(0xFFEFE8DA);

  /// Content on [paper] and [paperElevated].
  static const Color onPaper = Color(0xFF2B2620);

  /// Light success.
  static const Color successLight = Color(0xFF2E7D32);

  /// Content on [successLight].
  static const Color onSuccessLight = Color(0xFFFFFFFF);

  /// Light warning.
  static const Color warningLight = Color(0xFFB4780A);

  /// Content on [warningLight].
  static const Color onWarningLight = Color(0xFFFFFFFF);

  /// Light info.
  static const Color infoLight = Color(0xFF2563EB);

  /// Content on [infoLight].
  static const Color onInfoLight = Color(0xFFFFFFFF);

  /// Dark success.
  static const Color successDark = Color(0xFF81C784);

  /// Content on [successDark].
  static const Color onSuccessDark = Color(0xFF14181A);

  /// Dark warning.
  static const Color warningDark = Color(0xFFF0C14B);

  /// Content on [warningDark].
  static const Color onWarningDark = Color(0xFF14181A);

  /// Dark info.
  static const Color infoDark = Color(0xFF60A5FA);

  /// Content on [infoDark].
  static const Color onInfoDark = Color(0xFF14181A);
}
