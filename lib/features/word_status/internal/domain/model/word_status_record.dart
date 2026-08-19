/// 保存済み WordStatus 行 1 件の永続化非依存表現です。
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
