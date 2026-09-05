import 'package:khulla/features/circulation/loan/domain/models/loan.dart';
import 'package:khulla/features/circulation/loan/domain/models/loan_query.dart';

abstract interface class LoanLocalDataSource {
  Future<LoanListResult> findLoans(LoanQuery query);

  Future<LoanListResult> findOpenLoans(LoanQuery query);

  Future<Loan?> findLoanById(String id);

  Future<Loan?> findOpenLoanByCopyId(String copyId);

  Future<int> countOpenLoansForMember(String memberId);

  Future<bool> memberHasOverdueLoans(String memberId);
}
