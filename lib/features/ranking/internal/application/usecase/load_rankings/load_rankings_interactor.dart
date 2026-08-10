import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/features/catalog/port/model/catalog_part_of_speech.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/ranking/internal/application/usecase/load_rankings/i_load_rankings_use_case.dart';
import 'package:my_dic/features/ranking/port/model/ranking_page.dart';
import 'package:my_dic/features/ranking/port/model/ranking_query.dart';
import 'package:my_dic/features/ranking/port/model/load_rankings_input_data.dart';
import 'package:my_dic/features/ranking/port/ranking_query_repository.dart';

class LoadRankingsInteractor implements ILoadRankingsUseCase {
  LoadRankingsInteractor(this._repository);

  final IRankingQueryRepository _repository;

  @override
  Future<Result<RankingPage>> execute(LoadRankingsInputData input) {
    final partOfSpeechFilters = <CatalogPartOfSpeech>{};
    final partOfSpeechExcludeFilters = <CatalogPartOfSpeech>{};
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

    return _repository.fetchPage(RankingQuery(
      page: input.page,
      size: input.size,
      accountId: input.accountScope,
      includedPartOfSpeech: partOfSpeechFilters,
      excludedPartOfSpeech: partOfSpeechExcludeFilters,
      includedFeatureTags: featureTagFilters,
      excludedFeatureTags: featureTagExcludeFilters,
    ));
  }
}
