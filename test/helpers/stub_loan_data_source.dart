import 'package:khulla/features/circulation/loan/data/loan_local_data_source.dart';
import 'package:khulla/features/circulation/loan/domain/models/loan.dart';
import 'package:khulla/features/circulation/loan/domain/models/loan_query.dart';

/// Stand-in for [LoanLocalDataSource] when a test only exercises checkout,
/// return or copy-status writes and never reads the loans table.
class StubLoanLocalDataSource implements LoanLocalDataSource {
  @override
  Future<LoanListResult> findLoans(LoanQuery query) =>
      Future.value((items: <Loan>[], totalCount: 0));

  @override
  Future<LoanListResult> findOpenLoans(LoanQuery query) =>
      Future.value((items: <Loan>[], totalCount: 0));

  @override
  Future<Loan?> findLoanById(String id) => Future.value();

  @override
  Future<Loan?> findOpenLoanByCopyId(String copyId) => Future.value();

  @override
  Future<int> countOpenLoansForMember(String memberId) => Future.value(0);

  @override
  Future<bool> memberHasOverdueLoans(String memberId) => Future.value(false);
}
