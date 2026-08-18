import 'package:my_dic/features/ranking/port/model/ranking_account_scope.dart';
import 'package:my_dic/features/ranking/port/model/ranking_filter.dart';

/// Validated input for one zero-based Ranking page.
final class RankingPageQuery {
  RankingPageQuery({
    required this.page,
    required this.size,
    required this.scope,
    RankingFilter? filter,
  }) : filter = filter ?? RankingFilter() {
    if (page < 0) {
      throw ArgumentError.value(page, 'page', 'must not be negative');
    }
    if (size <= 0) {
      throw ArgumentError.value(size, 'size', 'must be positive');
    }
  }

  final int page;
  final int size;
  final RankingAccountScope scope;
  final RankingFilter filter;
}
