/// Read-only accountId resolution port.
///
/// Features depend on this instead of Auth Repository or Firebase directly
/// so that "who is signed in" has one answer across the app and can be faked
/// in tests without any Firebase dependency.
abstract interface class CurrentSession {
  /// The signed-in account ID, or `null` when there is no ready session
  /// (signed out, email unverified, or profile still loading).
  String? get accountIdOrNull;

  /// The signed-in account ID.
  ///
  /// Throws [SessionRequiresAccountError] when there is none. Only use this
  /// where an unauthenticated caller is a programming error; most usecases
  /// should read [accountIdOrNull] and treat `null` as "act as guest".
  String requireAccountId();
}

class SessionRequiresAccountError extends StateError {
  SessionRequiresAccountError()
      : super('CurrentSession has no authenticated account.');
}
