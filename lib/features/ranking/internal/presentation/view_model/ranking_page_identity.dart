import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/features/ranking/port/ranking.dart';

final class RankingPageIdentity {
  const RankingPageIdentity({
    required this.sessionKey,
    required this.filter,
    required this.page,
    required this.size,
  });

  final SessionScopeKey sessionKey;
  final RankingFilter filter;
  final int page;
  final int size;

  @override
  bool operator ==(Object other) =>
      other is RankingPageIdentity &&
      other.sessionKey == sessionKey &&
      other.filter == filter &&
      other.page == page &&
      other.size == size;

  @override
  int get hashCode => Object.hash(sessionKey, filter, page, size);
}

final class RankingRequestToken {
  const RankingRequestToken({
    required this.generation,
    required this.pageIdentity,
    required this.attempt,
  });

  final int generation;
  final RankingPageIdentity pageIdentity;
  final int attempt;

  @override
  bool operator ==(Object other) =>
      other is RankingRequestToken &&
      other.generation == generation &&
      other.pageIdentity == pageIdentity &&
      other.attempt == attempt;

  @override
  int get hashCode => Object.hash(generation, pageIdentity, attempt);
}
