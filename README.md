# Khulla Digital Library

An open-source library management system, built as a **local-first Flutter app**. Your catalogue lives in a SQLite database on your own machine — no server to run, no account to create, no data leaving the building.

*Khulla* (खुल्ला) is Nepali for "open".

## Download

Ready-to-run builds are attached to every release: **[latest release](https://github.com/khulla-digital-library/khulla-digital-library/releases/latest)**.

| Platform | File | How to run it |
| --- | --- | --- |
| Windows | `khulla-<version>-windows-x64.zip` | Unzip anywhere and run `khulla.exe`. It is a portable folder, not an installer. Windows warns about an unknown publisher because the build is unsigned — *More info* → *Run anyway*. |
| Android | `khulla-<version>-android.apk` | Sideload it, allowing installs from your browser or file manager. |
| Web | `khulla-<version>-web.tar.gz` | Serve the extracted folder from any static host. |
| Linux | `khulla-<version>-linux-x64.tar.gz` | Extract and run `./khulla`. |

You can also **[try it in a browser](https://khulla-digital-library.github.io/khulla-digital-library/)** — a demo with no server behind it, where the catalogue lives in that browser's storage and clearing site data wipes it.

Your catalogue is a SQLite file on your own machine, so uninstalling does not delete it and nothing is uploaded anywhere. Take a backup from **Settings → Backup** before moving between machines.

## Why local-first

A small library's catalogue is not big data — it is a few thousand rows that must be available at the circulation desk at 9am whether or not the internet is. Running it out of a local database means no hosting bill, no outage, no migration when a grant runs out, and no third party holding a record of who borrowed what.

The same codebase compiles to a Windows executable and to a web app, so a library can install it on the desk machine and still open the catalogue from a browser on the floor.

## Platforms

| Target | Status | SQLite backend |
| --- | --- | --- |
| Windows | Primary, released | drift on a background isolate, over bundled SQLite |
| Web | Primary, released | drift over SQLite in WebAssembly, in a worker |
| Android | Released | drift on a background isolate |
| Linux | Released | drift on a background isolate |
| macOS, iOS | Builds, not released | drift on a background isolate |

Releases are built by CI for the four released targets. macOS and iOS compile from the same source but are not published — both need an Apple Developer account to produce anything a user can open. See [docs/contributing/releasing.md](./docs/contributing/releasing.md).

## Getting started

**Prerequisites** — [FVM](https://fvm.app) to pin the Flutter SDK, plus platform toolchains: Visual Studio with the *Desktop development with C++* workload for Windows; `clang`, `cmake`, `ninja-build`, `libgtk-3-dev` for Linux.

```sh
git clone https://github.com/khulla-digital-library/khulla-digital-library.git
cd khulla-digital-library

dart pub global activate fvm   # once, if you do not have FVM yet
fvm install                    # downloads the SDK pinned in .fvmrc
make bootstrap                 # resolve deps and link local packages
make build                     # generate code (freezed, injectable, assets)
make localize                  # generate localizations

make run-windows               # or: make run-web, make run-linux
```

The Flutter version is pinned in `.fvmrc` (currently 3.47.0). After pulling a change that bumps it, run `fvm install`.

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
│   ├── database/         # Data layer: overview, how-to, schema diagram
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
| `make check` | Format, copyright, analyze and test — run this before a PR |
| `make ci` | The same gates CI runs, failing on unformatted code instead of rewriting it |
| `make run-web` / `run-windows` / `run-linux` | Run the dev flavor |
| `make build-web` / `build-windows` / `build-linux` / `build-apk` | Release builds |

## Architecture

The full guide lives in [docs/architecture](./docs/architecture/) — folder conventions, the data-layer stack, migration rules, state management, and naming. In short:

- **State** — `flutter_bloc` cubits with single-class `freezed` states and `formz` inputs.
- **Data** — `Page → Cubit → Repository → LocalDataSource → AppDatabase → SQLite`. Driver errors are converted to a small sealed `AppException` set at the data-source boundary.
- **Schema** — append-only migrations; the schema version is derived from the migration list. A database written by a newer build refuses to open rather than being deleted.
- **Design system** — `khulla_ui` holds every token; `app_palette.dart` is the only file in the repository allowed to contain a hex color.
- **Layout** — one adaptive shell: a bottom bar below 600px, a navigation rail above, extended with labels at 1200px.

## Contributing

Contributions are welcome. See [docs/contributing](./docs/contributing/) for setup, conventions and the pull-request flow.

Commits follow a conventional format — `feat:`, `fix:`, `chore:`, `refactor:`, `sync:`, `ci:` — enforced by a git hook. Branch off `dev`; direct commits to `dev` and `prod` are blocked.

Merging into `prod` publishes a release at the version in `pubspec.yaml` and redeploys the web demo — see [releasing](./docs/contributing/releasing.md).

## License

[MIT](./LICENSE)
