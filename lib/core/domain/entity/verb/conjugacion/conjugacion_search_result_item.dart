/// 活用検索でヒットした単語のcatalog情報（word/wordId/簡易的な意味）。
/// Search・Quizの双方から利用されるcatalog read model。
class ConjugacionSearchResultItem {
  final String word;
  final int wordId;
  final String simpleMeaning;

  ConjugacionSearchResultItem({
    required this.word,
    required this.wordId,
    required this.simpleMeaning,
  });
}
