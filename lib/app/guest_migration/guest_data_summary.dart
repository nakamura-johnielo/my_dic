/// Snapshot of how many rows sit under the guest scope across the datasets
/// that support real per-account scoping.
class GuestDataSummary {
  const GuestDataSummary({
    required this.espJpnWordStatusCount,
    required this.jpnEspWordStatusCount,
    required this.myWordCount,
    required this.myWordStatusCount,
    required this.userProfileCount,
  });

  final int espJpnWordStatusCount;
  final int jpnEspWordStatusCount;
  final int myWordCount;
  final int myWordStatusCount;
  final int userProfileCount;

  bool get isEmpty =>
      espJpnWordStatusCount == 0 &&
      jpnEspWordStatusCount == 0 &&
      myWordCount == 0 &&
      myWordStatusCount == 0 &&
      userProfileCount == 0;

  bool get isNotEmpty => !isEmpty;

  int get totalCount =>
      espJpnWordStatusCount +
      jpnEspWordStatusCount +
      myWordCount +
      myWordStatusCount +
      userProfileCount;
}
