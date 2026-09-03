import 'package:flutter_test/flutter_test.dart';
import 'package:khulla_ui/khulla_ui.dart';

void main() {
  group('AppPagination.pageWindow', () {
    test('draws every page while the run fits', () {
      expect(AppPagination.pageWindow(1, 0), [0]);
      expect(AppPagination.pageWindow(7, 3), [0, 1, 2, 3, 4, 5, 6]);
    });

    test('keeps the first and last page at the ends', () {
      for (final current in [0, 4, 19]) {
        final window = AppPagination.pageWindow(20, current);
        expect(window.first, 0, reason: 'page 1 is always reachable');
        expect(window.last, 19, reason: 'the last page is always reachable');
      }
    });

    test('elides on the right while near the start', () {
      expect(AppPagination.pageWindow(20, 0), [0, 1, 2, 3, null, 19]);
      expect(AppPagination.pageWindow(20, 2), [0, 1, 2, 3, null, 19]);
    });

    test('elides on both sides in the middle', () {
      expect(AppPagination.pageWindow(20, 9), [0, null, 8, 9, 10, null, 19]);
    });

    test('elides on the left while near the end', () {
      expect(AppPagination.pageWindow(20, 19), [0, null, 16, 17, 18, 19]);
    });

    test('never exceeds the visible budget', () {
      for (var current = 0; current < 40; current++) {
        expect(
          AppPagination.pageWindow(40, current).length,
          lessThanOrEqualTo(7),
        );
      }
    });
  });
}
