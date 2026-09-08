# Khulla Digital Library — Feature Status & Roadmap

> Generated 2026-09-06 from a full tree scan on branch `feat/features-integraiton`
> (HEAD `4de2375`). Schema v10 (`lib/core/database/app_database.dart:64`).
> Method: read `lib/`, `packages/khulla_ui/`, `test/`, `docs/`, `drift_schemas/`,
> `lib/l10n/arb/app_en.arb` (853 keys), `lib/core/router/routes.dart`,
> `lib/app/router/app_router.dart`, plus `git log --oneline -30` and
> `rg showNotWiredToast|TODO|placeholder`. A screen counts as **Done** only if
> it is routed, reads/writes SQLite through its repository, and has no
> `showNotWiredToast` on its primary actions.

## TL;DR

| Bucket | Count | What's in it |
|---|---|---|
| Done (routed + wired to SQLite) | ~17 screens/flows | Auth (3), Titles, Copies, Labels, Check-out, Return, Holds, Fines, Members ×2, Library profile, Loan rules, Appearance, Reference-data seeding |
| Partially wired (works, but has stubbed actions) | 4 | Circulation overview (dead route + 1 stub), Copy list (done — see note), Member form expiry picker, Shell account chip |
| UI-only, routed but stubbed | 3 | Dashboard (gated), Backup, Sync |
| In tree but shelved (commented out of router) | 3 sections, 5 routes | OPAC, Reports, Users + Roles |
| Removed / descoped in git history | 3 | Author sub-feature, Catalog overview page, `feature-plan.md` |
| Tests | 5 files | converters, recovery-code, staff repo, title repo, circulation repo + drift migration test to v10 |

The app today is a **working desk tool for one branch**: catalogue →
members → checkout/return/holds/fines → loan rules. What is missing for a
"whole library" story is: dashboard numbers, backup/restore, real staff
management UI (data layer exists), public search (OPAC), and reports. None of
those need schema redesign — they are read-models and file I/O over tables
that already exist.

### Status legend used below

- ✅ Done — routed, cubit → repository → drift, error states, no stub on the happy path.
- 🟡 Partial — happy path works, one or two secondary buttons toast.
- 🔴 UI-only — pixel-complete layout on mock data, every action toasts.
- ⏸️ Shelved — code exists but route + nav entry are commented out.
- 🗑️ Removed — deleted in a recent commit, deliberately descoped.

---

## 1. Done ✅

### 1.1 Foundation (not a feature, but it is finished)

| Piece | Evidence | Notes |
|---|---|---|
| Adaptive shell (rail / bottom bar / extended rail) | `lib/app/shell/app_shell.dart`, `shell_destinations.dart:56` | 5 live destinations: Dashboard, Catalog, Circulation, Members, Settings. OPAC/Reports/Users commented out at `shell_destinations.dart:104-122`. |
| Router (single `GoRouter`, `StatefulShellRoute.indexedStack`) | `lib/app/router/app_router.dart`, `lib/core/router/routes.dart` | Auth outside shell; `/` → `/dashboard`; `/catalog` → titles; `/circulation` → check-out; `/settings` → library. No `--flavor`, flavor = entrypoint. |
| DI (`get_it` + `injectable`, cubits via `BlocProvider` in router) | `lib/core/di/injection.dart`, `injection.config.dart` | `@lazySingleton` app-wide, `@injectable` page-scoped. |
| Error model (`AppException` + `guardDatabase`, l10n-mapped) | `lib/core/error/app_exception.dart`, `guard.dart`, `lib/shared/utils/app_exception_l10n.dart` | Pages catch `AppException` and toast `error.localizedMessage(l10n)`. |
| Money (extension type, minor units, `MoneyConverter`) | `lib/core/money/` | `display()` to screen, `toMoney()` in, never interpolated. |
| Design system `khulla_ui` | `packages/khulla_ui/lib/src/widgets/` (~55 primitives), `test/` (5 test files) | Tokens only, `app_palette.dart` sole hex owner. |
| L10n (ARB source of truth) | `lib/l10n/arb/app_en.arb` — 853 keys | `commonNotWiredYet` at line 134 is the stub-toast string. |
| Database migrations v1→v10 | `app_database.dart:88-304`, `drift_schemas/`, `test/drift/app_database/migration_test.dart` | 12 tables. `from > to` refusal is load-bearing. `schema.md` doc is stale (says v7 — see §5). |
| Reference data seeding (formats + member types) | `lib/shared/domain/reference_data_repository.dart`, `reference_data_cubit.dart`, `reference_seed_labels.dart` | `ensureDefaults`, `addFormat`, member-type CRUD. |

