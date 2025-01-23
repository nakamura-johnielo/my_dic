import 'package:my_dic/Constants/Enums/feature_tag.dart';
import 'package:my_dic/Constants/Enums/part_of_speech.dart';

class LoadRankingsInputData {
  int currentPage;
  int size;
  Set<PartOfSpeech> partOfSpeechFilters;
  Set<FeatureTag> featureTagFilters;

  LoadRankingsInputData(this.partOfSpeechFilters, this.featureTagFilters,
      this.currentPage, this.size);
}
