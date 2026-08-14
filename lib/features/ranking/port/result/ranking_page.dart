import 'package:my_dic/features/ranking/port/model/ranking_item.dart';

/// A filtered Ranking page with exact source look-ahead information.
final class RankingPage {
  RankingPage({
    required Iterable<RankingItem> items,
    required this.hasMore,
  }) : items = List.unmodifiable(items);

  final List<RankingItem> items;
  final bool hasMore;
}
