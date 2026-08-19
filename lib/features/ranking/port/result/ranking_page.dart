import 'package:my_dic/features/ranking/port/model/ranking_item.dart';

/// 正確なソース先読み情報を持つ、フィルタリング済み Ranking ページ。
final class RankingPage {
  RankingPage({
    required Iterable<RankingItem> items,
    required this.hasMore,
  }) : items = List.unmodifiable(items);

  final List<RankingItem> items;
  final bool hasMore;
}
