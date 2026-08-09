import 'package:my_dic/features/catalog/port/model/catalog_part_of_speech.dart';

/// Ranking-owned presentation labels for Catalog part-of-speech values.
extension RankingPartOfSpeechLabels on CatalogPartOfSpeech {
  String get displayLabel => wireValue;
}
