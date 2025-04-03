import 'package:my_dic/_Business_Rule/Usecase/load_rankings/load_rankings_input_data.dart';

abstract class ILoadRankingsUseCase {
  Future<void> execute(LoadRankingsInputData input);
}
