import 'package:bcrypt/bcrypt.dart';
import 'package:injectable/injectable.dart';

/// Hashes and verifies staff passwords.
///
/// bcrypt, because the alternative in a local-first app is worse than it
/// looks: there is no server to rate-limit against, so whoever holds the
/// database file can try passwords as fast as the hash lets them. A salted,
/// deliberately slow hash is what turns "every password by lunchtime" into
/// "one password, maybe". A raw SHA of the password would be neither salted
/// nor slow.
///
/// Pure Dart, so the same code runs on Windows, the web build and everything
/// between — no FFI, no per-platform crypto backend to keep in step.
///
/// [hash] and [verify] are synchronous and deliberately expensive — a
/// noticeable fraction of a second each. Call them from a cubit that is
/// already showing a submitting state, never inside `build`.
@lazySingleton
class PasswordHasher {
  /// A salted bcrypt digest of [password], safe to store as-is.
  ///
  /// The salt is generated per call and travels inside the returned string,
  /// so there is no second column to add and no salt to manage. It carries
  /// the package's default work factor of 2^10; raising it later invalidates
  /// nothing, because the cost is recorded inside each hash and existing
  /// accounts keep verifying at the factor they were created with.
  String hash(String password) => BCrypt.hashpw(password, BCrypt.gensalt());

  /// Whether [password] produced [hash].
  ///
  /// Returns false rather than throwing on a malformed [hash] — a corrupted
  /// or hand-edited row must read as "wrong password", not as a crash on the
  /// sign-in screen.
  bool verify(String password, String hash) {
    try {
      return BCrypt.checkpw(password, hash);
    } on Object {
      return false;
    }
  }
}