### 1.2 Staff auth ✅

| Flow | Files | Status |
|---|---|---|
| Onboarding (library + admin account + recovery codes) | `features/staff_auth/presentation/onboarding/` + `onboarding_cubit.dart:152 completeSetup()` | Done. Schema v7 added `staff_recovery_codes`. |
| Sign-in (+ recovery-code availability check) | `sign_in/` + `sign_in_cubit.dart:61 signIn()` | Done. |
| Recover password | `recover_password/` | Done. |
| Session restore / sign-out, router redirect | `auth/cubit/auth_cubit.dart:33,63,70`, `app_router.dart:371 _redirect` | Done. |
| Password hashing (bcrypt, pure Dart) + recovery codes | `lib/core/security/password_hasher.dart`, `recovery_code.dart`, `test/core/recovery_code_test.dart` | Done. |

### 1.3 Catalog — Titles ✅

`features/catalog/title/` — full stack: `tables/titles.dart` + `title_formats.dart`
→ `title_local_data_source.dart` (custom SQL with copy/availability counts) →
`title_repository_impl.dart` (id assign, `buildSearchText`, block delete while
copies exist) → `TitleCubit` / `TitleDetailCubit` / `TitleFormCubit` /
`TitleFormatCubit`.

- Title list: search, availability filter, sort → `ORDER BY`, paging. ✅
- Title detail: header + details + copies card + history (returned loans). ✅
- Add/edit via `TitleFormDialog` (shell action, no route — per convention). ✅
- Format manager dialog (`TitleFormatListDialog`). ✅
- Archive + hard delete with guard. ✅ (`title_detail_page.dart:53,84,107`)
- Covered by `test/data/title_repository_test.dart`.

### 1.4 Catalog — Copies ✅

`features/catalog/copy/` — `tables/copies.dart` → `local_copy_data_source.dart`
(joins title + open loan for borrower/due) → `CopyRepositoryImpl` → `CopyCubit`
(`loadCopies`, `archiveCopy`, **`markCopyLost`, `markCopyDamaged`** —
`copy_cubit.dart:99-113`) + `CopyFormCubit` (`saveCopy`).

- Holdings list across all titles, status filter, sort, paging. ✅
- Add copy (barcode auto-allocate from library settings supported). ✅
- Mark lost / mark damaged / withdraw — all wired with destructive confirms
  and success toasts (`copy_list_page.dart:65-123`). ✅
- Row tap → parent title (`Routes.catalogTitle`). ✅

### 1.5 Catalog — Labels ✅

`features/catalog/label/` — `LabelCubit` (`label_cubit.dart`: `loadLabelDesk`,
`queueBarcode`, `printSheet`) + `LabelSheetPrinter` (`printing` + `pdf` deps)
+ `label_print_page.dart` (380 lines, `BlocBuilder`, `AppException` handling).

- Scan-by-barcode queue (re-scan bumps count), size/layout toggles, sheet PDF →
  OS print dialog. ✅ Real implementation, not the old placeholder (the
  `label_size.dart` / `labels_placeholder.dart` under `copy/` were deleted in
  `4de2375` and re-created properly under `label/`).

### 1.6 Circulation core ✅ (the engine everything else uses)

`features/circulation/shared/data/circulation_repository_impl.dart` (991 lines)
— transactional checkout / return / renew / holds / fines over `AppDatabase`:

- `checkOutCopy`: barcode → copy/title/member lookup, archived/suspended/
  expired/lendable/reserved/availability checks, borrowing limit, overdue
  block, max-outstanding-fine, hold-queue order, due-date from effective rules,
  fulfils member's own hold. ✅
