/// How this installation describes itself.
///
/// One record, not a table: a Khulla install is one library. A branch field
/// is here rather than a branches list for the same reason — a second branch
/// runs its own copy of the app with its own catalogue file.
class LibraryProfile {
  const LibraryProfile({
    required this.name,
    required this.branch,
    required this.email,
    required this.phone,
    required this.address,
    required this.openingHours,
    required this.currencyCode,
    required this.currencySymbol,
  });

  final String name;
  final String branch;
  final String email;
  final String phone;
  final String address;
  final String openingHours;

  /// The currency every amount in the app is shown in. `MoneyFormat.current`
  /// is set from this once in `bootstrap` — the storage unit itself never
  /// changes, only how it is displayed.
  final String currencyCode;

  final String currencySymbol;
}
