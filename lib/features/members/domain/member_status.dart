/// A borrower's standing with the library.
///
/// [expiring] is separate from [active] because it is the state the desk can
/// still do something about: a membership that lapses next week is a
/// conversation at the counter today, not a refusal next month.
enum MemberStatus { active, expiring, expired, suspended }
