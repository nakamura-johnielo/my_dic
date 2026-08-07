/// The display projection for one ranked word.
class RankingListItem {
  const RankingListItem({
    required this.rank,
    required this.rankedWord,
    required this.lemma,
    required this.wordId,
    required this.hasConjugation,
  });

  final int rank;
  final String rankedWord;
  final String lemma;
  final int wordId;
  final bool hasConjugation;
}
