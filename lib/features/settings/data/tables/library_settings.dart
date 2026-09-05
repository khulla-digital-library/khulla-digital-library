import 'package:drift/drift.dart';
import 'package:khulla/core/money/currency.dart';

/// The library's own record — one row, for the whole file.
///
/// A single-row table rather than a key-value bag, because these values are
/// typed and read together: the app needs the name and the currency on the
/// way to the first frame, and a bag would hand back strings to re-parse.
/// The `CHECK` constraint is what keeps "one row" true even if a future
/// import writes carelessly.
@DataClassName('LibrarySettingsRow')
class LibrarySettings extends Table {
  /// Always 1. See [customConstraints].
  IntColumn get id => integer().withDefault(const Constant(1))();

  /// What the library calls itself, shown on the shell and on printed slips.
  TextColumn get name => text().withLength(min: 1, max: 160)();

  /// The currency every fine and fee is displayed in.
  ///
  /// It changes how amounts are *rendered*, never how they are stored — a
  /// fine is an integer number of hundredths whatever this says. Switching it
  /// does not convert existing amounts, and nothing here should ever imply it
  /// does.
  TextColumn get currency => textEnum<AppCurrency>()();

  /// Which branch this installation serves, when the library has more than one name.
  TextColumn get branch => text().nullable().withLength(max: 120)();

  TextColumn get email => text().nullable().withLength(max: 254)();

  TextColumn get phone => text().nullable().withLength(max: 40)();

  TextColumn get address => text().nullable().withLength(max: 400)();

  /// Free text — not a structured weekly schedule.
  TextColumn get openingHours => text().nullable().withLength(max: 200)();

  /// Prefix for auto-generated copy barcodes — the counter follows.
  TextColumn get barcodePrefix => text().withDefault(const Constant('KH-'))();

  /// Next integer appended after [barcodePrefix] when a copy gets no barcode.
  IntColumn get barcodeNextValue => integer().withDefault(const Constant(1))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime().nullable()();

  /// The only id this table's row may take.
  static const int singletonId = 1;

  @override
  Set<Column<Object>> get primaryKey => {id};

  // The literal is written out rather than read from [singletonId], here and
  // in the column default: drift's schema export evaluates these expressions
  // on their own, where a reference back into this class is not a constant.
  @override
  List<String> get customConstraints => const ['CHECK (id = 1)'];
}
