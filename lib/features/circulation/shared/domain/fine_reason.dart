/// Why a fine was raised.
///
/// The reason is stored rather than inferred, because the rate that produced
/// the amount can change: a fine raised at last year's per-day rate must keep
/// reading as what it was.
enum FineReason { overdue, damage, lost, membership }
