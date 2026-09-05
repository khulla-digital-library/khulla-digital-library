# Contributing

Thanks for helping build Khulla.

## Setup

You need [FVM](https://fvm.app) and the platform toolchains: Visual Studio with *Desktop development with C++* for Windows; `clang`, `cmake`, `ninja-build`, `libgtk-3-dev` for Linux; Xcode for macOS and iOS.

```sh
dart pub global activate fvm   # once, if you do not have FVM yet
fvm install
make bootstrap
make build                     # generated sources are not committed — required on a fresh clone
make localize
```

If a pull request bumps `.fvmrc`, run `fvm install` before `make bootstrap`.

Verify your setup with `make check`.

## Before you open a pull request

```sh
make check      # format + analyze + test, the same three steps CI runs
```

Analysis runs with `--fatal-infos`, so an info-level lint fails the build. Run `make fix` first — it resolves most of them automatically.

Never run `dart format .` or `dart analyze` from the repository root. `make format` and `make analyze` go through `melos exec`, which keeps them inside workspace packages.

## Conventions

The architecture guide is [CLAUDE.md](../../CLAUDE.md) at the repository root. It is written for an AI coding assistant, but it is the accurate and complete description of how this codebase is organized — read it before your first change. The short version:

- **One public class per file**, filename matching the class in `snake_case`.
- **No hard-coded colors, spacing, or corner radii.** Read tokens from the theme. `packages/khulla_ui/lib/src/theme/app_palette.dart` is the only file allowed to contain a hex color.
- **No hard-coded user-facing strings.** Every label goes in `lib/l10n/arb/app_en.arb` and is read via `context.l10n`.
- **`App`-prefixed class names are reserved** for the design system. Feature widgets take the feature's name as a prefix instead.
- **Schema changes are append-only migrations.** Never edit a migration that has shipped — someone's catalogue was built by running exactly that SQL.

## Branches and commits

Branch off `dev`. Direct commits to `dev` and `prod` are blocked by a git hook.

Commit messages follow a conventional format, also enforced by a hook:

```
type(scope): message
```

Valid types: `feat`, `fix`, `chore`, `refactor`, `sync`, `ci`.

```
feat(catalog): add ISBN lookup to the title editor
fix(circulation): stop a return from clearing the loan history
```

Open pull requests against `dev`. `make pr` pushes and opens one for you.

## Reporting bugs

Open an issue with the platform you hit it on (Windows, web, …), the Flutter version from `fvm flutter --version`, and the steps to reproduce. If it involves the database, say whether it happened on a fresh install or an existing catalogue — migration bugs and query bugs look identical from the outside.