- `returnCopy` / `returnCopies`: closes loan, computes overdue fine
  (`computeOverdueFine` with grace + cap), raises `FineReason.overdue` unless
  waived, promotes next waiting hold or releases copy. ✅
- `renewLoan`: renewal-limit + waiting-hold guards, extends by renewal or loan
  period. ✅
- `placeHold` / `cancelHold` / `markHoldReady` / `expireStaleHolds`: hold limit,
  lendable/archived guards, copy assignment, shelf-expiry, queue promotion. ✅
- `collectFine` / `waiveFine`: settles outstanding, guards double-settle. ✅
- Reads delegate to `LoanLocalDataSource` / `FineLocalDataSource` /
  `ReservationLocalDataSource`. ✅
- Covered by `test/data/circulation_repository_test.dart` (267 lines).

### 1.7 Circulation desks ✅ (all four routed)

| Desk | Route | Cubit key methods |
|---|---|---|
| Check-out | `circulation/check-out` (`CheckOutPage`, 165 lines) | `lookupMember`, `addCopyByBarcode`, `checkOutCopies` (`check_out_cubit.dart:70,131,165`) |
| Return | `circulation/return` (`ReturnPage`, 131 lines) | `addLoanByBarcode`, `returnCopies` (`return_cubit.dart:22,75`) incl. condition + waive toggle |
| Holds | `circulation/reservations` (`ReservationListPage`, 307 lines) | `loadReservations`, `cancelHold`, `markHoldReady` (`reservation_list_cubit.dart:68,75`) + `PlaceHoldDialog` from shell action |
| Fines | `circulation/fines` (`FineListPage`, 372 lines) | `loadFines`, `collectFine`, `waiveFine` (`fine_list_cubit.dart:98,105`) |

All four render the four screen states (loading / error + retry / empty /
content) with `AppException` toasts. ✅

### 1.8 Members ✅

`features/members/` — `tables/members.dart` + `member_types.dart` →
`member_local_data_source.dart` → `MemberRepositoryImpl` → `MemberCubit`
(search, with-loans / owes-fines / suspended / expiring filters, sort, paging)
+ `MemberDetailCubit` (`loadMember`, `removeMember`, `collectFine`,
`suspendMember`, `unsuspendMember`, `renewMembership`) + `MemberFormCubit`.

- Member list + detail + form dialog (shell action). ✅
- Suspend / unsuspend / renew from both list and detail. ✅
- Detail shows loans card + fines card (reads circulation tables). ✅
- One stub: expiry date picker in `member_form_dialog.dart:271` still calls
  `showNotWiredToast`. 🟡 (only stub in the whole members feature)

### 1.9 Settings — Library profile ✅ / Loan rules ✅ / Appearance ✅

| Page | Route | State |
|---|---|---|
| Library profile (name, contact, currency incl. v9 `currency_name`/`currency_symbol`) | `settings/library` (`library_profile_page.dart`, 232 lines) | ✅ `LibraryProfileCubit.loadProfile` + save, `AppException` toasts |
| Loan rules (periods, limits, fine rates, hold shelf) | `settings/loan-rules` (`loan_rules_page.dart`, 266 lines) | ✅ `LoanRulesCubit.loadRules` + save |
| Appearance (theme) | `settings/appearance` (`appearance_page.dart`, 93 lines) | ✅ "The one settings screen that is not a placeholder" — `ThemeCubit` + `theme_storage.dart` |

---

## 2. Partially wired 🟡

