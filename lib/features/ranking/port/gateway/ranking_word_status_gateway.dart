import 'dart:collection';

import 'package:my_dic/core/shared/errors/app_error.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/ranking/port/model/ranking_account_scope.dart';

final class RankingWordStatusBatchQuery {
  RankingWordStatusBatchQuery({
    required this.scope,
    required Iterable<CatalogWordRef> words,
  }) : words = List.unmodifiable(LinkedHashSet<CatalogWordRef>.of(words));

  final RankingAccountScope scope;
  final List<CatalogWordRef> words;
}

final class RankingWordStatusFact {
  const RankingWordStatusFact({
    required this.word,
    required this.isLearned,
    required this.isBookmarked,
    required this.hasNote,
  });

  const RankingWordStatusFact.initial(this.word)
      : isLearned = false,
        isBookmarked = false,
        hasNote = false;

  final CatalogWordRef word;
  final bool isLearned;
  final bool isBookmarked;
  final bool hasNote;
}

final class RankingWordStatusBatch {
  RankingWordStatusBatch(Iterable<RankingWordStatusFact> facts)
      : _byWord = Map.unmodifiable({for (final fact in facts) fact.word: fact});

  RankingWordStatusBatch.empty() : _byWord = const {};

  final Map<CatalogWordRef, RankingWordStatusFact> _byWord;

  Map<CatalogWordRef, RankingWordStatusFact> get byWord =>
      UnmodifiableMapView(_byWord);

  RankingWordStatusFact? statusFor(CatalogWordRef word) => _byWord[word];
}

enum RankingWordStatusGatewayFailureKind {
  unavailable,
  unsupportedCatalog,
  invalidData,
  unexpected,
}

final class RankingWordStatusGatewayError extends AppError {
  const RankingWordStatusGatewayError({
    required this.kind,
    required super.message,
    super.originalError,
    super.stackTrace,
  }) : super(code: 'RANKING_WORD_STATUS_GATEWAY_FAILURE');

  final RankingWordStatusGatewayFailureKind kind;
}

abstract interface class RankingWordStatusGateway {
  Future<Result<RankingWordStatusBatch>> readBatch(
    RankingWordStatusBatchQuery query,
  );
}
