/// Stable local row-scope identifier used for unauthenticated (guest) access
/// and for rows created before per-account scoping existed on a dataset.
///
/// Never sent to Firebase; it only selects which local rows a datasource
/// read/write touches. Signed-in users are scoped by their real accountId
/// instead. Automatic migration from this guest scope to a signed-in
/// account's scope is intentionally not performed here (see Local-first 7
/// guest integration design).
const String guestAccountScope = 'legacy_unowned';
