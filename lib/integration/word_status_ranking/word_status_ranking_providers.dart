import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/word_status_composition.dart';
import 'package:my_dic/features/ranking/port/ranking.dart';
import 'package:my_dic/integration/word_status_ranking/word_status_backed_ranking_gateway.dart';

final rankingWordStatusGatewayProvider = Provider<RankingWordStatusGateway>(
  (ref) => WordStatusBackedRankingGateway(
    ref.watch(wordStatusPortsProvider).batchReader,
  ),
);
