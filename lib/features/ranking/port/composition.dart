import 'package:my_dic/features/ranking/internal/application/ranking_reader.dart';
import 'package:my_dic/features/ranking/port/ranking_query_repository.dart';
import 'package:my_dic/features/ranking/port/reader.dart';

/// Pure Ranking composition root for a caller-supplied read projection.
RankingReader createRankingComposition(IRankingQueryRepository repository) =>
    InternalRankingReader(repository);
