// Copyright (c) 2026 Khulla Digital Library contributors.
// SPDX-License-Identifier: MIT

/// Where one hold stands in the queue.
enum ReservationStatus {
  waiting,
  ready,
  fulfilled,
  expired,
  cancelled,
}
