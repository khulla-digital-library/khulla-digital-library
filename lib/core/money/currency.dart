import 'package:khulla/core/money/money_format.dart';

/// The currencies a library can be set up in.
///
/// Deliberately a short list rather than the ISO 4217 table: the currency is
/// chosen once, during first-run setup, by someone who wants to get to the
/// catalogue — not a lookup exercise through 180 codes. Adding one is a
/// constant here and a [MoneyFormat] beside it.
///
/// The enum name is what the database stores, so a case is never renamed or
/// reordered out from under a saved row.
enum AppCurrency {
  npr,
  inr,
  usd,
  eur,
  gbp;

  /// The ISO 4217 code, shown next to the currency's name in the picker.
  String get code => name.toUpperCase();

  /// How amounts are rendered in this currency: symbol, side, and grouping.
  ///
  /// What this never decides is the storage unit — every amount is an integer
  /// number of hundredths whatever the currency. See `Money`.
  MoneyFormat get format => switch (this) {
    AppCurrency.npr => MoneyFormat.nepaliRupee,
    AppCurrency.inr => MoneyFormat.indianRupee,
    AppCurrency.usd => MoneyFormat.usDollar,
    AppCurrency.eur => MoneyFormat.euro,
    AppCurrency.gbp => MoneyFormat.britishPound,
  };
}

//TODO(sawongam): Add a custom currency package later (will do later)
