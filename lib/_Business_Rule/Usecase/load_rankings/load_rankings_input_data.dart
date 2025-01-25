import 'package:my_dic/Constants/Enums/feature_tag.dart';
import 'package:my_dic/Constants/Enums/part_of_speech.dart';

class LoadRankingsInputData {
  List<int> currentPage;
  int pagenation;
  int size;
  Set<PartOfSpeech> partOfSpeechFilters;
  Set<FeatureTag> featureTagFilters;
  bool isNext;

  LoadRankingsInputData(this.partOfSpeechFilters, this.featureTagFilters,
      this.currentPage, this.size, this.isNext, this.pagenation);
}
