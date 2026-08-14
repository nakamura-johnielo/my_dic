import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/ranking/port/composition.dart';
import 'package:my_dic/integration/catalog_ranking/catalog_ranking_providers.dart';
import 'package:my_dic/integration/word_status_ranking/word_status_ranking_providers.dart';

final rankingPortsProvider = Provider<RankingPorts>(
  (ref) => createRankingComposition(
    dependencies: RankingDependencies(
      catalogGateway: ref.watch(rankingCatalogGatewayProvider),
      wordStatusGateway: ref.watch(rankingWordStatusGatewayProvider),
    ),
  ),
);
