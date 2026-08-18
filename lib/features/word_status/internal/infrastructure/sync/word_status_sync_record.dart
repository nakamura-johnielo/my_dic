/// Transport-neutral representation of a synchronized word-status row.
final class WordStatusSyncRecord {
  WordStatusSyncRecord({
    required this.wordId,
    required this.isLearned,
    required this.isBookmarked,
    required this.hasNote,
    required DateTime updatedAt,
    required this.remoteRevision,
    this.lastMutationId,
  }) : updatedAt = updatedAt.toUtc();

  final int wordId;
  final bool isLearned;
  final bool isBookmarked;
  final bool hasNote;
  final DateTime updatedAt;
  final int remoteRevision;
  final String? lastMutationId;
}
