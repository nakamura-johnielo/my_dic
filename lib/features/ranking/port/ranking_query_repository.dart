import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/ranking/port/model/ranking_page.dart';
import 'package:my_dic/features/ranking/port/model/ranking_query.dart';

/// Application read port for account-scoped ranking projections.
abstract class IRankingQueryRepository {
  Future<Result<RankingPage>> fetchPage(RankingQuery query);
}
