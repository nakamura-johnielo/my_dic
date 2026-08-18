class SyncCursor implements Comparable<SyncCursor> {
  const SyncCursor({
    required this.seconds,
    required this.nanoseconds,
    required this.documentId,
  })  : assert(seconds >= 0),
        assert(nanoseconds >= 0 && nanoseconds < 1000000000),
        assert(documentId != '');

  final int seconds;
  final int nanoseconds;
  final String documentId;

  @override
  int compareTo(SyncCursor other) {
    final secondsComparison = seconds.compareTo(other.seconds);
    if (secondsComparison != 0) return secondsComparison;
    final nanosComparison = nanoseconds.compareTo(other.nanoseconds);
    if (nanosComparison != 0) return nanosComparison;
    return documentId.compareTo(other.documentId);
  }

  @override
  bool operator ==(Object other) =>
      other is SyncCursor &&
      seconds == other.seconds &&
      nanoseconds == other.nanoseconds &&
      documentId == other.documentId;

  @override
  int get hashCode => Object.hash(seconds, nanoseconds, documentId);
}
