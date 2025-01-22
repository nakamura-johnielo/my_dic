import 'package:my_dic/Constants/Enums/feature_tag.dart';
import 'package:my_dic/Constants/Enums/part_of_speech.dart';

class SetRankingItemsInputData {
  int page;
  int size;
  Set<PartOfSpeech> partOfSpeechFilters;
  Set<FeatureTag> featureTagFilters;

  SetRankingItemsInputData(
      this.partOfSpeechFilters, this.featureTagFilters, this.page, this.size);
}
