import 'package:flutter_test/flutter_test.dart';
import 'package:khulla_ui/khulla_ui.dart';

final _destinations = <AppNavDestination>[
  const AppNavDestination(icon: AppIcon(AppIcons.book), label: 'First'),
  const AppNavDestination(icon: AppIcon(AppIcons.people), label: 'Second'),
];

/// `find.byIcon` only knows Material's `Icon`; the app draws `AppIcon`.
Finder _icon(AppIconSpec spec) => find.byWidgetPredicate(
  (widget) => widget is AppIcon && widget.spec == spec,
);

Widget _host(Widget child, {Size size = const Size(1400, 900)}) => MediaQuery(
  data: MediaQueryData(size: size),
  child: MaterialApp(
    theme: AppTheme.light(AppDensity.comfortable),
    home: Scaffold(
      body: Row(
        children: [
          child,
          const Expanded(child: SizedBox()),
        ],
      ),
    ),
  ),
);

void main() {
  group('AppNavRail', () {
    testWidgets('lays out collapsed with a bottom-pinned trailing slot', (
      tester,
    ) async {
      // The trailing slot wraps its child in Expanded to push it to the
      // bottom of the rail. That only works if NavigationRail puts trailing
      // inside a Flex — if a future Flutter moves it into a scroll view,
      // this test fails loudly instead of the app throwing at runtime.
      await tester.pumpWidget(
        _host(
          AppNavRail(
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            destinations: _destinations,
            leading: const AppIcon(AppIcons.library),
            trailing: const AppIcon(AppIcons.settings),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      // Collapsed, a destination is its glyph and a tooltip — the label is
      // not painted, which is the whole point of the narrow rail.
      expect(_icon(AppIcons.book), findsOneWidget);
      expect(find.text('First'), findsNothing);
      expect(
        find.byTooltip('First'),
        findsOneWidget,
        reason: 'a collapsed destination must still name itself on hover',
      );
      expect(_icon(AppIcons.settings), findsOneWidget);
    });

    testWidgets('lays out extended', (tester) async {
      await tester.pumpWidget(
        _host(
          AppNavRail(
            selectedIndex: 1,
            onDestinationSelected: (_) {},
            destinations: _destinations,
            extended: true,
            trailing: const AppIcon(AppIcons.settings),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Second'), findsOneWidget);
    });

    testWidgets('reports the tapped destination index', (tester) async {
      var selected = -1;
      await tester.pumpWidget(
        _host(
          AppNavRail(
            selectedIndex: 0,
            onDestinationSelected: (index) => selected = index,
            destinations: _destinations,
          ),
        ),
      );

      await tester.tap(_icon(AppIcons.people));
      expect(selected, 1);
    });
  });

  group('AppNavBar', () {
    testWidgets('renders every destination and reports taps', (tester) async {
      var selected = -1;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            bottomNavigationBar: AppNavBar(
              selectedIndex: 0,
              onDestinationSelected: (index) => selected = index,
              destinations: _destinations,
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);

      await tester.tap(find.text('Second'));
      expect(selected, 1);
    });
  });
}
