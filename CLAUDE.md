# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository

Khulla is an open-source library management system: a **local-first Flutter app** with no backend. The catalogue lives in SQLite on the device. Organized as a Melos monorepo:

| Path | Package | Role |
| --- | --- | --- |
| `.` | `khulla` | The app |
| `packages/khulla_ui` | `khulla_ui` | Design system — tokens, primitives, zero domain knowledge |

Primary targets are **Windows and web**; Linux, macOS, Android and iOS build from the same source.

Two flavors, `dev` (`lib/main_dev.dart`) and `prod` (`lib/main_prod.dart`), differing only in which database file they open and how loudly they log. **There is no `--flavor`** — `flutter build` does not support it on desktop or web, so the entrypoint is the only flavor switch on every platform.

`sizzbe-app/` is a read-only reference copy of the codebase these conventions came from. It is gitignored and excluded from analysis. Never edit it, never import from it.

## Commands

**Do not run the app yourself** (`flutter run`, the `run` skill, an emulator) — the user runs and previews it. Verify with `dart run melos run analyze`, `dart run melos run test`, and code review. If visual verification is needed, describe what to check and ask.

**Do not touch git state unless explicitly asked** — no `git add`, `git commit`, `git push`, no branch or tag creation, no `make pr`. Leave changes unstaged. Read-only git commands are fine. Approval once does not carry to later changes.

**Never run `dart format .` or `dart analyze` from the repo root** — use `make format` / `make analyze`, which go through `melos exec` and stay inside workspace packages.

Setup:
```sh
dart run melos bootstrap   # pub get + link local path deps across all packages
make build                 # generated sources are not committed; run this first
make localize
```

| Command | What it does |
| --- | --- |
| `make bootstrap` | `melos bootstrap` |
| `make build` | Codegen: freezed, injectable, json_serializable, flutter_gen |
| `make localize` | Regenerate `AppLocalizations` from the ARB files |
| `make clean` | Delete `.dart_tool/build` (use if codegen fails after a bump) |
| `make check` | `format` + `analyze` + `test` — what CI runs |
| `make analyze` / `format` / `fix` / `test` | Individually, across every package |
| `make run-web` / `run-windows` / `run-linux` | Run the dev flavor |
| `make build-web` / `build-windows` / `build-apk` | Release builds of the prod flavor |
| `make db-web` | Refetch `sqlite3.wasm` + `sqflite_sw.js` into `web/` |
| `make pr` | `git push` and open a PR against `dev` |

Workspace scripts live in `melos.yaml`. Bloc lint: `dart run bloc_tools:bloc lint .`

Before finishing any change: `make format` and `make analyze`.

## Architecture

### Layout

```
lib/
├── app/          # Root widget, router, the adaptive shell
├── core/         # DI, database, errors, routing, storage, logging, window
├── features/     # One folder per feature — empty today
└── shared/       # Cross-feature models, widgets, components, layouts
```

Features add `data/` and `domain/` only when needed — presentation-first is fine:

```
features/<name>/presentation/
├── cubit/          # <name>_cubit.dart + <name>_state.dart
├── pages/          # route entry points — compose sections, shallow build()
├── placeholder/    # mock data and preview models until the tables exist
└── widgets/        # single-feature UI only
```

A cubit/state pair **always** lives in its own `cubit/` folder, never loose beside pages or widgets.

Multi-step flows nest one folder per step, and each step owns its cubit, page and widgets:

```
features/staff_auth/presentation/
├── auth/                       # app-wide session cubit, no page
│   └── cubit/
├── sign_in/
│   ├── cubit/                  # sign_in_cubit.dart + sign_in_state.dart
│   ├── sign_in_page.dart
│   └── widgets/
└── widgets/                    # shared across the flow's steps
```

A single-step feature drops the step folder and keeps the page at the presentation root. Mock data goes in `placeholder/`, not `widgets/`. Never import another feature's `presentation/widgets/` or `placeholder/`.

A feature that owns several tables splits into sub-features instead, one folder per resource, and **each sub-feature carries its own full `data/` / `domain/` / `presentation/` stack**. Do not hoist a shared `data/` or `domain/` to the feature root. `catalog` will be the first of these:

```
features/catalog/
├── shared/                     # only what genuinely spans sub-features
│   ├── domain/                 # catalog_constants.dart
│   └── presentation/
│       ├── placeholder/
│       └── widgets/            # domain-free UI (cards, sheets, chips)
├── title/{data,domain,presentation}/
├── copy/{data,domain,presentation}/
├── author/{data,domain,presentation}/
└── catalog/presentation/       # the overview page, no resource of its own
```

