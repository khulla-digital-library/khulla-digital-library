// Copyright (c) 2026 Khulla Digital Library contributors.
// SPDX-License-Identifier: MIT

import 'package:khulla/gen/app_version.dart';

/// Facts about the product itself — the version, who made it, where it lives.
///
/// None of it is localized: a version string, a person's name and a URL read
/// the same in every language, and translating any of them would break the
/// thing it points at.
///
/// [version] comes from `version:` in `pubspec.yaml`, read at build time by
/// `tools/version.dart` rather than at runtime — a runtime read would mean
/// another dependency for one string. It is the same number CI names the
/// release and its tag after, so what the about panel shows identifies the
/// download it is running.
abstract final class AppInfo {
  /// The released version, without the build number.
  ///
  /// Generated: bump `version:` in `pubspec.yaml` and run `make version`.
  static const String version = kAppVersion;

  /// The person behind the project, shown in the about panel.
  static const String authorName = 'Sangam Adhikari';

  /// The author's initials, for the avatar beside the name.
  static String get authorInitials => authorName
      .split(' ')
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();

  /// The author's site.
  static const String authorSite = 'https://sangamadhikari.com';

  /// The author's GitHub profile.
  static const String authorGithub = 'https://github.com/sawongam';

  /// Where the source lives.
  static const String repositoryUrl =
      'https://github.com/khulla-digital-library/khulla-digital-library';

  /// Where a bug or a request goes.
  static const String issuesUrl = '$repositoryUrl/issues';

  /// The licence the source is released under.
  static const String license = 'MIT';
}
