/// Where one loan stands right now.
///
/// [dueToday] is its own value rather than a date comparison in the UI: the
/// desk treats "back today" as a working state — a shelf to watch, a call to
/// make — and a screen that has to recompute it from a date on every build
/// gets it wrong the moment the app is left open past midnight.
enum LoanStatus { onLoan, dueToday, overdue, returned }
