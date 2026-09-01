/// Which set of lending rules a borrower falls under.
///
/// The category — not the member — carries the loan period, the borrowing
/// limit and the fine rate, so changing what a student may borrow is one edit
/// in settings rather than three hundred edits on the register.
enum MemberCategory { student, teacher, public, child }
