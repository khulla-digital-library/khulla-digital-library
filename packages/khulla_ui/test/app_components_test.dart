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
    testWidgets('defaults to the 40px size', (tester) async {
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
      expect(box.height, 40);
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

    testWidgets('defaults hint text to the label when hintText is omitted', (
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

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.decoration!.hintText, 'ISBN');
    });

    testWidgets('keeps an explicit hintText over the label', (tester) async {
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 280,
            child: AppTextField(
              label: 'ISBN',
              hintText: '978-0-000-00000-0',
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.decoration!.hintText, '978-0-000-00000-0');
    });
  });

  group('AppQuantityField', () {
    testWidgets('steps up from the current value', (tester) async {
      final controller = TextEditingController(text: '1');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 280,
            child: AppQuantityField(
              label: 'Copies',
              controller: controller,
              decreaseTooltip: 'One fewer',
              increaseTooltip: 'One more',
              onChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.byTooltip('One more'));
      await tester.pump();
      expect(controller.text, '2');
    });

    testWidgets('does not expand past a compact control width', (tester) async {
      final controller = TextEditingController(text: '1');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _host(
          Row(
            children: [
              AppQuantityField(
                label: 'Copies',
                controller: controller,
                decreaseTooltip: 'One fewer',
                increaseTooltip: 'One more',
                onChanged: (_) {},
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      );

      final box = tester.getSize(find.byType(AppQuantityField));
      expect(box.width, lessThan(160));
    });

    testWidgets('matches AppTextField control height', (tester) async {
      final controller = TextEditingController(text: '1');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _host(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppTextField(label: 'Cost', onChanged: (_) {}),
              ),
              AppQuantityField(
                label: 'Copies',
                controller: controller,
                decreaseTooltip: 'One fewer',
                increaseTooltip: 'One more',
                onChanged: (_) {},
              ),
            ],
          ),
        ),
      );

      final cost = tester.getSize(find.byType(TextField).first);
      final copies = tester.getSize(
        find.byKey(const ValueKey('app_quantity_control')),
      );
      expect(copies.height, cost.height);
    });

    testWidgets('small size is shorter than regular', (tester) async {
      final smallController = TextEditingController(text: '1');
      final regularController = TextEditingController(text: '1');
      addTearDown(smallController.dispose);
      addTearDown(regularController.dispose);

      await tester.pumpWidget(
        _host(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppQuantityField(
                label: 'Copies',
                size: AppQuantityFieldSize.small,
                controller: smallController,
                decreaseTooltip: 'One fewer',
                increaseTooltip: 'One more',
                onChanged: (_) {},
              ),
              AppQuantityField(
                label: 'Copies',
                controller: regularController,
                decreaseTooltip: 'One fewer',
                increaseTooltip: 'One more',
                onChanged: (_) {},
              ),
            ],
          ),
        ),
      );

      final controls = tester.widgetList<ConstrainedBox>(
        find.byKey(const ValueKey('app_quantity_control')),
      );
      expect(controls.length, 2);
      expect(
        controls.first.constraints.maxHeight,
        lessThan(controls.last.constraints.maxHeight),
      );
    });

    testWidgets('does not step below min', (tester) async {
      final controller = TextEditingController(text: '1');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 280,
            child: AppQuantityField(
              label: 'Copies',
              controller: controller,
              decreaseTooltip: 'One fewer',
              increaseTooltip: 'One more',
              onChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.byTooltip('One fewer'));
      await tester.pump();
      expect(controller.text, '1');
    });
  });

  group('AppPositiveIntFormatter', () {
    test('keeps digits and strips leading zeros', () {
      const formatter = AppPositiveIntFormatter();
      TextEditingValue apply(String text) => formatter.formatEditUpdate(
        TextEditingValue.empty,
        TextEditingValue(text: text),
      );

      expect(apply('12').text, '12');
      expect(apply('012').text, '12');
      expect(apply('abc').text, '');
      expect(apply('1000').text, '');
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
                    itemIcon: (_) => AppIcons.book,
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

      final borders = find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == '_BorderContainer',
      );

      expect(borders, findsNWidgets(2));
      expect(
        tester.getSize(borders.at(0)).height,
        tester.getSize(borders.at(1)).height,
      );
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

      await tester.tap(find.byType(InputDecorator));
      await tester.pumpAndSettle();

      final panel = tester.getSize(
        find
            .descendant(
              of: find.byType(CompositedTransformFollower),
              matching: find.byType(SizedBox),
            )
            .first,
      );

      expect(panel.width, fieldWidth);
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

      final menuTop = tester.getRect(find.byType(ListView)).top;

      expect(menuTop, closeTo(fieldBottom, 1));
    });

    testWidgets('searchable menu filters items', (tester) async {
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 280,
            child: AppDropdownField<String>(
              label: 'Currency',
              value: 'USD',
              items: const ['USD', 'EUR', 'NPR', 'INR'],
              itemLabel: (value) => value,
              searchable: true,
              searchHint: 'Search currencies',
              emptySearchMessage: 'No matches',
              onChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InputDecorator));
      await tester.pumpAndSettle();

      expect(find.text('EUR'), findsOneWidget);
      expect(find.byType(AppSearchField), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'us');
      await tester.pump();

      final list = find.byType(ListView);
      expect(
        find.descendant(of: list, matching: find.text('USD')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: list, matching: find.text('EUR')),
        findsNothing,
      );
      expect(
        find.descendant(of: list, matching: find.text('NPR')),
        findsNothing,
      );
    });

    testWidgets('keeps a scrollbar thumb visible on a long menu', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 280,
            child: AppDropdownField<String>(
              label: 'Format',
              value: 'Book',
              items: const [
                'Book',
                'Journal',
                'Magazine',
                'Audiobook',
                'Video',
                'E-book',
                'Other',
              ],
              itemLabel: (value) => value,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InputDecorator));
      await tester.pumpAndSettle();

      final bar = tester.widget<Scrollbar>(find.byType(Scrollbar));
      expect(bar.thumbVisibility, isTrue);
    });

    testWidgets('invokes the footer action and closes the menu', (
      tester,
    ) async {
      var adds = 0;
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 280,
            child: AppDropdownField<String>(
              label: 'Format',
              value: 'Book',
              items: const ['Book', 'Journal'],
              itemLabel: (value) => value,
              footerActionLabel: 'Add format',
              onFooterAction: () => adds++,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InputDecorator));
      await tester.pumpAndSettle();

      expect(find.text('Add format'), findsOneWidget);

      await tester.tap(find.text('Add format'));
      await tester.pumpAndSettle();

      expect(adds, 1);
      expect(find.text('Journal'), findsNothing);
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

      final zebra = AppColors.light().tints.rowZebra;

      bool hasZebraStripe(String label) {
        final row = find.ancestor(
          of: find.text(label),
          matching: find.byType(Stack),
        );
        final boxes = tester.widgetList<ColoredBox>(
          find.descendant(of: row, matching: find.byType(ColoredBox)),
        );
        return boxes.any((box) => box.color == zebra);
      }

      expect(hasZebraStripe('one'), isFalse);
      expect(hasZebraStripe('two'), isTrue);
    });
  });

  group('AppEmptyView', () {
    testWidgets('centers in the space its parent gives it', (tester) async {
      const height = 400.0;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(800, height)),
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const Scaffold(
              body: AppEmptyView(
                icon: AppIcons.book,
                title: 'No titles yet',
                message: 'Catalogue the first work.',
              ),
            ),
          ),
        ),
      );

      final body = tester.getRect(find.byType(Scaffold));
      final title = tester.getRect(find.text('No titles yet'));
      expect(title.center.dy, closeTo(body.center.dy, 48));
    });
  });

  group('AppDialogCloseChip', () {
    testWidgets('fills with the opaque surface, not a washed container', (
      tester,
    ) async {
      await tester.pumpWidget(_host(AppDialogCloseChip(onPressed: () {})));

      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, AppTheme.light().colorScheme.surface);
      expect(decoration.color!.a, 1.0);
    });

    testWidgets('invokes onPressed when tapped', (tester) async {
      var pressed = 0;
      await tester.pumpWidget(
        _host(AppDialogCloseChip(onPressed: () => pressed++)),
      );

      await tester.tap(find.byType(AppDialogCloseChip));
      expect(pressed, 1);
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
