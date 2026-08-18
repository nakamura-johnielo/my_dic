import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/feature_composition/catalog_composition.dart';
import 'package:my_dic/features/ranking/port/ranking.dart';
import 'package:my_dic/integration/catalog_ranking/catalog_backed_ranking_gateway.dart';

final rankingCatalogGatewayProvider = Provider<RankingCatalogGateway>(
  (ref) => CatalogBackedRankingGateway(
    ref.watch(catalogQueryPortsProvider).rankedEntries,
  ),
);
