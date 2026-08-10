/// The display projection for one ranked word.
class RankingListItem {
  const RankingListItem({
    required this.rankingId,
    required this.rank,
    required this.rankedWord,
    required this.lemma,
    required this.wordId,
    required this.hasConjugation,
  });

  /// Stable identity derived from the rankings table's physical primary key.
  final int rankingId;
  final int rank;
  final String rankedWord;
  final String lemma;
  final int wordId;
  final bool hasConjugation;
}
