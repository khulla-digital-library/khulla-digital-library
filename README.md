# Khulla Digital Library

An open-source library management system, built as a **local-first Flutter app**. Your catalogue lives in a SQLite database on your own machine — no server to run, no account to create, no data leaving the building.

*Khulla* (खुल्ला) is Nepali for "open".

> **Status: early scaffold.** The architecture, design system, database layer and navigation shell are in place and building. No library features exist yet.

## Why local-first

A small library's catalogue is not big data — it is a few thousand rows that must be available at the circulation desk at 9am whether or not the internet is. Running it out of a local database means no hosting bill, no outage, no migration when a grant runs out, and no third party holding a record of who borrowed what.

The same codebase compiles to a Windows executable and to a web app, so a library can install it on the desk machine and still open the catalogue from a browser on the floor.

## Platforms

| Target | Status | SQLite backend |
| --- | --- | --- |
| Windows | Primary | `sqflite_common_ffi` (bundled SQLite over `dart:ffi`) |
| Web | Primary | `sqflite_common_ffi_web` (SQLite in WebAssembly, stored in IndexedDB) |
| Linux, macOS | Builds | `sqflite_common_ffi` |
| Android, iOS | Builds | `sqflite` (system SQLite) |

## Getting started

**Prerequisites** — [Flutter](https://docs.flutter.dev/get-started/install) 3.47 or newer (Dart 3.13+). For Windows builds you also need Visual Studio with the *Desktop development with C++* workload; for Linux, `clang`, `cmake`, `ninja-build`, `libgtk-3-dev`.

```sh
git clone https://github.com/khulla-digital-library/khulla-digital-library.git
cd khulla-digital-library

dart run melos bootstrap   # resolve dependencies, link local packages
make build                 # generate code (freezed, injectable, assets)
make localize              # generate localizations

make run-windows           # or: make run-web, make run-linux
```

Generated sources are not committed, so `make build` and `make localize` are required on a fresh clone before anything will analyze or run.

## Repository structure

```
khulla-digital-library/
├── lib/
│   ├── app/              # Root widget, router, adaptive navigation shell
│   ├── core/             # DI, database, errors, routing, logging, window
│   ├── features/         # One folder per feature
│   ├── l10n/             # Localization (ARB source of truth)
│   └── shared/           # Cross-feature models, widgets, components
├── packages/
│   └── khulla_ui/        # Design system — tokens, theme, primitives
├── assets/               # Icons and images
├── docs/
│   ├── architecture/     # Design decisions and ADRs
│   └── contributing/     # How to contribute
├── test/
├── android/ ios/ linux/ macos/ web/ windows/
├── melos.yaml            # Workspace scripts
└── Makefile              # Everyday commands
```

## Common commands

| Command | What it does |
| --- | --- |
| `make bootstrap` | Resolve dependencies across the workspace |
| `make build` | Run code generation |
| `make localize` | Regenerate localizations from `lib/l10n/arb/` |
| `make check` | Format, analyze and test — run this before a PR |
| `make run-web` / `run-windows` / `run-linux` | Run the dev flavor |
| `make build-web` / `build-windows` / `build-apk` | Release builds |

## Architecture

The full guide lives in [CLAUDE.md](./CLAUDE.md) — folder conventions, the data-layer stack, migration rules, state management, and naming. In short:

- **State** — `flutter_bloc` cubits with single-class `freezed` states and `formz` inputs.
- **Data** — `Page → Cubit → Repository → LocalDataSource → AppDatabase → SQLite`. Driver errors are converted to a small sealed `AppException` set at the data-source boundary.
- **Schema** — append-only migrations; the schema version is derived from the migration list. A database written by a newer build refuses to open rather than being deleted.
- **Design system** — `khulla_ui` holds every token; `app_palette.dart` is the only file in the repository allowed to contain a hex color.
- **Layout** — one adaptive shell: a bottom bar below 600px, a navigation rail above, extended with labels at 1200px.

## Contributing

Contributions are welcome. See [docs/contributing](./docs/contributing/) for setup, conventions and the pull-request flow.

Commits follow a conventional format — `feat:`, `fix:`, `chore:`, `refactor:`, `sync:`, `ci:` — enforced by a git hook. Branch off `dev`; direct commits to `dev` and `prod` are blocked.

## License

[MIT](./LICENSE)
