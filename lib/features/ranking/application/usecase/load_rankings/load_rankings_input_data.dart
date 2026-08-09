import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/features/catalog/port/model/catalog_part_of_speech.dart';

class LoadRankingsInputData {
  /// The zero-based page requested by the presentation layer.
  final int page;
  final int size;
  final Map<CatalogPartOfSpeech, int> partOfSpeechFilters;
  final Map<FeatureTag, int> featureTagFilters;

  const LoadRankingsInputData(
    this.partOfSpeechFilters,
    this.featureTagFilters,
    this.page,
    this.size,
  );
}
