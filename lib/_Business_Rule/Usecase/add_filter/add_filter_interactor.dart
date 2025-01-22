import 'package:my_dic/_Business_Rule/Usecase/add_filter/add_filter_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/add_filter/add_filter_output_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/add_filter/i_add_filter_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/add_filter/i_add_filter_use_case.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_esp_ranking_repository.dart';

class AddFilterInteractor implements IAddFilterUseCase {
  final IAddFilterPresenter _addFilterPresenterImpl;
  final IEspRankingRepository _espRankingRepository;

  AddFilterInteractor(this._addFilterPresenterImpl, this._espRankingRepository);

  @override
  void execute(AddFilterInputData input) {
    _espRankingRepository.getRankingListByFilters(input);
    /* AddFilterOutputData d = AddFilterOutputData(input.filter);
    _addFilterPresenterImpl.execute(d); */
  }
}
