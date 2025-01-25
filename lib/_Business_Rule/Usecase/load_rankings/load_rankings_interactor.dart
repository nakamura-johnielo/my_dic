import 'package:my_dic/_Business_Rule/Usecase/add_filter/add_filter_repository_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_rankings/filtered_ranking_list_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_rankings/load_rankings_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_rankings/load_rankings_output_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_rankings/i_load_rankings_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/load_rankings/i_load_rankings_use_case.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/ranking.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_esp_ranking_repository.dart';

class LoadRankingsInteractor implements ILoadRankingsUseCase {
  final ILoadRankingsPresenter _loadRankingsPresenterImpl;
  final IEspRankingRepository _wikiEspRankingRepository;

  LoadRankingsInteractor(
      this._loadRankingsPresenterImpl, this._wikiEspRankingRepository);

  int _getOffset(int pagenation, int size) {
    return pagenation ~/ size; //商のみ
  }

  @override
  void execute(LoadRankingsInputData input) async {
    List<int> requiredPages = [input.currentPage[0], input.currentPage[1]];
    int offset = input.pagenation; // getOffset(input.pagenation, input.size);
    /* if ((offset < requiredPages[0] || -1 == requiredPages[0]) ||
        requiredPages[1] < offset) */
    if (requiredPages[0] <= offset && offset <= requiredPages[1]) {
      if (input.isNext) {
        requiredPages[1] += 1;
      } else {
        requiredPages[0] -= 1;
      }
    } else {
      requiredPages[0] = offset;
      requiredPages[1] = offset;
    }

    /* if (input.isNext) {
      if (offset <= requiredPages[1]) {
        requiredPages[1] += 1;
      } else {
        requiredPages[1] = offset;
        requiredPages[0] = offset;
      }
    } else {
      if (offset >= requiredPages[0]) {
        requiredPages[0] -= 1;
      } else {
        requiredPages[0] = offset;
        requiredPages[1] = offset;
      }
    } */

    FilteredRankingListInputData inputData = FilteredRankingListInputData(
        input.partOfSpeechFilters,
        input.featureTagFilters,
        input.isNext
            ? requiredPages[1]
            : requiredPages[0], //current -> required
        input.size);

    List<Ranking> resp =
        await _wikiEspRankingRepository.getRankingListByFilters(inputData);

    LoadRankingsOutputData outputData =
        LoadRankingsOutputData(resp, requiredPages);
    if (input.isNext) {
      _loadRankingsPresenterImpl.handleNext(outputData);
      return;
    }
    _loadRankingsPresenterImpl.handlePrevious(outputData);
  }
}
