import 'package:my_dic/_Business_Rule/Usecase/update_ranking_filter/update_ranking_filter_output_data.dart';

abstract class IUpdateRankingFilterPresenter {
  void setPartOfSpeechFilter(AddPartOfSpeechFilterOutputData data);
  void deletePartOfSpeechFilter(DeletePartOfSpeechFilterOutputData data);

  void setFeatureTagFilter(AddFeatureTagFilterOutputData data);
  void deleteFeatureTagFilter(DeleteFeatureTagFilterOutputData data);
}
