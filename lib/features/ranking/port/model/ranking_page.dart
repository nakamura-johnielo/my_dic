import 'package:my_dic/features/ranking/port/model/ranking_list_item.dart';

/// A ranking page after the repository has applied its pagination strategy.
class RankingPage {
  RankingPage({required List<RankingListItem> items, required this.hasNext})
      : items = List.unmodifiable(items);

  final List<RankingListItem> items;
  final bool hasNext;
}
