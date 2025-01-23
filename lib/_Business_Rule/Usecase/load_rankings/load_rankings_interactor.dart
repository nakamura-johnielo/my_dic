import 'package:my_dic/_Business_Rule/Usecase/add_filter/add_filter_repository_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_rankings/filtered_ranking_list_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_rankings/load_rankings_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_rankings/load_rankings_output_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_rankings/i_load_rankings_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_rankings/i_load_rankings_use_case.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/ranking.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_esp_ranking_repository.dart';

class LoadRankingsInteractor implements ILoadRankingsUseCase {
  final ILoadRankingsPresenter _setRankingItemsPresenterImpl;
  final IEspRankingRepository _wikiEspRankingRepository;

  LoadRankingsInteractor(
      this._setRankingItemsPresenterImpl, this._wikiEspRankingRepository);

  @override
  void execute(LoadRankingsInputData input) async {
    FilteredRankingListInputData inputData = FilteredRankingListInputData(
        input.partOfSpeechFilters,
        input.featureTagFilters,
        input.currentPage + 1, //current -> required
        input.size);

    List<Ranking> resp =
        await _wikiEspRankingRepository.getRankingListByFilters(inputData);

    LoadRankingsOutputData outputData =
        LoadRankingsOutputData(resp, inputData.requiredPage);
    _setRankingItemsPresenterImpl.execute(outputData);
  }
}
