import 'package:my_dic/_Business_Rule/Usecase/add_filter/add_filter_repository_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/set_ranking_items/filtered_ranking_list_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/set_ranking_items/set_ranking_items_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/set_ranking_items/set_ranking_items_output_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/set_ranking_items/i_set_ranking_items_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/set_ranking_items/i_set_ranking_items_use_case.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/ranking.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_esp_ranking_repository.dart';

class SetRankingItemsInteractor implements ISetRankingItemsUseCase {
  final ISetRankingItemsPresenter _setRankingItemsPresenterImpl;
  final IEspRankingRepository _wikiEspRankingRepository;

  SetRankingItemsInteractor(
      this._setRankingItemsPresenterImpl, this._wikiEspRankingRepository);

  @override
  void execute(SetRankingItemsInputData input) async {
    FilteredRankingListInputData inputData = FilteredRankingListInputData(
        input.partOfSpeechFilters,
        input.featureTagFilters,
        input.page,
        input.size);

    List<Ranking> resp =
        await _wikiEspRankingRepository.getRankingListByFilters(inputData);

    SetRankingItemsOutputData outputData =
        SetRankingItemsOutputData(resp, inputData.page);
    _setRankingItemsPresenterImpl.execute(outputData);
  }
}
