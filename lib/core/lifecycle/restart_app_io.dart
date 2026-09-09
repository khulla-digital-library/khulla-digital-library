// Copyright (c) 2026 Khulla Digital Library contributors.
// SPDX-License-Identifier: MIT

import 'dart:io';

/// Ends the process. The platform (or the operator, on desktop) starts it
/// again — there is no supported way to reopen a closed `AppDatabase`
/// connection in place.
void restartApp() => exit(0);
