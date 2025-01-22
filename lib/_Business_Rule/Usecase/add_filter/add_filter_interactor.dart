import 'package:my_dic/_Business_Rule/Usecase/add_filter/add_filter_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/add_filter/add_filter_output_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/add_filter/add_filter_repository_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/add_filter/i_add_filter_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/add_filter/i_add_filter_use_case.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/ranking.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_esp_ranking_repository.dart';

class AddFilterInteractor implements IAddFilterUseCase {
  final IAddFilterPresenter _addFilterPresenterImpl;
  final IEspRankingRepository _wikiEspRankingRepository;

  AddFilterInteractor(
      this._addFilterPresenterImpl, this._wikiEspRankingRepository);

  @override
  void execute(AddFilterInputData input) async {
    AddFilterRepositoryInputData data = AddFilterRepositoryInputData(
        input.partOfSpeechFilters,
        input.featureTagFilters,
        input.page,
        input.size);
    /* List<Ranking> resp=await _wikiEspRankingRepository.getRankingListByFilters(data);
    AddFilterOutputData d = AddFilterOutputData(input.filter);
    _addFilterPresenterImpl.execute(d); */
  }
}
