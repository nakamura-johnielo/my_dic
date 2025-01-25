import 'package:my_dic/_Business_Rule/Usecase/load_rankings/load_rankings_output_data.dart';

abstract class ILoadRankingsPresenter {
  void execute(LoadRankingsOutputData input);
  void handleNext(LoadRankingsOutputData input);
  void handlePrevious(LoadRankingsOutputData input);
}
