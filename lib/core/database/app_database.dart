import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:khulla/core/config/app_config.dart';
import 'package:khulla/core/database/app_database.steps.dart';
import 'package:khulla/core/database/connection.dart';
import 'package:khulla/core/database/converters/date_only_converter.dart';
import 'package:khulla/core/database/converters/money_converter.dart';
import 'package:khulla/core/error/app_exception.dart';
import 'package:khulla/core/logging/app_logger.dart';
import 'package:khulla/core/money/currency.dart';
import 'package:khulla/core/money/money.dart';
import 'package:khulla/features/catalog/copy/data/tables/copies.dart';
import 'package:khulla/features/catalog/shared/domain/copy_condition.dart';
import 'package:khulla/features/catalog/shared/domain/copy_status.dart';
import 'package:khulla/features/catalog/title/data/tables/title_formats.dart';
import 'package:khulla/features/catalog/title/data/tables/titles.dart';
import 'package:khulla/features/circulation/fine/data/tables/fines.dart';
import 'package:khulla/features/circulation/loan/data/tables/loans.dart';
import 'package:khulla/features/circulation/reservation/data/tables/reservations.dart';
import 'package:khulla/features/circulation/shared/domain/fine_reason.dart';
import 'package:khulla/features/circulation/shared/domain/reservation_status.dart';
import 'package:khulla/features/members/data/tables/member_types.dart';
import 'package:khulla/features/members/data/tables/members.dart';
import 'package:khulla/features/settings/data/tables/library_settings.dart';
import 'package:khulla/features/settings/data/tables/loan_rules.dart';
import 'package:khulla/features/users/data/tables/staff.dart';
// The enums the tables store through `textEnum` are named in the generated
// part file, which cannot carry imports of its own — they have to be visible
// from here even though nothing in this file mentions them.
import 'package:khulla/features/users/domain/user_role.dart';
import 'package:khulla/features/users/domain/user_status.dart';

part 'app_database.g.dart';

