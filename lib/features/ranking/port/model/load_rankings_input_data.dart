import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';

class LoadRankingsInputData {
  /// The zero-based page requested by the presentation layer.
  final int page;
  final int size;
  final Map<CatalogPartOfSpeech, int> partOfSpeechFilters;
  final Map<FeatureTag, int> featureTagFilters;
  final String accountScope;

  const LoadRankingsInputData(
    this.partOfSpeechFilters,
    this.featureTagFilters,
    this.page,
    this.size,
    this.accountScope,
  );
}
