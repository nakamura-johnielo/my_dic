import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/ranking/port/composition.dart';
import 'package:my_dic/features/ranking/port/ranking.dart';

void main() {
  test('typed dependencies assemble one completed reader capability', () {
    final ports = createRankingComposition(
      dependencies: RankingDependencies(
        catalogGateway: _CatalogGateway(),
        wordStatusGateway: _WordStatusGateway(),
      ),
    );

    expect(ports.reader, isA<RankingPageReaderPort>());
  });
}

final class _CatalogGateway implements RankingCatalogGateway {
  @override
  Future<Result<RankingCatalogChunk>> readChunk(
    RankingCatalogChunkQuery query,
  ) async =>
      Result.success(RankingCatalogChunk(items: const [], hasMore: false));
}

final class _WordStatusGateway implements RankingWordStatusGateway {
  @override
  Future<Result<RankingWordStatusBatch>> readBatch(
    RankingWordStatusBatchQuery query,
  ) async =>
      Result.success(RankingWordStatusBatch.empty());
}
