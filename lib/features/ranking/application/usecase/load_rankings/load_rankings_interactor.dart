import 'package:my_dic/app/session/current_session.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/core/shared/enums/word/part_of_speech.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/ranking/application/usecase/load_rankings/i_load_rankings_use_case.dart';
import 'package:my_dic/features/ranking/application/usecase/load_rankings/load_rankings_input_data.dart';
import 'package:my_dic/features/ranking/application/query/i_ranking_query_repository.dart';
import 'package:my_dic/features/ranking/application/query/ranking_page.dart';
import 'package:my_dic/features/ranking/application/query/ranking_query.dart';

class LoadRankingsInteractor implements ILoadRankingsUseCase {
  LoadRankingsInteractor(this._repository, this._currentSession);

  final IRankingQueryRepository _repository;
  final CurrentSession _currentSession;

  @override
  Future<Result<RankingPage>> execute(LoadRankingsInputData input) {
    final partOfSpeechFilters = <PartOfSpeech>{};
    final partOfSpeechExcludeFilters = <PartOfSpeech>{};
    for (final entry in input.partOfSpeechFilters.entries) {
      if (entry.value == 1) partOfSpeechFilters.add(entry.key);
      if (entry.value == -1) partOfSpeechExcludeFilters.add(entry.key);
    }

    final featureTagFilters = <FeatureTag>{};
    final featureTagExcludeFilters = <FeatureTag>{};
    for (final entry in input.featureTagFilters.entries) {
      if (entry.value == 1) featureTagFilters.add(entry.key);
      if (entry.value == -1) featureTagExcludeFilters.add(entry.key);
    }

    final nextPage = input.currentPage[1] + 1 + input.pagenation;
    final requiredPage = input.isNext ? nextPage : input.currentPage[0];
    return _repository.fetchPage(RankingQuery(
      page: requiredPage,
      size: input.size,
      accountId: _currentSession.accountIdOrNull ?? guestAccountScope,
      includedPartOfSpeech: partOfSpeechFilters,
      excludedPartOfSpeech: partOfSpeechExcludeFilters,
      includedFeatureTags: featureTagFilters,
      excludedFeatureTags: featureTagExcludeFilters,
    ));
  }
}
