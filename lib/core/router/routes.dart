/// Centralized route paths for the app router.
///
/// Navigate with `context.go(Routes.catalog)` — never a hard-coded string, so
/// renaming a path is a single edit and every caller moves with it.
abstract final class Routes {
  static const String root = '/';

  /// Catalogue: titles, copies, authors, subjects.
  static const String catalog = '/catalog';

  /// Circulation: checkouts, returns, reservations, overdues.
  static const String circulation = '/circulation';

  /// Members: borrower records and their standing.
  static const String members = '/members';

  /// Settings: library profile, loan rules, backup, appearance.
  static const String settings = '/settings';

  /// Whether [location] is [prefix] or nested under it.
  static bool isUnder(String location, String prefix) =>
      location == prefix || location.startsWith('$prefix/');
}
