import 'package:my_dic/_Business_Rule/Usecase/simple_load_rankings22/i_load_rankings_presenter.dart';
import 'package:my_dic/_Business_Rule/Usecase/simple_load_rankings22/i_load_rankings_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/simple_load_rankings22/load_rankings_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/simple_load_rankings22/load_rankings_output_data.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/ranking.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_esp_ranking_repository.dart';

class LoadRankingsInteractor implements ILoadRankingsUseCase {
  final IEspRankingRepository _espRankingRepository;
  final ILoadRankingsPresenter _rankingsPresenter;

  LoadRankingsInteractor(this._espRankingRepository, this._rankingsPresenter);

  @override
  void execute(LoadRankingsInputData input) async {
    List<Ranking> res =
        await _espRankingRepository.getRankingList(input.page, input.size);
    LoadRankingsOutputData output = LoadRankingsOutputData(res);
    _rankingsPresenter.execute(output);
  }
}
