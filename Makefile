.PHONY: bootstrap install-sdk build migrate db-diagram localize analyze format fix test check clean \
        db-web run-web run-windows run-linux build-web build-windows build-apk pr

FLUTTER := fvm flutter
DART := fvm dart

# ── Setup ───────────────────────────────────────────────────────────────────

## Install the Flutter SDK version pinned in .fvmrc.
install-sdk:
	fvm install

## Resolve dependencies and link local packages across the workspace.
bootstrap:
	$(DART) run melos bootstrap

# Keep in step with the `drift` version in pubspec.yaml — the worker and the
# WebAssembly build are only guaranteed to match within one release.
DRIFT_RELEASE := drift-2.34.3

## Fetch the SQLite WebAssembly build and the drift worker into web/.
## Only needed after upgrading drift — the output is checked in.
db-web:
	curl -fsSL -o web/sqlite3.wasm \
	  https://github.com/simolus3/drift/releases/download/$(DRIFT_RELEASE)/sqlite3.wasm
	curl -fsSL -o web/drift_worker.js \
	  https://github.com/simolus3/drift/releases/download/$(DRIFT_RELEASE)/drift_worker.js

# ── Code generation ─────────────────────────────────────────────────────────

## freezed, injectable, json_serializable, flutter_gen.
build:
	$(DART) run build_runner build

## Record the current schema, regenerate step-by-step migrations and their
## tests. Run after changing a table and bumping schemaVersion, before `build`.
migrate:
	$(DART) run drift_dev make-migrations

## Regenerate the Mermaid ER diagram in docs/database/schema.md from the
## latest drift schema snapshot. Run after `make migrate` / `make build`.
db-diagram:
	$(DART) tools/db_diagram.dart

## Regenerate AppLocalizations from lib/l10n/arb/.
localize:
	$(FLUTTER) gen-l10n

## Regenerate launcher icons across all platforms (Android, iOS, Web, macOS, Windows, Linux).
icons:
	$(DART) run icons_launcher:create

## Wipe the build_runner cache. Use when codegen fails after a dependency bump.
clean:
	rm -rf .dart_tool/build

# ── Quality ─────────────────────────────────────────────────────────────────

analyze:
	$(DART) run melos run analyze

format:
	$(DART) run melos run format

fix:
	$(DART) run melos run fix

test:
	$(DART) run melos run test

## What CI runs. Do this before opening a pull request.
check: format analyze test

# ── Run ─────────────────────────────────────────────────────────────────────

run-web:
	$(FLUTTER) run -d chrome -t lib/main_dev.dart

run-windows:
	$(FLUTTER) run -d windows -t lib/main_dev.dart

run-linux:
	$(FLUTTER) run -d linux -t lib/main_dev.dart

# ── Release builds ──────────────────────────────────────────────────────────
#
# Desktop and web do not support `--flavor`; the entrypoint selects the flavor
# on every platform, so these all target lib/main_prod.dart directly.

build-web:
	$(FLUTTER) build web -t lib/main_prod.dart

build-windows:
	$(FLUTTER) build windows -t lib/main_prod.dart

build-apk:
	$(FLUTTER) build apk -t lib/main_prod.dart

# ── Git ─────────────────────────────────────────────────────────────────────

pr:
	git push && gh pr create --fill --base dev
