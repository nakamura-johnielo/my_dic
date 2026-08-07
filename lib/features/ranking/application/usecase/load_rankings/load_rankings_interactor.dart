import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/core/shared/enums/word/part_of_speech.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/ranking/application/usecase/load_rankings/i_load_rankings_use_case.dart';
import 'package:my_dic/features/ranking/application/usecase/load_rankings/load_rankings_input_data.dart';
import 'package:my_dic/features/ranking/domain/entity/ranking.dart';
import 'package:my_dic/features/ranking/domain/i_repository/i_esp_ranking_repository.dart';

class LoadRankingsInteractor implements ILoadRankingsUseCase {
  LoadRankingsInteractor(this._repository);

  final IEspRankingRepository _repository;

  @override
  Future<Result<List<Ranking>>> execute(LoadRankingsInputData input) {
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
    return _repository.getRankingListByFilters(
      requiredPage,
      input.size,
      partOfSpeechFilters,
      featureTagFilters,
      partOfSpeechExcludeFilters,
      featureTagExcludeFilters,
    );
  }
}