| Area | File | What works | What's stubbed |
|---|---|---|---|
| Circulation overview (loans desk) | `features/circulation/circulation/presentation/circulation_page.dart` (414 lines) | `LoanListCubit.loadOpenLoans`, search/status/sort/clear, **renew works** (`_renewLoan`), return + view-member navigate | `loansMarkLost` row action → `showNotWiredToast` (`:154`); **and the page has no route** — router serves the four desks directly, so this file is currently dead code |
| Member form expiry | `features/members/presentation/pages/member_form_dialog.dart:271` | Everything else in the form saves | Date picker toasts; expiry must be edited elsewhere or left unset |
| Shell account chip | `lib/app/shell/widgets/shell_account_chip.dart:46,60` | Layout, avatar, navigation | Profile + sign-out taps toast (sign-out path exists in `AuthCubit.signOut` but isn't called from here) |
| Settings landing | `features/settings/presentation/pages/settings_page.dart` | Version/storage/licence rows render | All values are `settings_placeholder.dart` constants; page is **not routed** (router goes straight to sub-pages), so low priority |

---

## 3. UI-only but routed 🔴 (real layout, mock data, every action toasts)

### 3.1 Dashboard 🔴 — `features/dashboard/presentation/dashboard_page.dart`

- Full two-pane layout exists (stats strip, usage/fines/collection cards,
  activity, attention worklist, ranked top-titles/top-members, subjects,
  quick actions) with 9 placeholder imports — but `build()` returns early at
  `:110-115` behind `TODO(sawongam): Remove this once the dashboard is
  implemented`, showing only `AppEmptyView("This section is under
  construction")`. The 40-line layout below is dead code (`// ignore:
  dead_code`).
- **To finish:** one `DashboardCubit` aggregating existing repositories
  (open/offense counts from `LoanLocalDataSource`, fines outstanding,
  recent titles/copies, top-borrowed via `loans_copy_history` index). No new
  tables needed. Wire period selector + quick-action nav. Delete
  `presentation/placeholder/` afterwards.

### 3.2 Backup 🔴 — `features/settings/presentation/pages/backup_page.dart`

- Export / restore / import / erase-confirm UI is finished; **all four**
  actions call `showNotWiredToast` (`:29,83,90,97`); stats are
  `placeholderLastBackup / placeholderDatabaseSize / placeholderStoragePath`.
- Building blocks already in repo: `file_selector` + `saveTextFile`
  (`lib/core/files/`), `sqlite3` backup API via drift. Missing: export
  (copy/vacuum db file → picked path), restore (replace + `warmUp` + reseed
  check), CSV/MARC import, destructive reset (delete + recreate + sign out).

### 3.3 Sync 🔴 — `features/settings/presentation/pages/sync_page.dart`

- Provider dropdown + switches are local `setState` only; "Sync now" toasts
  (`:112`); history table renders `placeholderSnapshots`. Copy correctly states
  local-is-truth.
- No sync transport exists (and per ADR-0001 local-first, none is owed for
  v1). See §6 for the honest options (folder/WebDAV/S3 snapshot of the db
  file vs. row-level sync — recommend the former).

---

## 4. Shelved — in tree, out of router ⏸️

Routes + nav entries are commented out in **both**
`app_router.dart:264-293` and `shell_destinations.dart:104-122`. Uncommenting
restores the pages as-is (UI-only).

| Section | Files | Data state | UI state |
|---|---|---|---|
| OPAC (public search) | `features/opac/presentation/opac_page.dart` (210 lines) + `opac_search_panel.dart`, `opac_result_card.dart` | Filters `placeholderTitles` in memory (`catalog_placeholder.dart`); subjects derived from mocks | Card grid + featured/empty states done; Hold + Kiosk actions toast (`:150,198`); details link points at staff title route |
| Reports | `features/reports/presentation/reports_page.dart` (387 lines) + `reports_fines_card.dart`, `reports_ranked_table.dart` | `reports_placeholder.dart` (collection slices, top titles/members, fines) | Period segmented control, collection header, ranked tables done; export/share toast (`:351,358`) |
| Users + Roles | `features/users/presentation/pages/user_list_page.dart` (286 lines), `role_list_page.dart` (146 lines) + `permission_matrix.dart`, `staff_card.dart` | Filters `placeholderStaff` in memory; sort/paging local; **every** row/menu action toasts (`user_list_page.dart:166,172,177,185,251,266`, `role_list_page.dart:56`) | Table + cards finished. **Data layer is ahead of UI:** `tables/staff.dart`, `staff_recovery_codes.dart`, `StaffRepository` + impl + mappers exist and are tested (`test/data/staff_repository_test.dart`). UI needs a `StaffCubit` + role editor, not new tables. |

---

## 5. Removed / descoped 🗑️ (from git log)

- **Author sub-feature deleted** (`834ceaf`): `catalog/author/`
  (`author_list_page`, `author_detail_page`, `author_card`) +
  `catalog_author.dart` placeholder gone; author is now a plain `title.author`
  text column. Author-scoped filters removed from `CopyQuery`, `TitleQuery`,
  `LoanQuery`, `ReservationQuery`, `MemberQuery`. Deliberate simplification —
  don't re-add without a many-to-many design.
- **Catalog overview page deleted** (`01270e5`, part of title refactor):
  `catalog_page.dart` + `catalog_overview_cubit.dart` removed; `/catalog`
  now redirects to `/catalog/titles`. The "counts + recent titles" landing has
  no owner — Dashboard (§3.1) is its natural successor.
- **`feature-plan.md` deleted** (`4de2375`): the catalog/circulation build-order
  plan was folded into doc comments and removed. History of intent now lives
  only in commit `0351414`'s diff — worth a one-paragraph ADR if the plan
  matters.
- **Label placeholder → real impl** (`4de2375`, despite the "remove" commit
  message): old `copy/presentation/label_print_page.dart` +
  `labels_placeholder.dart` replaced by the real `catalog/label/` stack
  (cubit + `LabelSheetPrinter`). Net gain, not a loss.
- **Schema v10 cleanup** (`6d21536`): dropped `library_settings.branch`,
  `titles.subtitle`, `titles.subjects`. OPAC's `_subjects` getter still reads
  `title.subjects` off the **placeholder** model, so no migration issue — but
  any future subjects feature needs a new table/column, not a resurrection.

### Stale docs / doc-code mismatches found during scan

1. `README.md:7` says "No library features exist yet" — false since ~Sept 5;
   catalog/circulation/members/settings are wired.
2. `README.md:20-21` platform table still says `sqflite_*`; code moved to
   drift (`drift` + `drift_flutter` + `sqlite3`).
3. `docs/database/schema.md` header says generated from v7; DB is at v10
   (missing `currency_name`/`currency_symbol`, missing dropped columns).
   Regenerate with `make db-diagram`.
4. `lib/shared/utils/not_wired_action.dart:7` says "Every screen in the app is
   currently interface-only" — now true of only ~6 screens.
5. `AGENTS.md:25` says root has no `test/` dir — root `test/` exists
   (core/data/drift/helpers).

---

## 6. What to build next (ordered)

### P0 — v1 blockers (a library can't open without these)

1. **Dashboard numbers** (§3.1). Aggregate existing tables; no migration.
   Acceptance: overdue/return-today counts match fines + loans queries;
   empty library shows zero-state, not the construction gate.
2. **Backup export/restore/reset** (§3.2). `file_selector` save/open + copy
   the sqlite file; reset = delete + `warmUp` + redirect to onboarding.
   Acceptance: round-trip on Windows + web (IndexedDB export path differs).
3. **Staff management UI** (§4 Users). Data layer + tests exist; add
   `StaffCubit` (list/search/status filter), invite/disable/reset-password,
   role editor over `UserRole`. Wire shell account chip sign-out at the same
   time (§2). Acceptance: second staffer can sign in; disabled staffer can't.
4. **Loan-desk loose ends**: wire or remove `loansMarkLost` on the (currently
   dead) circulation overview; decide whether that page or the four desks is
   canonical and delete the other route target. Wire member-form expiry picker
   (§2).

### P1 — v1.1 (expected by librarians, no schema risk)

5. **OPAC v1**: point the existing card grid at `TitleRepository.findTitles`
   (`availableOnly` already exists in `TitleQuery`); hold button → existing
   `placeHold`; kiosk mode = OPAC route with staff chrome hidden.
6. **Reports v1**: top-borrowed (existing `loans_copy_history` index),
   overdue ledger, fines collected/waived, new-members-per-month; CSV export
   via existing `saveTextFile`; PDF via existing `printing` dep.
7. **Catalog polish**: ISBN lookup on title form, duplicate-title detection
   (`titles_isbn` index exists), bulk barcode printing from copy list into the
   label queue, subject tags re-design (post-v10-removal — likely a
   `title_subjects` join table + migration v11).
8. **Circulation polish**: overdue-notice list (uses `send_notices` flag that
   the member form already writes), auto-renew cron (`auto_renew_when_unreserved`
   column exists but nothing reads it), damaged/lost fine automation
   (`replacement_cost` column exists but return flow doesn't raise it).

### P2 — future / probably-what-to-add (bigger bets)

- **Sync for real** (folder-first: timestamped db snapshots to picked folder /
  WebDAV / S3; local-wins conflict rule per sync-page copy). Row-level sync is
  a second product — don't start it for v1.
- **Multi-branch**: `library_settings` is singleton (`CHECK id = 1`); branches
  need a `branches` table + `branch_id` on copies/loans/members + migration.
- **Acquisitions & weeding**: purchase requests, vendor tracking, withdrawal
  reports (withdraw exists per-copy; no batch flow).
- **MARC21 / CSV import-export**, barcode symbology options (Code39/QR),
  spine-label sizes beyond current `LabelSize`.
- **Audit log**: who checked out / waived / edited what (`checked_out_by_staff_id`
  exists on loans; extend to returns/fines/members + viewer in Reports).
- **Notifications**: email/SMS overdue notices (member `email`/`phone` stored;
  nothing sends), print-ready notice slips.
- **Accessibility + Nepali localization**: second ARB (`app_ne.arb`) + `make
  localize`; kiosk font-size mode; full keyboard flow for checkout/return.
- **Reservations UX**: member-facing hold pickup notices, hold expiry cron
  (`expireStaleHolds` exists but nothing schedules it — call on startup +
  daily timer).
- **Fines UX**: partial payment (schema supports `paid`/`waived` splits;
  UI only collects/waives in full), payment-method note, receipts via
  `printing`.
- **Dashboard v2**: collection-age chart, fine-recovery trend, subject
  coverage — needs a `dashboard` read-model, not new writes.

---

## 7. Appendix — where things live

```
lib/features/
  catalog/title/        ✅ list/detail/formats/form (full stack)
  catalog/copy/         ✅ holdings + add + lost/damaged/withdraw
  catalog/label/        ✅ queue + PDF print
  catalog/shared/       ✅ CopyStatus/CopyCondition + catalog_labels
  circulation/check_out|return_copy|reservation|fine/  ✅ four desks
  circulation/loan|fine|reservation/ (data+domain)    ✅ query sources
  circulation/shared/   ✅ CirculationRepositoryImpl (the engine)
  circulation/circulation/ 🟡 LoanListCubit works, page unrouted + 1 stub
  members/              ✅ list/detail/form (+1 stub: expiry picker)
  settings/             ✅ library + loan-rules + appearance; 🔴 backup + sync
  staff_auth/           ✅ onboarding/sign-in/recover/session
  dashboard/            🔴 gated placeholder
  opac|reports|users/   ⏸️ shelved UI-only (users has real data layer)
lib/core/  database(v10, 12 tables) · error · money · router · theme ·
           security(bcrypt/recovery) · files(saveTextFile) · window · feedback
lib/shared/ reference-data repo/cubit ✅ · components · LoadStatus · AppExceptionL10n
packages/khulla_ui/  ~55 widgets, theme, 5 test files
test/  core(2) · data(3) · drift(migration to v10) · helpers(3)
```

**Navigation today:** Dashboard · Catalog (Titles / Copies / Labels) ·
Circulation (Check-out / Return / Reservations / Fines) · Members · Settings
(Library / Loan rules / Appearance / Backup / Sync). OPAC / Reports / Users
hidden behind comments in router + shell destinations.

**Database (v10, 12 tables):** `library_settings` · `staff` ·
`staff_recovery_codes` · `loan_rules` · `title_formats` · `member_types` ·
`titles` · `copies` · `members` · `loans` · `fines` · `reservations`.
Full DDL in `docs/database/` (regenerate — currently shows v7).
