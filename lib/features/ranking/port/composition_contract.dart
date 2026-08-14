import 'package:my_dic/features/ranking/port/ranking.dart';

/// Completed Ranking capabilities for one application scope.
final class RankingPorts {
  const RankingPorts({required this.reader});

  final RankingPageReaderPort reader;
}
