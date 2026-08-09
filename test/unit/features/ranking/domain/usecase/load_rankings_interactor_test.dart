import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/features/catalog/port/model/catalog_part_of_speech.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/ranking/application/query/i_ranking_query_repository.dart';
import 'package:my_dic/features/ranking/application/query/ranking_list_item.dart';
import 'package:my_dic/features/ranking/application/query/ranking_page.dart';
import 'package:my_dic/features/ranking/application/query/ranking_query.dart';
import 'package:my_dic/features/ranking/application/usecase/load_rankings/load_rankings_input_data.dart';
import 'package:my_dic/features/ranking/application/usecase/load_rankings/load_rankings_interactor.dart';

import '../../../../../helpers/fake_current_session.dart';

void main() {
  group('LoadRankingsInteractor', () {
    test('maps filters and authenticated account to a RankingQuery', () async {
      final repository = _FakeRankingQueryRepository();
      final interactor = LoadRankingsInteractor(
        repository,
        FakeCurrentSession(accountIdOrNull: 'account-a'),
      );

      await interactor.execute(LoadRankingsInputData(
        {CatalogPartOfSpeech.noun: 1, CatalogPartOfSpeech.verb: -1},
        {FeatureTag.isLearned: 1, FeatureTag.hasNote: -1},
        0,
        20,
      ));

      expect(repository.lastQuery?.page, 0);
      expect(repository.lastQuery?.size, 20);
      expect(repository.lastQuery?.accountId, 'account-a');
      expect(repository.lastQuery?.includedPartOfSpeech,
          {CatalogPartOfSpeech.noun});
      expect(repository.lastQuery?.excludedPartOfSpeech,
          {CatalogPartOfSpeech.verb});
      expect(repository.lastQuery?.includedFeatureTags, {FeatureTag.isLearned});
      expect(repository.lastQuery?.excludedFeatureTags, {FeatureTag.hasNote});
    });

    test('uses the guest account scope when no session is available', () async {
      final repository = _FakeRankingQueryRepository();
      final interactor =
          LoadRankingsInteractor(repository, FakeCurrentSession());

      await interactor.execute(LoadRankingsInputData(
        const {},
        const {},
        0,
        20,
      ));

      expect(repository.lastQuery?.accountId, guestAccountScope);
    });

    test('returns the port page and propagates its failure', () async {
      final repository = _FakeRankingQueryRepository(
        result: Result.failure(DatabaseError(message: 'database unavailable')),
      );
      final interactor =
          LoadRankingsInteractor(repository, FakeCurrentSession());

      final result = await interactor.execute(LoadRankingsInputData(
        const {},
        const {},
        0,
        20,
      ));

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<DatabaseError>());
    });
  });
}

class _FakeRankingQueryRepository implements IRankingQueryRepository {
  _FakeRankingQueryRepository({Result<RankingPage>? result})
      : _result = result ??
            Result.success(RankingPage(
              items: const [
                RankingListItem(
                  rank: 1,
                  rankedWord: 'ser',
                  lemma: 'ser',
                  wordId: 1,
                  hasConjugation: true,
                ),
              ],
              hasNext: false,
            ));

  final Result<RankingPage> _result;
  RankingQuery? lastQuery;

  @override
  Future<Result<RankingPage>> fetchPage(RankingQuery query) async {
    lastQuery = query;
    return _result;
  }
}
