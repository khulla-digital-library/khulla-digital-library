/// Whether a staff account can sign in today.
///
/// [invited] is its own state rather than an inactive [active]: an invitation
/// that was never accepted is a job for the desk — resend it — while a
/// disabled account is a decision somebody already made.
enum UserStatus { active, invited, disabled }
