import 'package:flutter_test/flutter_test.dart';
import 'package:khulla_ui/khulla_ui.dart';

Widget _host(Widget child, {Size size = const Size(1400, 900)}) => MediaQuery(
  data: MediaQueryData(size: size),
  child: MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  group('AppButton', () {
    testWidgets('defaults to the 36px size', (tester) async {
      await tester.pumpWidget(
        _host(AppButton(onPressed: () {}, child: const Text('Add title'))),
      );

      final box = tester.getSize(
        find
            .ancestor(
              of: find.text('Add title'),
              matching: find.byType(AnimatedContainer),
            )
            .first,
      );
      expect(box.height, 36);
    });

    testWidgets('swaps the label for a spinner while loading', (tester) async {
      await tester.pumpWidget(
        _host(
          AppButton(
            onPressed: () {},
            isLoading: true,
            child: const Text('Save'),
          ),
        ),
      );

      expect(find.text('Save'), findsNothing);
      expect(find.byType(AppSpinner), findsOneWidget);
    });

    testWidgets('swallows presses while loading', (tester) async {
      var presses = 0;
      await tester.pumpWidget(
        _host(
          AppButton(
            onPressed: () => presses++,
            isLoading: true,
            child: const Text('Save'),
          ),
        ),
      );

      await tester.tap(find.byType(AppButton));
      expect(presses, 0);
    });
  });

  group('AppTextField', () {
    testWidgets('nudges its content on focus instead of drawing a ring', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 280,
            child: AppTextField(label: 'ISBN', onChanged: (_) {}),
          ),
        ),
      );

      double contentStart() {
        final field = tester.widget<TextField>(find.byType(TextField));
        final padding = field.decoration!.contentPadding ?? EdgeInsets.zero;
        return padding.resolve(TextDirection.ltr).left;
      }

      final resting = contentStart();
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      final focused = contentStart();

      expect(
        focused - resting,
        2,
        reason: 'focus is signalled by a 2px content shift',
      );
    });

    testWidgets('shows the error under the field, not on its border', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 280,
            child: AppTextField(
              label: 'ISBN',
              errorText: 'Already taken',
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(AppFieldError), findsOneWidget);
      expect(find.text('Already taken'), findsOneWidget);
    });
  });

  group('AppDropdownField', () {
    testWidgets('matches AppTextField control height', (tester) async {
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 400,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppDropdownField<String>(
                    label: 'Format',
                    value: 'Book',
                    items: const ['Book', 'Journal'],
                    itemLabel: (value) => value,
                    onChanged: (_) {},
                  ),
                ),
                Expanded(
                  child: AppTextField(
                    label: 'Language',
                    initialValue: 'English',
                    onChanged: (_) {},
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      final dropdownHeight = tester
          .getSize(find.byType(InputDecorator).first)
          .height;
      final textFieldHeight = tester
          .getSize(find.byType(TextFormField).first)
          .height;

      expect(dropdownHeight, textFieldHeight);
    });

    testWidgets('opens a menu as wide as the field', (tester) async {
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 280,
            child: AppDropdownField<String>(
              label: 'Format',
              value: 'Book',
              items: const ['Book', 'Journal'],
              itemLabel: (value) => value,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final fieldWidth = tester.getSize(find.byType(InputDecorator)).width;
      const menuInset = 4.0;

      await tester.tap(find.byType(InputDecorator));
      await tester.pumpAndSettle();

      expect(
        tester.getSize(find.byType(MenuItemButton).first).width,
        fieldWidth - menuInset * 2,
      );
    });

    testWidgets('menu opens flush against the field', (tester) async {
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 280,
            child: AppDropdownField<String>(
              label: 'Format',
              value: 'Book',
              items: const ['Book', 'Journal'],
              itemLabel: (value) => value,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final fieldBottom = tester.getRect(find.byType(InputDecorator)).bottom;

      await tester.tap(find.byType(InputDecorator));
      await tester.pumpAndSettle();

      final menuTop = tester.getRect(find.byType(MenuItemButton).first).top;

      expect(menuTop, fieldBottom);
    });
  });

  group('AppTable', () {
    testWidgets('stripes every other row and leaves the first bare', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 600,
            child: AppTable<String>(
              items: const ['one', 'two'],
              columns: [
                AppTableColumn<String>(
                  id: 'value',
                  label: 'Value',
                  cellBuilder: (context, item) => Text(item),
                ),
              ],
            ),
          ),
        ),
      );

      Color? fillOf(String label) {
        final container = tester.widget<AnimatedContainer>(
          find
              .ancestor(
                of: find.text(label),
                matching: find.byType(AnimatedContainer),
              )
              .first,
        );
        return (container.decoration! as BoxDecoration).color;
      }

      expect(fillOf('one'), Colors.transparent);
      expect(fillOf('two'), isNot(Colors.transparent));
    });
  });

  testWidgets('AppDesignGallery builds every section without throwing', (
    tester,
  ) async {
    // Pumped by hand rather than settled: the states section runs the
    // skeleton pulse and the spinner, both of which loop forever.
    await tester.pumpWidget(_host(const AppDesignGallery()));
    await tester.pump(const Duration(milliseconds: 300));

    for (final section in ['Controls', 'Surfaces', 'Data', 'States']) {
      await tester.tap(find.text(section));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    }
  });
}
