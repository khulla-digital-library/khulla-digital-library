import 'package:flutter_test/flutter_test.dart';
import 'package:khulla/shared/utils/collection_page_size.dart';
import 'package:khulla_ui/khulla_ui.dart';

void main() {
  group('computeCollectionPageSize', () {
    final metrics = AppMetrics.of(AppDensity.compact);

    test('subtracts the header and rounds up row slots', () {
      // 36 header + 14 * 52 body = 764
      expect(
        computeCollectionPageSize(
          tableBodyHeight: 764,
          metrics: metrics,
        ),
        14,
      );
    });

    test('rounds up when the viewport fits a partial row', () {
      expect(
        computeCollectionPageSize(
          tableBodyHeight: 770,
          metrics: metrics,
        ),
        15,
      );
    });

    test('never goes below the minimum', () {
      expect(
        computeCollectionPageSize(
          tableBodyHeight: 10,
          metrics: metrics,
        ),
        kCollectionPageSizeMin,
      );
    });
  });
}
