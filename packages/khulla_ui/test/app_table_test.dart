import 'package:flutter_test/flutter_test.dart';
import 'package:khulla_ui/khulla_ui.dart';

void main() {
  group('FormFactor', () {
    test('isAtLeast compares narrowest-first', () {
      expect(FormFactor.large.isAtLeast(FormFactor.expanded), isTrue);
      expect(FormFactor.compact.isAtLeast(FormFactor.medium), isFalse);
      expect(FormFactor.medium.isAtLeast(FormFactor.medium), isTrue);
    });

    test('columns follow the window class', () {
      expect(FormFactor.compact.columns(), 1);
      expect(FormFactor.large.columns(), 4);
      expect(FormFactor.expanded.columns(expanded: 2), 2);
    });
  });

  group('AppTableSort', () {
    test('clicking the sorted column flips direction', () {
      const sort = AppTableSort(columnId: 'title');
      expect(
        sort.toggled('title'),
        const AppTableSort(columnId: 'title', ascending: false),
      );
    });

    test('clicking another column starts ascending', () {
      const sort = AppTableSort(columnId: 'title', ascending: false);
      expect(sort.toggled('dueDate'), const AppTableSort(columnId: 'dueDate'));
    });
  });

  group('AppTableColumn', () {
    final columns = [
      AppTableColumn<String>(
        id: 'title',
        label: 'Title',
        cellBuilder: (_, item) => Text(item),
      ),
      AppTableColumn<String>(
        id: 'shelf',
        label: 'Shelf',
        showFrom: FormFactor.expanded,
        cellBuilder: (_, item) => Text(item),
      ),
    ];

    test('drops columns the window cannot fit', () {
      expect(
        AppTableColumn.visible(columns, FormFactor.compact).map((c) => c.id),
        ['title'],
      );
      expect(
        AppTableColumn.visible(columns, FormFactor.large).map((c) => c.id),
        ['title', 'shelf'],
      );
    });
  });
}
