import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/ranking/domain/entity/ranking.dart';
import 'package:my_dic/features/ranking/domain/i_repository/i_esp_ranking_repository.dart';
import 'package:my_dic/features/ranking/domain/usecase/load_rankings/filtered_ranking_list_input_data.dart';

class FakeEspRankingRepository implements IEspRankingRepository {
  final Result<List<Ranking>> _result;
  
  FilteredRankingListInputData? lastFilteredInput;
  int? lastPage;
  int? lastSize;
  int callCount = 0;
  int filteredCallCount = 0;

  FakeEspRankingRepository({
    required Result<List<Ranking>> result,
  }) : _result = result;

  factory FakeEspRankingRepository.success({List<Ranking>? rankings}) {
    return FakeEspRankingRepository(
      result: Result.success(rankings ?? _defaultRankings()),
    );
  }

  factory FakeEspRankingRepository.databaseError() {
    return FakeEspRankingRepository(
      result: Result.failure(DatabaseError(message: 'Database connection failed')),
    );
  }

  @override
  Future<Result<List<Ranking>>> getRankingList(int page, int size) async {
    callCount++;
    lastPage = page;
    lastSize = size;
    return _result;
  }

  @override
  Future<Result<List<Ranking>>> getRankingListByFilters(
      FilteredRankingListInputData input) async {
    filteredCallCount++;
    lastFilteredInput = input;
    return _result;
  }

  static List<Ranking> _defaultRankings() {
    return [
      const Ranking(
        rank: 1,
        rankedWord: 'ser',
        lemma: 'ser',
        wordId: 1,
        hasConj: true,
        isLearned: false,
        isBookmarked: false,
        hasNote: false,
      ),
      const Ranking(
        rank: 2,
        rankedWord: 'estar',
        lemma: 'estar',
        wordId: 2,
        hasConj: true,
        isLearned: true,
        isBookmarked: false,
        hasNote: false,
      ),
      const Ranking(
        rank: 3,
        rankedWord: 'casa',
        lemma: 'casa',
        wordId: 3,
        hasConj: false,
        isLearned: false,
        isBookmarked: true,
        hasNote: true,
      ),
    ];
  }
}
