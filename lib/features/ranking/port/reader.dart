import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/ranking/port/model/ranking_page.dart';
import 'package:my_dic/features/ranking/port/model/ranking_query.dart';

/// Provider-neutral public reader for Ranking's read-only projection.
abstract interface class RankingReader {
  Future<Result<RankingPage>> fetchPage(RankingQuery query);
}
