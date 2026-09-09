# Releasing

How a change on `dev` becomes something a librarian can download and run.

Everything here is GitHub Actions. There are no secrets to configure, no
signing certificates, and no deployment target to provision — Khulla is a
local-first app, so a release is four builds and a page to put them on.

## The workflows

| Workflow | Runs when | Does |
| --- | --- | --- |
| [`ci.yaml`](../../.github/workflows/ci.yaml) | Push to `dev`/`prod`, PR into either | `make ci` (format, copyright, analyze, test) and a web build |
| [`release.yaml`](../../.github/workflows/release.yaml) | A `v*` tag, or run by hand | Builds Windows, Linux, Android and web; publishes a GitHub Release |
| [`deploy-web.yaml`](../../.github/workflows/deploy-web.yaml) | Push to `prod`, or run by hand | Publishes the web build to GitHub Pages |

All three share [`.github/actions/setup-flutter`](../../.github/actions/setup-flutter/action.yml),
which installs the SDK version pinned in `.fvmrc`, resolves dependencies and
runs code generation. Generated sources are not committed, so no job can skip
that step.

CI runs `make ci`, not `make check`. They run the same gates; the difference is
that `make ci` fails on unformatted code rather than rewriting it on a runner
nobody will commit from.

## Cutting a release

1. Merge everything you want in the release into `dev`, then open a PR from
   `dev` into `prod` and merge it once CI is green.
2. Bump `version:` in `pubspec.yaml` on `prod`. The format is
   `<major>.<minor>.<patch>+<build>` — bump the build number too, because
   Android refuses an install whose `versionCode` did not increase.
3. Tag the merge commit and push the tag:

   ```sh
   git checkout prod && git pull
   git tag v1.0.0
   git push origin v1.0.0
   ```

The tag must match the pubspec version exactly (`v1.0.0` ↔ `version: 1.0.0+n`).
The workflow checks this and fails the release if they disagree, so that the
version a tester reports is the version you can check out.

The release job builds all four targets in parallel, checksums them into
`SHA256SUMS.txt`, and publishes a GitHub Release with generated notes plus a
download table. Roughly 15–25 minutes end to end.

## Sending someone a test build

You do not need a tag. From the **Actions** tab, pick **Release** → **Run
workflow** → the branch you want. It builds the same four targets and attaches
them as workflow artifacts, versioned `0.1.0-dev.<sha>`, with nothing
published. Send the run's URL — anyone signed into GitHub can download from it.

## What each target produces

| Target | Artifact | Notes |
| --- | --- | --- |
| Windows | `khulla-<version>-windows-x64.zip` | Portable folder, not an installer. Unzip and run `khulla.exe`. SmartScreen warns about an unknown publisher because the binary is unsigned. |
| Android | `khulla-<version>-android.apk` | One universal APK, not per-ABI splits — a tester sideloading should not need to know what an ABI is. |
| Web | `khulla-<version>-web.tar.gz` | Built for the site root. Serve the extracted folder from any static host. |
| Linux | `khulla-<version>-linux-x64.tar.gz` | Extract, run `./khulla`. |

macOS and iOS build from the same source but are not released: both need an
Apple Developer account to produce anything a user can open.

## The web demo

`deploy-web.yaml` publishes to GitHub Pages on every push to `prod`. It needs
one manual step, once: **Settings → Pages → Source: GitHub Actions**.

It is built with `--base-href /<repo>/`, because a project site is served from
a subpath. Routing uses the hash strategy (`/#/catalog`), which deep-links
correctly on Pages with no rewrite rules; switching to path URLs would mean
calling `usePathUrlStrategy()` *and* configuring a server-side rewrite to
`index.html`. See [ADR 0005](../architecture/decisions/0005-gorouter-for-navigation.md).

Treat it as a demo, not a service. The catalogue lives in the browser's own
storage, so every visitor gets a fresh empty library and clearing site data
wipes it.

## Signing, when it matters

Both desktop and Android ship unsigned today, which is honest for a pre-1.0
open-source tool a librarian installs deliberately. It costs the user one
"unknown publisher" dialog.

Signing becomes worth the cost when Khulla goes on Google Play (which refuses
debug keys outright) or when the SmartScreen warning starts costing installs.
Both follow the same shape: put the key in repository secrets, decode it in the
job, and point the build at it.

- **Android** — replace the debug `signingConfig` in
  `android/app/build.gradle.kts` with one reading a `key.properties` file, and
  write that file in the `android` job from a base64 secret.
- **Windows** — sign `build/windows/x64/runner/Release/khulla.exe` with
  `signtool` before the packaging step, using an EV or OV code-signing
  certificate.

Do not commit a keystore, a certificate, or a password. If a key does get
committed, rotate it — a rewrite of history is not a revocation.
