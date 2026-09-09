import 'package:intl/intl.dart';

/// How calendar dates are shown on screen.
///
/// Amounts go through money formatting; dates had no equivalent until
/// persistence landed.
abstract final class AppDateFormat {
  static final DateFormat display = DateFormat('d MMM y');

  static String format(DateTime date) => display.format(date);
}