Each sub-feature keeps the single-step shape inside `presentation/` (`cubit/`, page at the root, `widgets/`). A widget that touches a domain model belongs to that model's sub-feature; `shared/presentation/widgets/` is for UI with no domain imports. Sub-features may import each other; cross-resource cascades live in a coordinator under `shared/presentation/`, not in the individual cubits.

### The shell

`app/shell/app_shell.dart` is the app's only shell, and it adapts rather than branching by platform:

- Below 600px it renders `AppNavBar` (bottom) under a slim `AppBar`.
- From 600px up it renders `AppNavRail` beside the content; the rail extends with labels at 1200px and above.

`app/shell/widgets/shell_destinations.dart` is the single source of truth for navigation. Index `i` in that list is `StatefulShellBranch` `i` in `AppRouter` — adding a section means adding an entry in both, in that order.

Read the window class with `context.formFactor`, never a raw `MediaQuery` width. Inside a component that must adapt to its slot rather than to the window, use `LayoutBuilder`.

### UI placement

> Could this exist in another app with the same brand?
> **Yes** → `packages/khulla_ui` · **No, generic** → `shared/widgets/` · **No, library-domain UI, 2+ features** → `shared/components/` · **No, one feature** → `features/<name>/presentation/widgets/`

Start UI in the feature that needs it; promote to `shared/components/` only when a second feature needs it. Browse `shared/` before duplicating — one widget per file. Row models and domain entities live in feature `data/` / `domain/`, not `shared/models/`.

`khulla_ui` has zero domain knowledge (no books, loans, members). Prefix classes with `App`. Read tokens from theme (`context.appSpacing`, `colorScheme`, `context.appColors`, `context.appRadius`) — never hard-code colors, spacing, or corner radii. Export public widgets from `khulla_ui.dart`; keep `app_palette.dart` internal — it is the only file in the repo that may contain a hex color.

### Data layer

There is no network. The vertical stack is:

```
Page → Cubit → Repository → RepositoryImpl → LocalDataSource → AppDatabase → SQLite
```

- **Contracts** — `abstract interface class` in `domain/<name>_repository.dart` and `data/<name>_local_data_source.dart`. Domain models in `domain/models/`. `domain/` never imports sqflite.
- **Impls** — `data/<name>_repository_impl.dart` delegates to the data source; `data/local_<name>_data_source.dart` runs the queries and maps rows. Both `@LazySingleton(as: …)`.
- **Mappers** — `data/mappers/<feature>_row_mappers.dart`: `toDomain()` on rows, `toRow()` on writes. Mapping happens in data sources only.
- **Errors** — wrap every data-source method body in `guardDatabase` (`lib/core/error/guard.dart`), which converts driver errors into `AppException`. Cubits catch `AppException` → `state.error`; pages render `AppExceptionL10n.localizedMessage`, never `error.message`.
- **DI** — `make build` generates bindings. `@lazySingleton` for app-wide cubits and services, `@injectable` for feature-scoped ones. Provide cubits via `BlocProvider` in `app_router.dart`; never call `getIt<T>()` inside a widget.

### Database

`AppDatabase` (`lib/core/database/app_database.dart`) is a `@lazySingleton` opened once in `bootstrap` and injected into data sources. Take `AppDatabase`, not a raw `Database`, so the connection can be swapped (restore, import) without stale handles.

`lib/core/database/database_platform.dart` conditionally exports one of two implementations — the native one uses `sqflite` on mobile and `sqflite_common_ffi` on desktop; the web one uses `sqflite_common_ffi_web`. Any code that needs a platform difference in the data layer belongs behind that pair, not in an `if (kIsWeb)`.

**Adding a table or column** is two steps:

1. Write a `Migration` in `lib/core/database/migrations/` with the next version number.
2. Append it to `appMigrations` in `migrations.dart`.

The schema version is derived from that list — there is no second number to bump. Migrations are **append-only**: a shipped `up()` is frozen, because someone's catalogue was built by running exactly that SQL. Fix a mistake with the next migration, never by editing an old one.

Foreign keys are enabled per connection in `_onConfigure`; WAL is enabled only where the platform supports it. A downgrade deliberately **refuses to open** rather than deleting the file — this app holds a library's only copy of its records.

### State management

`flutter_bloc` (Cubit/Bloc). Form state uses `formz` (`lib/core/form/inputs/` — `Email`, `FullName`, `Password`, `RequiredText`).

States are **single-class `freezed`** types — one `const factory`, never a sealed union. Most states carry `formz` inputs that must survive every status transition, so a union would force each variant to redeclare every field.

