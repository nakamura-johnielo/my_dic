import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/ranking/port/ranking.dart';
import 'package:my_dic/features/word_status/port/word_status.dart';
import 'package:my_dic/integration/word_status_ranking/word_status_backed_ranking_gateway.dart';

void main() {
  test('maps account scope and preserves provider batch absence', () async {
    final reader = _WordStatusBatchReader(
      Result.success(
        WordStatusBatch([
          WordStatus(
            word: _word(1),
            isLearned: true,
            isBookmarked: false,
            hasNote: true,
            updatedAt: DateTime.utc(2026),
          ),
        ]),
      ),
    );
    final gateway = WordStatusBackedRankingGateway(reader);

    final result = await gateway.readBatch(
      RankingWordStatusBatchQuery(
        scope: RankingAccountScope.account('account-a'),
        words: [_word(1), _word(2)],
      ),
    );

    expect(
      reader.query?.scope,
      WordStatusScope.account('account-a'),
    );
    expect(result.dataOrNull?.statusFor(_word(1))?.isLearned, isTrue);
    expect(result.dataOrNull?.statusFor(_word(2)), isNull);
  });

  test('maps guest scope and typed provider failure', () async {
    final reader = _WordStatusBatchReader(
      const Result.failure(WordStatusReadError.storage()),
    );
    final gateway = WordStatusBackedRankingGateway(reader);

    final result = await gateway.readBatch(
      RankingWordStatusBatchQuery(
        scope: const RankingAccountScope.guest(),
        words: [_word(1)],
      ),
    );

    expect(reader.query?.scope, const WordStatusScope.guest());
    expect(
      (result.errorOrNull as RankingWordStatusGatewayError).kind,
      RankingWordStatusGatewayFailureKind.unavailable,
    );
  });
}

CatalogWordRef _word(int id) => CatalogWordRef(
      catalogId: CatalogId.espJpnMain,
      wordId: id,
    );

final class _WordStatusBatchReader implements WordStatusBatchReaderPort {
  _WordStatusBatchReader(this.result);

  final Result<WordStatusBatch> result;
  ReadWordStatusBatchQuery? query;

  @override
  Future<Result<WordStatusBatch>> readBatch(
    ReadWordStatusBatchQuery query,
  ) async {
    this.query = query;
    return result;
  }
}
