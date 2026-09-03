import 'package:khulla/core/money/money.dart';
import 'package:khulla/features/settings/presentation/placeholder/library_profile.dart';
import 'package:khulla/features/settings/presentation/placeholder/loan_rules.dart';

/// Stand-in configuration until a `settings` table exists.
///
/// Everything here is what a fresh install would ship with, so the forms open
/// on plausible values rather than empty fields — which is also how the real
/// screens will behave once the defaults live in a migration.
const LibraryProfile placeholderLibraryProfile = LibraryProfile(
  name: 'Khulla Community Library',
  branch: 'Main branch',
  email: 'desk@khulla.example.org',
  phone: '+977 1 555 0142',
  address: 'Jhamsikhel, Lalitpur, Nepal',
  openingHours: 'Sun – Fri, 10:00 – 18:00',
  currencyCode: 'NPR',
  currencySymbol: 'Rs',
);

/// The lending rules a new loan is created under.
final LoanRules placeholderLoanRules = LoanRules(
  loanPeriodDays: 14,
  renewalLimit: 2,
  borrowingLimit: 5,
  finePerDay: Money.major(5),
  graceDays: 1,
  maximumFine: Money.major(500),
  holdShelfDays: 7,
  blockOverdueBorrowers: true,
  autoRenewWhenUnreserved: false,
);

/// What the About card reports about this install.
const String placeholderVersion = '0.1.0 (dev)';

/// The licence the project ships under.
const String placeholderLicence = 'AGPL-3.0';

/// Where the catalogue file lives on this machine.
const String placeholderStoragePath = 'Application support · khulla.db';

/// When a backup was last written. Null on an install that has never taken
/// one, which is the case the backup screen has copy for.
const String placeholderLastBackup = '28 Aug 2026, 18:04';

/// How large the catalogue file is.
const String placeholderDatabaseSize = '14.2 MB';