```dart
@freezed
abstract class CatalogState with _$CatalogState {
  const factory CatalogState({
    @Default(LoadStatus.initial) LoadStatus status,
    @Default(<Title>[]) List<Title> titles,
    AppException? error,
  }) = _CatalogState;

  const CatalogState._();

  bool get isLoading => status == LoadStatus.loading;
}
```

Two rules that are easy to get wrong:

- **Getters and methods require the private `const XState._();` constructor.** Put it *after* the unnamed `const factory`, not before — `sort_unnamed_constructors_first` rejects the usual freezed ordering, and `document_ignores` would make an `// ignore:` cost a doc comment.
- **`copyWith` preserves nullable fields.** To clear one, pass it explicitly: `copyWith(error: null)`. Never add `clearX` boolean parameters. By convention a cubit clears `error` whenever it starts fresh — every `copyWith` that sets `status` to `initial`, `loading`, or `loaded` also passes `error: null`; a failure passes the error, and everything else leaves it alone so a visible error is not silently wiped.

Run `make build` after adding or changing a state.

### Routing

Single `GoRouter` owned by `AppRouter` (`lib/app/router/app_router.dart`, `@lazySingleton`). Paths are constants in `Routes` (`lib/core/router/routes.dart`). Navigate with `context.go(Routes.xxx)`, never a hard-coded string.

There is no redirect guard yet because there is no session. When staff sign-in lands, add a `refreshListenable` over the auth cubit's stream (`GoRouterRefreshStream` is already in `core/router/`) and a `redirect` beside it.

Web uses the default hash URL strategy (`/#/catalog`), which deep-links correctly on any static host with no rewrite rules. Switching to path URLs means calling `usePathUrlStrategy()` **and** configuring a server-side rewrite to `index.html`.

### Desktop

`lib/core/window/window_setup.dart` conditionally exports a `window_manager` implementation on native and a no-op elsewhere, so `bootstrap` has no platform branch. It sets a minimum window size — the width below which the rail and a detail pane stop fitting — and shows the window only once Flutter can paint, avoiding the white flash of a default desktop launch.

### Startup

`bootstrap` installs the error and bloc observers, sizes the window, configures DI, then opens the database. If the database cannot be opened — a locked file, a full disk, a schema from a newer build — it runs `StartupFailureApp` instead of `App`, so the operator gets readable, localized copy and a retry rather than a crash.

## Naming conventions

- Files: `snake_case.dart`, one public widget/class per file, filename matches the class it exports (`BookListTile` → `book_list_tile.dart`, `AppButton` → `app_button.dart`).
- Classes in `khulla_ui`: prefix `App` (`AppButton`, `AppNavRail`, `AppTextField`). This prefix is reserved for the design system — don't use it in app or feature code.
- Classes in a feature's `presentation/widgets/`: prefix with the feature name, not `App` (`CatalogHeader`, `CatalogFilterBar`). This signals at a glance that the widget is feature-scoped.
- Pages: `<feature>_page.dart` under `presentation/pages/`, or at the step root inside a multi-step flow.
- Cubit/state pairs: `<name>_cubit.dart` + `<name>_state.dart` together in a `cubit/` folder.
- Placeholder/mock data: `<feature>_placeholder.dart` under `presentation/placeholder/`.
- `shared/components` and `shared/widgets` files use plain descriptive names, no prefix.
- Migrations: `<verb>_<subject>.dart` (`create_books_table.dart`, `add_isbn_to_books.dart`).

## Strings & assets

- All user-facing text goes in `lib/l10n/arb/app_en.arb`; access via `context.l10n` (`package:khulla/l10n/l10n.dart`). No hard-coded labels, hints, or button text. Run `make localize` after adding keys. Add new locales as `app_<locale>.arb`.
- Assets use generated `Assets.*` from `package:khulla/gen/assets.gen.dart` — never hard-code paths. Run `make build` after adding assets to `pubspec.yaml`.
- Generated sources (`*.g.dart`, `*.freezed.dart`, `*.config.dart`, `lib/gen/`, `lib/l10n/gen/`) are **not** committed. A fresh clone must run `make build` and `make localize`.

## Lints

`analysis_options_base.yaml` holds the shared rule set; the root `analysis_options.yaml` layers `bloc_lint` on top, and `packages/khulla_ui/analysis_options.yaml` includes the base alone. Analysis runs with `--fatal-infos`, so an info is a failure.

The root exclude list is written out in full rather than inherited: an including file's `analyzer.exclude` **replaces** the included one's, and `flutter pub get` appends the platform directories if they are missing — which would silently drop the generated-file globs. Edit that list in both places or not at all.
