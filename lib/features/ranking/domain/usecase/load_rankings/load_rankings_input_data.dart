import 'package:my_dic/core/common/enums/feature_tag.dart';
import 'package:my_dic/core/common/enums/word/part_of_speech.dart';

class LoadRankingsInputData {
  List<int> currentPage;
  int pagenation;
  int size;
  Map<PartOfSpeech, int> partOfSpeechFilters;
  Map<FeatureTag, int> featureTagFilters;
  bool isNext;

  LoadRankingsInputData(this.partOfSpeechFilters, this.featureTagFilters,
      this.currentPage, this.size, this.isNext, this.pagenation);
}
