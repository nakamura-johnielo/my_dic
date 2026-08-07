import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/core/shared/enums/word/part_of_speech.dart';

class LoadRankingsInputData {
  final List<int> currentPage;
  final int pagenation;
  final int size;
  final Map<PartOfSpeech, int> partOfSpeechFilters;
  final Map<FeatureTag, int> featureTagFilters;
  final bool isNext;

  const LoadRankingsInputData(
    this.partOfSpeechFilters,
    this.featureTagFilters,
    this.currentPage,
    this.size,
    this.isNext,
    this.pagenation,
  );
}
