// Copyright (c) 2026 Khulla Digital Library contributors.
// SPDX-License-Identifier: MIT

/// The build flavor the application is currently running as.
///
/// Each flavor has its own entrypoint (`lib/main_<flavor>.dart`) and resolves a
/// matching `AppConfig`.
enum Flavor { dev, prod }
