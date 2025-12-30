
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/features/ranking/data/data_source/local/ranking_dao.dart';
import 'package:my_dic/features/ranking/data/data_source/local/i_ranking_local_data_source.dart';
import 'package:my_dic/features/ranking/data/data_source/local/ranking_drift_data_source.dart';
import 'package:my_dic/features/ranking/data/repository_impl/wiki_esp_ranking_repository.dart';
import 'package:my_dic/features/ranking/domain/i_repository/i_esp_ranking_repository.dart';

final rankingDaoProvider = Provider<RankingDao>((ref) {
  return RankingDao(ref.read(databaseProvider));
});
final rankingLocalDataSourceProvider =
    Provider<IRankingLocalDataSource>((ref) {
  return RankingDriftDataSource(ref.read(rankingDaoProvider));
});

final espRankingRepositoryProvider = Provider<IEspRankingRepository>((ref) {
  return RankingRepository(ref.read(rankingLocalDataSourceProvider));
});