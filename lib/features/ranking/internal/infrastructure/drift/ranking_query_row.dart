/// Data-layer-only row returned by [RankingDao]'s ranking projection query.
///
/// Nullable values are preserved so the repository can surface a typed
/// infrastructure failure instead of manufacturing display sentinels.
class RankingQueryRow {
  const RankingQueryRow({
    required this.rankingId,
    required this.rank,
    required this.rankedWord,
    required this.lemma,
    required this.wordId,
    required this.hasConjugation,
  });

  final int? rankingId;
  final int? rank;
  final String? rankedWord;
  final String? lemma;
  final int? wordId;
  final bool hasConjugation;
}
