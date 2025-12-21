import 'package:my_dic/features/ranking/domain/entity/ranking.dart';

class LoadRankingsOutputData {
  List<Ranking> items;
  List<int> requiredPage;
  LoadRankingsOutputData(this.items, this.requiredPage);
}
