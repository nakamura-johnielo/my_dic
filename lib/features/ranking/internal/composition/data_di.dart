import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/features/ranking/internal/infrastructure/drift/drift_ranking_query_repository.dart';
import 'package:my_dic/features/ranking/internal/infrastructure/drift/ranking_dao.dart';
import 'package:my_dic/features/ranking/port/ranking_query_repository.dart';

final rankingDaoProvider = Provider<RankingDao>((ref) {
  return RankingDao(ref.read(databaseProvider));
});
final rankingQueryRepositoryProvider = Provider<IRankingQueryRepository>((ref) {
  return DriftRankingQueryRepository(ref.read(rankingDaoProvider));
});
