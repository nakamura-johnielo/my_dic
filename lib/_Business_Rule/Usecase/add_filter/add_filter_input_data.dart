import 'package:my_dic/Constants/Enums/feature_tag.dart';
import 'package:my_dic/Constants/Enums/i_enum.dart';
import 'package:my_dic/Constants/Enums/part_of_speech.dart';

class AddFilterInputData<T extends DisplayEnumMixin> {
  int page;
  int size;
  Set<PartOfSpeech> partOfSpeechFilters;
  Set<FeatureTag> featureTagFilters;

  AddFilterInputData(
      this.partOfSpeechFilters, this.featureTagFilters, this.page, this.size);
}
