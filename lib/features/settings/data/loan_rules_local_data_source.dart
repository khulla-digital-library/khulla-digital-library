// Copyright (c) 2026 Khulla Digital Library contributors.
// SPDX-License-Identifier: MIT

import 'package:khulla/features/settings/domain/models/loan_rules.dart'
    as domain;

/// Reads and writes the singleton loan-rules row.
abstract interface class LoanRulesLocalDataSource {
  Future<domain.LoanRules?> findRules();

  Future<domain.LoanRules> saveRules(domain.LoanRules rules);
}
