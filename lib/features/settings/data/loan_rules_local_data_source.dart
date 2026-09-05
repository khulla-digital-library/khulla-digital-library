import 'package:khulla/features/settings/domain/models/loan_rules.dart'
    as domain;

/// Reads and writes the singleton loan-rules row.
abstract interface class LoanRulesLocalDataSource {
  Future<domain.LoanRules?> findRules();

  Future<domain.LoanRules> saveRules(domain.LoanRules rules);
}
