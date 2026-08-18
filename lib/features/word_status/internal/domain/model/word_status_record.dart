/// Persistence-neutral representation of one stored WordStatus row.
final class WordStatusRecord {
  const WordStatusRecord({
    required this.wordId,
    required this.isLearned,
    required this.isBookmarked,
    required this.hasNote,
    required this.updatedAt,
  });

  final int wordId;
  final bool isLearned;
  final bool isBookmarked;
  final bool hasNote;
  final DateTime updatedAt;
}
