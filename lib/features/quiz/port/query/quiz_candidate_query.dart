/// 0 始まりの Quiz 候補検索に対する検証済み入力。
final class QuizCandidateQuery {
  QuizCandidateQuery(
      {required String text, required this.page, required this.size})
      : text = text.trim() {
    if (page < 0)
      throw ArgumentError.value(page, 'page', 'must not be negative');
    if (size <= 0) throw ArgumentError.value(size, 'size', 'must be positive');
  }

  final String text;
  final int page;
  final int size;
}
