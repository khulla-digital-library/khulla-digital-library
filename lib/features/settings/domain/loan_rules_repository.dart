// Copyright (c) 2026 Khulla Digital Library contributors.
// SPDX-License-Identifier: MIT

import 'package:khulla/features/settings/domain/models/loan_rules.dart';

/// Reads and writes the singleton loan-rules row.
abstract interface class LoanRulesRepository {
  Future<LoanRules?> findRules();

  Future<LoanRules> saveRules(LoanRules rules);
}
