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

    test('keeps the scaffold and chrome surfaces distinct', () {
      // The shell paints its rail on the chrome color and the page on the
      // scaffold color. If the two collapse to the same value the rail's edge
      // disappears and the layout reads as one undifferentiated slab.
      final light = AppTheme.light(FormFactor.expanded);
      expect(
        light.scaffoldBackgroundColor,
        isNot(light.colorScheme.surface),
      );
    });
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
