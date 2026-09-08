import 'package:flutter_test/flutter_test.dart';
import 'package:khulla/shared/utils/collection_page_size.dart';
import 'package:khulla_ui/khulla_ui.dart';

void main() {
  group('computeCollectionPageSize', () {
    final metrics = AppMetrics.of(AppDensity.compact);

    test('subtracts the header and divides by row height', () {
      // 48 header + 11 * 65 body = 763
      expect(
        computeCollectionPageSize(
          tableBodyHeight: 763,
          metrics: metrics,
        ),
        11,
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
