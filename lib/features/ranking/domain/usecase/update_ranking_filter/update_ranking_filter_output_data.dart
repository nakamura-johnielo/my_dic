import 'package:my_dic/core/common/enums/i_enum.dart';

class AddPartOfSpeechFilterOutputData extends IUpdateRankingFilterOutputData {
  AddPartOfSpeechFilterOutputData(super.data, super.filterType);
}

class DeletePartOfSpeechFilterOutputData extends IUpdateRankingFilterOutputData {
  DeletePartOfSpeechFilterOutputData(super.data, super.filterType);
}

class AddFeatureTagFilterOutputData extends IUpdateRankingFilterOutputData {
  AddFeatureTagFilterOutputData(super.data, super.filterType);
}

class DeleteFeatureTagFilterOutputData extends IUpdateRankingFilterOutputData {
  DeleteFeatureTagFilterOutputData(super.data, super.filterType);
}

abstract class IUpdateRankingFilterOutputData {
  DisplayEnumMixin data;
  int filterType;
  IUpdateRankingFilterOutputData(this.data, this.filterType);
}

class UpdateRankingFilterOutputData {
  final DisplayEnumMixin data;
  final int value; // 0: none, 1: include, -1: exclude

  UpdateRankingFilterOutputData(this.data, this.value);
}