import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/ranking/port/model/ranking_item_id.dart';

/// 1 つの Catalog ランキングソースエントリに対する Ranking の表示プロジェクション。
final class RankingItem {
  const RankingItem({
    required this.id,
    required this.word,
    required this.rank,
    required this.rankedWord,
    required this.lemma,
    required this.hasConjugation,
  });

  final RankingItemId id;
  final CatalogWordRef word;
  final int rank;
  final String rankedWord;
  final String lemma;
  final bool hasConjugation;

  @override
  bool operator ==(Object other) =>
      other is RankingItem &&
      other.id == id &&
      other.word == word &&
      other.rank == rank &&
      other.rankedWord == rankedWord &&
      other.lemma == lemma &&
      other.hasConjugation == hasConjugation;

  @override
  int get hashCode =>
      Object.hash(id, word, rank, rankedWord, lemma, hasConjugation);
}
