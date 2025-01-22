import 'package:my_dic/Constants/Enums/feature_tag.dart';
import 'package:my_dic/Constants/Enums/part_of_speech.dart';

class AddFilterRepositoryInputData {
  int page;
  int size;
  Set<PartOfSpeech> partOfSpeechFilters;
  Set<FeatureTag> featureTagFilters;

  AddFilterRepositoryInputData(
      this.partOfSpeechFilters, this.featureTagFilters, this.page, this.size);
}
