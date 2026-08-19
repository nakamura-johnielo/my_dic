import 'package:my_dic/features/ranking/internal/composition/ranking_composition_factory.dart';
import 'package:my_dic/features/ranking/port/composition_contract.dart';
import 'package:my_dic/features/ranking/port/ranking.dart';

export 'composition_contract.dart';

/// 1 つの完成済み Ranking アプリケーションスコープに必要なゲートウェイ。
final class RankingDependencies {
  const RankingDependencies({
    required this.catalogGateway,
    required this.wordStatusGateway,
  });

  final RankingCatalogGateway catalogGateway;
  final RankingWordStatusGateway wordStatusGateway;
}

RankingPorts createRankingComposition({
  required RankingDependencies dependencies,
}) =>
    createInternalRankingPorts(
      catalogGateway: dependencies.catalogGateway,
      wordStatusGateway: dependencies.wordStatusGateway,
    );
