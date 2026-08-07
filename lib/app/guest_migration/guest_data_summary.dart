/// Snapshot of how many rows sit under the guest scope across the datasets
/// that support real per-account scoping. User Profile is intentionally
/// excluded: profile rows only ever get created for a signed-in account
/// (`ensureUserProfile`), so no guest-scope profile can exist.
class GuestDataSummary {
  const GuestDataSummary({
    required this.espJpnWordStatusCount,
    required this.jpnEspWordStatusCount,
    required this.myWordCount,
    required this.myWordStatusCount,
  });

  final int espJpnWordStatusCount;
  final int jpnEspWordStatusCount;
  final int myWordCount;
  final int myWordStatusCount;

  bool get isEmpty =>
      espJpnWordStatusCount == 0 &&
      jpnEspWordStatusCount == 0 &&
      myWordCount == 0 &&
      myWordStatusCount == 0;

  bool get isNotEmpty => !isEmpty;

  int get totalCount =>
      espJpnWordStatusCount +
      jpnEspWordStatusCount +
      myWordCount +
      myWordStatusCount;
}
