// Copyright (c) 2026 Khulla Digital Library contributors.
// SPDX-License-Identifier: MIT

/// The current application version, kept in sync with `pubspec.yaml`.
///
/// A plain constant avoids the async `package_info_plus` round-trip for a
/// value that is known at compile time and never changes at runtime.
/// Update this whenever `version:` in `pubspec.yaml` is bumped.
const String kAppVersion = '0.1.0';
