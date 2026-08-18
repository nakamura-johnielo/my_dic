import 'package:my_dic/features/ranking/internal/application/ranking_application_service.dart';
import 'package:my_dic/features/ranking/port/composition_contract.dart';
import 'package:my_dic/features/ranking/port/ranking.dart';

RankingPorts createInternalRankingPorts({
  required RankingCatalogGateway catalogGateway,
  required RankingWordStatusGateway wordStatusGateway,
}) =>
    RankingPorts(
      reader: RankingApplicationService(
        catalog: catalogGateway,
        wordStatus: wordStatusGateway,
      ),
    );
