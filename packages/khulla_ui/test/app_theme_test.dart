import 'package:flutter_test/flutter_test.dart';
import 'package:khulla_ui/khulla_ui.dart';

void main() {
  group('AppTheme', () {
    for (final brightness in Brightness.values) {
      for (final formFactor in FormFactor.values) {
        test('carries every token extension in $brightness/$formFactor', () {
          final theme = brightness == Brightness.light
              ? AppTheme.light(formFactor)
              : AppTheme.dark(formFactor);

          // context.appColors and friends assert these are present. A theme
          // built without one throws deep inside an unrelated widget's build,
          // which is a miserable way to find out.
          expect(theme.extension<AppColors>(), isNotNull);
          expect(theme.extension<AppSpacing>(), isNotNull);
          expect(theme.extension<AppRadius>(), isNotNull);
          expect(theme.extension<AppBreakpoints>(), isNotNull);
          expect(theme.extension<AppTextStyles>(), isNotNull);
        });
      }
    }

    test('uses the mobile type ramp only for compact', () {
      final compact = AppTheme.light().textTheme.bodyMedium?.fontSize;
      final expanded = AppTheme.light(
        FormFactor.expanded,
      ).textTheme.bodyMedium?.fontSize;

      expect(compact, isNotNull);
      expect(expanded, isNotNull);
      expect(
        AppTheme.light(FormFactor.medium).textTheme.bodyMedium?.fontSize,
        expanded,
        reason: 'medium and expanded share the desktop ramp',
      );
    });

    test(
      'separates canvas from card by hairline in light, by fill in dark',
      () {
        // Light: depth comes from the hairline, so the page and a card sit on
        // the same white and only the 1px border tells them apart. Dark: a
        // hairline on near-black is too weak to carry an edge on its own, so
        // the canvas drops below the card instead. Both are deliberate; the
        // thing neither may do is leave the two indistinguishable.
        final light = AppTheme.light(FormFactor.expanded);
        expect(light.scaffoldBackgroundColor, light.colorScheme.surface);
        expect(
          light.extension<AppColors>()!.hairline,
          isNot(light.colorScheme.surface),
          reason: 'the hairline has to be visible against the canvas',
        );

        final dark = AppTheme.dark(FormFactor.expanded);
        expect(dark.scaffoldBackgroundColor, isNot(dark.colorScheme.surface));
      },
    );
  });

  group('AppBreakpoints', () {
    const breakpoints = AppBreakpoints();

    test('maps widths onto the four window size classes', () {
      expect(breakpoints.formFactorFor(360), FormFactor.compact);
      expect(breakpoints.formFactorFor(599), FormFactor.compact);
      expect(breakpoints.formFactorFor(600), FormFactor.medium);
      expect(breakpoints.formFactorFor(839), FormFactor.medium);
      expect(breakpoints.formFactorFor(840), FormFactor.expanded);
      expect(breakpoints.formFactorFor(1199), FormFactor.expanded);
      expect(breakpoints.formFactorFor(1200), FormFactor.large);
      expect(breakpoints.formFactorFor(2560), FormFactor.large);
    });

    test('puts navigation in a rail everywhere but compact', () {
      expect(FormFactor.compact.usesNavigationRail, isFalse);
      expect(FormFactor.medium.usesNavigationRail, isTrue);
      expect(FormFactor.expanded.usesNavigationRail, isTrue);
      expect(FormFactor.large.usesNavigationRail, isTrue);
    });

    test('extends the rail only at the largest class', () {
      expect(
        FormFactor.values.where((f) => f.usesExtendedRail),
        [FormFactor.large],
      );
    });
  });
}
