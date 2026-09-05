import 'package:khulla/features/settings/domain/models/loan_rules.dart';

/// Reads and writes the singleton loan-rules row.
abstract interface class LoanRulesRepository {
  Future<LoanRules?> findRules();

  Future<LoanRules> saveRules(LoanRules rules);
}
