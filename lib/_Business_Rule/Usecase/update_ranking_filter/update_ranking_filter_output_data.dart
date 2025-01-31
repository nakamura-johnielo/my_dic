import 'package:my_dic/Constants/Enums/i_enum.dart';

class AddPartOfSpeechFilterOutputData extends UpdateRankingFilterOutputData {
  AddPartOfSpeechFilterOutputData(super.data, super.filterType);
}

class DeletePartOfSpeechFilterOutputData extends UpdateRankingFilterOutputData {
  DeletePartOfSpeechFilterOutputData(super.data, super.filterType);
}

class AddFeatureTagFilterOutputData extends UpdateRankingFilterOutputData {
  AddFeatureTagFilterOutputData(super.data, super.filterType);
}

class DeleteFeatureTagFilterOutputData extends UpdateRankingFilterOutputData {
  DeleteFeatureTagFilterOutputData(super.data, super.filterType);
}

abstract class UpdateRankingFilterOutputData {
  DisplayEnumMixin data;
  int filterType;
  UpdateRankingFilterOutputData(this.data, this.filterType);
}
