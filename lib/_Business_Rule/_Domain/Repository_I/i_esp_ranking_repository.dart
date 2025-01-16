import 'package:my_dic/_Business_Rule/_Domain/Entities/ranking.dart';

abstract class IEspRankingRepository {
  Future<List<Ranking>> getRankingList(int page, int size);
}
