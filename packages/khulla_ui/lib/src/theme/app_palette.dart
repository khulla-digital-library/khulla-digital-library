import 'package:flutter/material.dart';

/// Raw color literals for the design system.
///
/// This is the **only** hex boundary in the repo. Do not import this file
/// from outside `packages/khulla_ui`. Widgets read color through
/// [ThemeData.colorScheme] or `context.appColors`.
///
/// Rebranding the product is a matter of editing this one file: every token,
/// component theme, and widget downstream resolves from these values.
///
/// The scale is deliberately two-part. A **brand** ramp carries a single warm
/// accent — the only saturated color in the chrome — and a **neutral** ramp
/// carries everything else. A dense catalogue screen is mostly text, rules and
/// hairlines; keeping the neutrals cool and the accent alone lets a status
/// badge or a primary button read as the one thing that is different.
abstract final class AppPalette {
  // ── Brand ─────────────────────────────────────────────────────────────────

  /// Khulla's accent, used to seed [ColorScheme] and to paint the one
  /// primary action a screen is allowed.
  static const Color brandSeed = Color(0xFFF26322);

  /// Pressed / hovered brand on light surfaces.
  static const Color brandStrongLight = Color(0xFFD24E15);

  /// Deeper brand for emphasis text and ink ripples on light surfaces.
  static const Color brandDeepLight = Color(0xFFB03F10);

  /// Brand wash behind an active rail item, a brand badge, an icon chip.
  static const Color brandSoftLight = Color(0xFFFFF1E9);

  /// Lifted brand for the same roles on dark surfaces.
  static const Color brandDeepDark = Color(0xFFFF9A63);

  /// Brand wash on dark surfaces.
  static const Color brandSoftDark = Color(0xFF35211A);

  // ── Neutrals, light ───────────────────────────────────────────────────────

  /// High-emphasis text that sits above [ColorScheme.onSurface].
  static const Color textHighLight = Color(0xFF0F1319);

  /// Body text on light surfaces.
  static const Color textBodyLight = Color(0xFF262C36);

  /// Secondary and supporting text on light surfaces.
  static const Color textMutedLight = Color(0xFF6A7382);

  /// Neutral white surface for cards, sheets, tables, and the chrome.
  static const Color surfaceLight = Color(0xFFFFFFFF);

  /// A half-step off white: table headers, hovered rows, field fills.
  static const Color surfaceSubtleLight = Color(0xFFF7F8FA);

  /// The page canvas the cards sit on.
  static const Color surfaceMutedLight = Color(0xFFF0F2F5);

  /// Neutral hairline between rows, cards and sections.
  static const Color outlineLight = Color(0xFFE6E9EF);

  /// The hairline one step stronger, for a field border or a divider that
  /// has to survive next to a filled surface.
  static const Color outlineStrongLight = Color(0xFFD5DAE3);

  /// Ambient shadow on light surfaces. Cards are lifted by a whisper, not a
  /// drop shadow — depth comes from the hairline, the shadow only softens it.
  static const Color shadowLight = Color(0xFF101828);

  // ── Neutrals, dark ────────────────────────────────────────────────────────

  /// High-emphasis text on dark surfaces.
  static const Color textHighDark = Color(0xFFF6F8FA);

  /// Body text on dark surfaces.
  static const Color textBodyDark = Color(0xFFE3E7ED);

  /// Secondary text on dark surfaces.
  static const Color textMutedDark = Color(0xFF97A1B0);

  /// The dark page canvas.
  static const Color canvasDark = Color(0xFF0D0F13);

  /// Card, sheet and chrome surface on dark. Lighter than the canvas, so a
  /// card reads as raised in dark exactly as it does in light.
  static const Color surfaceDark = Color(0xFF171A20);

  /// A half-step above [surfaceDark]: table headers, hovered rows.
  static const Color surfaceSubtleDark = Color(0xFF1D212A);

  /// Raised dark container for chips and tints inside a card.
  static const Color surfaceMutedDark = Color(0xFF232833);

  /// Neutral hairline on dark surfaces.
  static const Color outlineDark = Color(0xFF2A2F3A);

  /// The dark hairline one step stronger.
  static const Color outlineStrongDark = Color(0xFF39404D);

  /// Ambient shadow on dark surfaces.
  static const Color shadowDark = Color(0xFF000000);

  // ── Reading surfaces ──────────────────────────────────────────────────────

  /// Warm parchment used for long-form reading surfaces.
  static const Color paper = Color(0xFFF7F1E6);

  /// Raised warm parchment, the light end of a [paper] gradient.
  static const Color paperElevated = Color(0xFFEFE8DA);

  /// Content on [paper] and [paperElevated].
  static const Color onPaper = Color(0xFF2B2620);

  // ── Status, light ─────────────────────────────────────────────────────────

  /// Light success.
  static const Color successLight = Color(0xFF067647);

  /// Content on [successLight].
  static const Color onSuccessLight = Color(0xFFFFFFFF);

  /// Success wash behind a badge or a tile glyph.
  static const Color successSoftLight = Color(0xFFE7F7EF);

  /// Light warning.
  static const Color warningLight = Color(0xFFB54708);

  /// Content on [warningLight].
  static const Color onWarningLight = Color(0xFFFFFFFF);

  /// Warning wash.
  static const Color warningSoftLight = Color(0xFFFDF3E6);

  /// Light info.
  static const Color infoLight = Color(0xFF175CD3);

  /// Content on [infoLight].
  static const Color onInfoLight = Color(0xFFFFFFFF);

  /// Info wash.
  static const Color infoSoftLight = Color(0xFFEAF2FE);

  /// Light danger — overdue, destructive, lost.
  static const Color dangerLight = Color(0xFFC0332B);

  /// Content on [dangerLight].
  static const Color onDangerLight = Color(0xFFFFFFFF);

  /// Danger wash.
  static const Color dangerSoftLight = Color(0xFFFDECEA);

  /// Neutral wash for an inert badge or a muted tile glyph.
  static const Color neutralSoftLight = Color(0xFFF0F2F5);

  // ── Status, dark ──────────────────────────────────────────────────────────

  /// Dark success.
  static const Color successDark = Color(0xFF5FD09A);

  /// Content on [successDark].
  static const Color onSuccessDark = Color(0xFF0D0F13);

  /// Success wash on dark.
  static const Color successSoftDark = Color(0xFF12291F);

  /// Dark warning.
  static const Color warningDark = Color(0xFFF3B75B);

  /// Content on [warningDark].
  static const Color onWarningDark = Color(0xFF0D0F13);

  /// Warning wash on dark.
  static const Color warningSoftDark = Color(0xFF2E2317);

  /// Dark info.
  static const Color infoDark = Color(0xFF7FB0F7);

  /// Content on [infoDark].
  static const Color onInfoDark = Color(0xFF0D0F13);

  /// Info wash on dark.
  static const Color infoSoftDark = Color(0xFF17222F);

  /// Dark danger.
  static const Color dangerDark = Color(0xFFF08279);

  /// Content on [dangerDark].
  static const Color onDangerDark = Color(0xFF0D0F13);

  /// Danger wash on dark.
  static const Color dangerSoftDark = Color(0xFF2E1B19);

  /// Neutral wash on dark.
  static const Color neutralSoftDark = Color(0xFF232833);
}
