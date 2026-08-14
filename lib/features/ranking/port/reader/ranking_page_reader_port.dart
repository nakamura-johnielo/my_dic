import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/ranking/port/query/ranking_page_query.dart';
import 'package:my_dic/features/ranking/port/result/ranking_page.dart';

abstract interface class RankingPageReaderPort {
  Future<Result<RankingPage>> readPage(RankingPageQuery query);
}
