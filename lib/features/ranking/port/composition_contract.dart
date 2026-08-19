import 'package:my_dic/features/ranking/port/ranking.dart';

/// 1 つのアプリケーションスコープにおける完成済み Ranking 機能。
final class RankingPorts {
  const RankingPorts({required this.reader});

  final RankingPageQueryPort reader;
}
