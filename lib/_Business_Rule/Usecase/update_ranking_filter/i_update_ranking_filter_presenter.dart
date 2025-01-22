import 'package:my_dic/_Business_Rule/Usecase/update_ranking_filter/update_ranking_filter_output_data.dart';

abstract class IUpdateRankingFilterPresenter {
  void addPartOfSpeechFilter(AddPartOfSpeechFilterOutputData data);
  void deletePartOfSpeechFilter(DeletePartOfSpeechFilterOutputData data);

  void addFeatureTagFilter(AddFeatureTagFilterOutputData data);
  void deleteFeatureTagFilter(DeleteFeatureTagFilterOutputData data);
}
