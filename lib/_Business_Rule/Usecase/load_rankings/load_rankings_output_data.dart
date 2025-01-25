import 'package:my_dic/_Business_Rule/_Domain/Entities/ranking.dart';

class LoadRankingsOutputData {
  List<Ranking> items;
  List<int> requiredPage;
  LoadRankingsOutputData(this.items, this.requiredPage);
}
