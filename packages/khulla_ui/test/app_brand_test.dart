import 'package:flutter_test/flutter_test.dart';
import 'package:khulla_ui/khulla_ui.dart';

Widget _host(Widget child) => MediaQuery(
  data: const MediaQueryData(size: Size(1400, 900)),
  child: MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  group('AppBrand', () {
    test('the teal preset keeps the hand-tuned ramp', () {
      // The shipped look must not change just because the brand became
      // configurable, so teal is the constants and not a derivation.
      expect(AppBrandTheme.teal.brand, AppBrand.teal);
      expect(
        AppBrandTheme.teal.brand,
        isNot(
          AppBrand.fromSeed(
            AppBrandTheme.teal.seed,
          ),
        ),
      );
    });

    test('fromSeed keeps the seed and its hue across the ramp', () {
      final brand = AppBrand.fromSeed(AppBrandTheme.violet.seed);
      final hue = HSVColor.fromColor(brand.seed).hue;

      expect(brand.seed, AppBrandTheme.violet.seed);
      for (final derived in [brand.accent, brand.deep, brand.strong]) {
        expect(HSVColor.fromColor(derived).hue, closeTo(hue, 1));
      }
    });

    test('fromSeed darkens for emphasis and lightens for the tint source', () {
      final brand = AppBrand.fromSeed(AppBrandTheme.blue.seed);
      final seed = brand.seed.computeLuminance();

      expect(brand.deep.computeLuminance(), lessThan(seed));
      expect(brand.strong.computeLuminance(), lessThan(seed));
      expect(brand.accent.computeLuminance(), greaterThan(seed));
      expect(
        brand.tint.computeLuminance(),
        greaterThan(brand.accent.computeLuminance()),
      );
    });

    test('fromSeed flips the ink on the fill by luminance', () {
      // White text on a pale yellow primary is the failure this prevents.
      final pale = AppBrand.fromSeed(const Color(0xFFFFE066));
      final deep = AppBrand.fromSeed(const Color(0xFF102A43));

      expect(pale.onBrand.computeLuminance(), lessThan(0.5));
      expect(deep.onBrand.computeLuminance(), greaterThan(0.5));
    });

    test('every preset produces a distinct primary', () {
      final seeds = AppBrandTheme.values.map((brand) => brand.seed).toSet();
      expect(seeds, hasLength(AppBrandTheme.values.length));
    });

    test('a theme is colored by the brand it is given', () {
      final theme = AppTheme.light(
        AppDensity.comfortable,
        AppBrandTheme.rose.brand,
      );

      expect(theme.colorScheme.primary, AppBrandTheme.rose.seed);
      expect(theme.extension<AppColors>()!.brand, AppBrandTheme.rose.seed);
      // Status colors carry meaning and must survive a brand change.
      expect(
        theme.extension<AppColors>()!.danger,
        AppTheme.light().extension<AppColors>()!.danger,
      );
    });
  });

  group('AppColorPicker', () {
    testWidgets('emits the color typed into the hex field', (tester) async {
      Color? emitted;
      await tester.pumpWidget(
        _host(
          AppColorPicker(
            value: AppBrandTheme.teal.seed,
            hexLabel: 'Hex',
            onChanged: (color) => emitted = color,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '4338CA');
      await tester.pump();

      expect(emitted, const Color(0xFF4338CA));
    });

    testWidgets('ignores a half-typed hex', (tester) async {
      var emissions = 0;
      await tester.pumpWidget(
        _host(
          AppColorPicker(
            value: AppBrandTheme.teal.seed,
            hexLabel: 'Hex',
            onChanged: (_) => emissions++,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '433');
      await tester.pump();

      expect(emissions, 0);
    });

    testWidgets('dragging the pad emits without changing the hue', (
      tester,
    ) async {
      Color? emitted;
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 320,
            child: AppColorPicker(
              value: AppBrandTheme.blue.seed,
              hexLabel: 'Hex',
              onChanged: (color) => emitted = color,
            ),
          ),
        ),
      );

      // Mid-pad: at the white and black edges the color quantizes to 8-bit
      // RGB and the recovered hue is meaningless, which is exactly why the
      // picker holds the hue itself rather than re-deriving it.
      final pad = tester.getRect(find.byType(ClipRRect).first);
      await tester.tapAt(pad.center);
      await tester.pump();

      expect(emitted, isNotNull);
      expect(
        HSVColor.fromColor(emitted!).hue,
        closeTo(HSVColor.fromColor(AppBrandTheme.blue.seed).hue, 2),
      );
    });
  });
}
