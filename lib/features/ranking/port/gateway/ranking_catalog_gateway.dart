import 'package:my_dic/core/shared/errors/app_error.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/ranking/port/model/ranking_item_id.dart';
import 'package:my_dic/features/ranking/port/model/ranking_part_of_speech.dart';

final class RankingCatalogChunkQuery {
  RankingCatalogChunkQuery({required this.offset, required this.size}) {
    if (offset < 0) {
      throw ArgumentError.value(offset, 'offset', 'must not be negative');
    }
    if (size <= 0) {
      throw ArgumentError.value(size, 'size', 'must be positive');
    }
  }

  final int offset;
  final int size;
}

final class RankingCatalogEntry {
  RankingCatalogEntry({
    required this.id,
    required this.word,
    required this.rank,
    required this.rankedWord,
    required this.lemma,
    required Iterable<RankingPartOfSpeech> partsOfSpeech,
    required this.hasConjugation,
  }) : partsOfSpeech = Set.unmodifiable(partsOfSpeech) {
    if (rank <= 0) {
      throw ArgumentError.value(rank, 'rank', 'must be positive');
    }
    if (rankedWord.isEmpty) {
      throw ArgumentError.value(rankedWord, 'rankedWord', 'must not be empty');
    }
    if (lemma.isEmpty) {
      throw ArgumentError.value(lemma, 'lemma', 'must not be empty');
    }
  }

  final RankingItemId id;
  final CatalogWordRef word;
  final int rank;
  final String rankedWord;
  final String lemma;
  final Set<RankingPartOfSpeech> partsOfSpeech;
  final bool hasConjugation;
}

final class RankingCatalogChunk {
  RankingCatalogChunk({required Iterable<RankingCatalogEntry> items,
    required this.hasMore})
      : items = List.unmodifiable(items);

  final List<RankingCatalogEntry> items;
  final bool hasMore;
}

enum RankingCatalogGatewayFailureKind { unavailable, invalidData, unexpected }

final class RankingCatalogGatewayError extends AppError {
  const RankingCatalogGatewayError({
    required this.kind,
    required super.message,
    super.originalError,
    super.stackTrace,
  }) : super(code: 'RANKING_CATALOG_GATEWAY_FAILURE');

  final RankingCatalogGatewayFailureKind kind;
}

abstract interface class RankingCatalogGateway {
  Future<Result<RankingCatalogChunk>> readChunk(
    RankingCatalogChunkQuery query,
  );
}