/// Owns the single SQLite connection for the app's lifetime.
@lazySingleton
@DriftDatabase(
  tables: [
    LibrarySettings,
    Staff,
    LoanRules,
    TitleFormats,
    MemberTypes,
    Titles,
    Copies,
    Members,
    Loans,
    Fines,
    Reservations,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(AppConfig config) : super(openDatabaseConnection(config));

  @visibleForTesting
  AppDatabase.connect(super.e);

  static const String _source = 'AppDatabase';

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: _createSchema,
    onUpgrade: _upgradeSchema,
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> warmUp() => customSelect('SELECT 1').get();

  @disposeMethod
  Future<void> dispose() => close();

  Future<void> _createSchema(Migrator m) async {
    AppLogger.info(
      'Creating catalogue schema v$schemaVersion',
      source: _source,
    );
    await m.createAll();
  }

  Future<void> _upgradeSchema(Migrator m, int from, int to) async {
    if (from > to) {
      AppLogger.error(
        'Catalogue schema v$from is newer than this build expects (v$to). '
        'Refusing to open so no data is lost.',
        source: _source,
        fatal: true,
      );
      throw const DatabaseUnavailableException(
        'This library file was created by a newer version of Khulla Digital Library.',
      );
    }

    AppLogger.info('Migrating catalogue from v$from to v$to', source: _source);

    await stepByStep(
      from1To2: (m, schema) async {
        await m.createTable(schema.librarySettings);
        await m.createTable(schema.staff);
      },
      from2To3: (m, schema) async {
        await m.createTable(schema.loanRules);
        await m.createTable(schema.titleFormats);
        await m.createTable(schema.memberTypes);
        await m.addColumn(
          schema.librarySettings,
          schema.librarySettings.branch,
        );
        await m.addColumn(schema.librarySettings, schema.librarySettings.email);
        await m.addColumn(schema.librarySettings, schema.librarySettings.phone);
        await m.addColumn(
          schema.librarySettings,
          schema.librarySettings.address,
        );
        await m.addColumn(
          schema.librarySettings,
          schema.librarySettings.openingHours,
        );
        await m.addColumn(
          schema.librarySettings,
          schema.librarySettings.barcodePrefix,
        );
        await m.addColumn(
          schema.librarySettings,
          schema.librarySettings.barcodeNextValue,
        );
        await m.addColumn(
          schema.librarySettings,
          schema.librarySettings.updatedAt,
        );
      },
      from3To4: (m, schema) async {
        // v3 snapshot recorded inline column checks on loan_rules that the
        // current table no longer declares — recreate so v4 matches the snapshot.
        await m.deleteTable('loan_rules');
        await m.createTable(schema.loanRules);
        await m.createTable(schema.titles);
        await m.createTable(schema.copies);
        await m.createIndex(
          Index(
            'titles_search',
            'CREATE INDEX titles_search ON titles (search_text)',
          ),
        );
        await m.createIndex(
          Index(
            'titles_format',
            'CREATE INDEX titles_format ON titles (format_id)',
          ),
        );
        await m.createIndex(
          Index('titles_sort', 'CREATE INDEX titles_sort ON titles (title)'),
        );
        await m.createIndex(
          Index(
            'titles_isbn',
            'CREATE INDEX titles_isbn ON titles (isbn) WHERE isbn IS NOT NULL',
          ),
        );
        await m.createIndex(
          Index(
            'copies_barcode',
            'CREATE UNIQUE INDEX copies_barcode ON copies (barcode)',
          ),
        );
        await m.createIndex(
          Index(
            'copies_title',
            'CREATE INDEX copies_title ON copies (title_id)',
          ),
        );
        await m.createIndex(
          Index(
            'copies_status',
            'CREATE INDEX copies_status ON copies (status) WHERE archived_at IS NULL',
          ),
        );
      },
      from4To5: (m, schema) async {
        await m.createTable(schema.members);
        await m.createIndex(
          Index(
            'members_card',
            'CREATE UNIQUE INDEX members_card ON members (card_number)',
          ),
        );
        await m.createIndex(
          Index(
            'members_search',
            'CREATE INDEX members_search ON members (search_text)',
          ),
        );
        await m.createIndex(
          Index(
            'members_type',
            'CREATE INDEX members_type ON members (member_type_id)',
          ),
        );
        await m.createIndex(
          Index(
            'members_expiry',
            'CREATE INDEX members_expiry ON members (expires_at) WHERE archived_at IS NULL',
          ),
        );
      },
      from5To6: (m, schema) async {
        await m.createTable(schema.loans);
        await m.createTable(schema.fines);
        await m.createTable(schema.reservations);
        await m.createIndex(
          Index(
            'loans_one_open_per_copy',
            'CREATE UNIQUE INDEX loans_one_open_per_copy ON loans (copy_id) WHERE returned_at IS NULL',
          ),
        );
        await m.createIndex(
          Index(
            'loans_open_by_member',
            'CREATE INDEX loans_open_by_member ON loans (member_id) WHERE returned_at IS NULL',
          ),
        );
        await m.createIndex(
          Index(
            'loans_due',
            'CREATE INDEX loans_due ON loans (due_at) WHERE returned_at IS NULL',
          ),
        );
        await m.createIndex(
          Index(
            'loans_member_history',
            'CREATE INDEX loans_member_history ON loans (member_id, checked_out_at DESC)',
          ),
        );
        await m.createIndex(
          Index(
            'loans_copy_history',
            'CREATE INDEX loans_copy_history ON loans (copy_id, checked_out_at DESC)',
          ),
        );
        await m.createIndex(
          Index(
            'fines_outstanding',
            'CREATE INDEX fines_outstanding ON fines (member_id) WHERE paid + waived < assessed',
          ),
        );
        await m.createIndex(
          Index(
            'reservations_one_active_per_member_title',
            'CREATE UNIQUE INDEX reservations_one_active_per_member_title '
                'ON reservations (title_id, member_id) WHERE closed_at IS NULL',
          ),
        );
        await m.createIndex(
          Index(
            'reservations_queue',
            'CREATE INDEX reservations_queue ON reservations (title_id, placed_at) '
                'WHERE closed_at IS NULL',
          ),
        );
      },
    )(m, from, to);
  }
}
