import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/ranking/port/model/ranking_page.dart';
import 'package:my_dic/features/ranking/port/model/ranking_query.dart';
import 'package:my_dic/features/ranking/port/ranking_query_repository.dart';
import 'package:my_dic/features/ranking/port/reader.dart';

// TODO refactor readerport
final class InternalRankingReaderPort implements RankingReaderPort {
  InternalRankingReaderPort(this._repository);

  final IRankingQueryRepository _repository;

  @override
  Future<Result<RankingPage>> fetchPage(RankingQuery query) =>
      _repository.fetchPage(query);
}
