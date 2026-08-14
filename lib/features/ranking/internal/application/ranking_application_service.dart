import 'package:my_dic/features/ranking/port/ranking.dart';

const int _defaultSourceChunkSize = 100;

/// Ranking-owned orchestration for filtering and offset page formation.
final class RankingApplicationService implements RankingPageReaderPort {
  RankingApplicationService({
    required RankingCatalogGateway catalog,
    required RankingWordStatusGateway wordStatus,
    int sourceChunkSize = _defaultSourceChunkSize,
  })  : _catalog = catalog,
        _wordStatus = wordStatus,
        _sourceChunkSize = sourceChunkSize {
    if (sourceChunkSize <= 0) {
      throw ArgumentError.value(
        sourceChunkSize,
        'sourceChunkSize',
        'must be positive',
      );
    }
  }

  final RankingCatalogGateway _catalog;
  final RankingWordStatusGateway _wordStatus;
  final int _sourceChunkSize;

  @override
  Future<Result<RankingPage>> readPage(RankingPageQuery query) async {
    final pageOffset = query.page * query.size;
    final requiredAcceptedCount = pageOffset + query.size + 1;
    final accepted = <RankingItem>[];
    final groupedWords = <CatalogWordRef>{};
    final sourceIds = <RankingItemId>{};
    RankingCatalogEntry? previousSourceEntry;
    var sourceOffset = 0;

    try {
      while (accepted.length < requiredAcceptedCount) {
        final catalogResult = await _catalog.readChunk(
          RankingCatalogChunkQuery(
            offset: sourceOffset,
            size: _sourceChunkSize,
          ),
        );
        if (catalogResult case Failure<RankingCatalogChunk>(:final error)) {
          return Result.failure(_catalogError(error));
        }
        final chunk = catalogResult.dataOrNull!;
        if (chunk.items.isEmpty && chunk.hasMore) {
          return const Result.failure(RankingReadError.invalidSourceItem());
        }

        final candidates = <RankingCatalogEntry>[];
        for (final entry in chunk.items) {
          if (!_isAfter(previousSourceEntry, entry) ||
              !sourceIds.add(entry.id)) {
            return const Result.failure(RankingReadError.invalidSourceItem());
          }
          previousSourceEntry = entry;
          if (!_matchesPartOfSpeech(entry, query.filter)) continue;
          if (query.filter.groupByCatalogWord &&
              !groupedWords.add(entry.word)) {
            continue;
          }
          candidates.add(entry);
        }

        RankingWordStatusBatch? statusBatch;
        if (_hasStatusFilter(query.filter) && candidates.isNotEmpty) {
          final statusResult = await _wordStatus.readBatch(
            RankingWordStatusBatchQuery(
              scope: query.scope,
              words: candidates.map((entry) => entry.word),
            ),
          );
          if (statusResult case Failure<RankingWordStatusBatch>(:final error)) {
            return Result.failure(_wordStatusError(error));
          }
          statusBatch = statusResult.dataOrNull!;
        }

        for (final entry in candidates) {
          final status = statusBatch?.statusFor(entry.word) ??
              RankingWordStatusFact.initial(entry.word);
          if (!_matchesStatus(status, query.filter)) continue;
          accepted.add(_item(entry));
          if (accepted.length == requiredAcceptedCount) break;
        }

        sourceOffset += chunk.items.length;
        if (!chunk.hasMore) break;
      }

      final hasMore = accepted.length > pageOffset + query.size;
      return Result.success(
        RankingPage(
          items: accepted.skip(pageOffset).take(query.size),
          hasMore: hasMore,
        ),
      );
    } catch (error, stackTrace) {
      return Result.failure(
        RankingReadError.unexpected(
          originalError: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}

bool _isAfter(
  RankingCatalogEntry? previous,
  RankingCatalogEntry current,
) {
  if (previous == null) return true;
  if (current.rank != previous.rank) return current.rank > previous.rank;
  return current.id.toSerialized() > previous.id.toSerialized();
}

bool _matchesPartOfSpeech(
  RankingCatalogEntry entry,
  RankingFilter filter,
) {
  if (filter.includedPartsOfSpeech.isNotEmpty &&
      !entry.partsOfSpeech.any(filter.includedPartsOfSpeech.contains)) {
    return false;
  }
  if (entry.partsOfSpeech.any(filter.excludedPartsOfSpeech.contains)) {
    return false;
  }
  return true;
}

bool _hasStatusFilter(RankingFilter filter) =>
    filter.includedStatuses.isNotEmpty || filter.excludedStatuses.isNotEmpty;

bool _matchesStatus(
  RankingWordStatusFact status,
  RankingFilter filter,
) {
  bool selected(RankingStatusFilter value) => switch (value) {
        RankingStatusFilter.learned => status.isLearned,
        RankingStatusFilter.bookmarked => status.isBookmarked,
        RankingStatusFilter.hasNote => status.hasNote,
      };

  if (filter.includedStatuses.isNotEmpty &&
      !filter.includedStatuses.any(selected)) {
    return false;
  }
  if (filter.excludedStatuses.any(selected)) return false;
  return true;
}

RankingItem _item(RankingCatalogEntry entry) => RankingItem(
      id: entry.id,
      word: entry.word,
      rank: entry.rank,
      rankedWord: entry.rankedWord,
      lemma: entry.lemma,
      hasConjugation: entry.hasConjugation,
    );

RankingReadError _catalogError(Object error) {
  if (error is! RankingCatalogGatewayError) {
    return RankingReadError.unexpected(originalError: error);
  }
  return switch (error.kind) {
    RankingCatalogGatewayFailureKind.unavailable =>
      RankingReadError.catalogUnavailable(originalError: error),
    RankingCatalogGatewayFailureKind.invalidData =>
      RankingReadError.invalidSourceItem(originalError: error),
    RankingCatalogGatewayFailureKind.unexpected =>
      RankingReadError.unexpected(originalError: error),
  };
}

RankingReadError _wordStatusError(Object error) {
  if (error is! RankingWordStatusGatewayError) {
    return RankingReadError.unexpected(originalError: error);
  }
  return switch (error.kind) {
    RankingWordStatusGatewayFailureKind.unavailable ||
    RankingWordStatusGatewayFailureKind.unsupportedCatalog ||
    RankingWordStatusGatewayFailureKind.invalidData =>
      RankingReadError.wordStatusUnavailable(originalError: error),
    RankingWordStatusGatewayFailureKind.unexpected =>
      RankingReadError.unexpected(originalError: error),
  };
}
