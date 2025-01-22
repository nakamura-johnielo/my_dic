import 'package:my_dic/Constants/Enums/i_enum.dart';

class AddPartOfSpeechFilterOutputData extends UpdateRankingFilterOutputData {
  AddPartOfSpeechFilterOutputData(super.data);
}

class DeletePartOfSpeechFilterOutputData extends UpdateRankingFilterOutputData {
  DeletePartOfSpeechFilterOutputData(super.data);
}

class AddFeatureTagFilterOutputData extends UpdateRankingFilterOutputData {
  AddFeatureTagFilterOutputData(super.data);
}

class DeleteFeatureTagFilterOutputData extends UpdateRankingFilterOutputData {
  DeleteFeatureTagFilterOutputData(super.data);
}

abstract class UpdateRankingFilterOutputData {
  DisplayEnumMixin data;
  UpdateRankingFilterOutputData(this.data);
}
