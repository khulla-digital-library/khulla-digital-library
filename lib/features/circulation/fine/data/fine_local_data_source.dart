import 'package:khulla/core/money/money.dart';
import 'package:khulla/features/circulation/fine/domain/models/fine.dart';
import 'package:khulla/features/circulation/fine/domain/models/fine_query.dart';

abstract interface class FineLocalDataSource {
  Future<FineListResult> findFines(FineQuery query);

  Future<Fine?> findFineById(String id);

  Future<Money> outstandingForMember(String memberId);
}
