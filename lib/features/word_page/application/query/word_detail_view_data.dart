import 'package:my_dic/core/domain/entity/dictionary/esj_dictionary.dart';
import 'package:my_dic/core/domain/entity/jpn_esp/jpn_esp_dictionary.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacions.dart';

/// Complete, screen-ready catalog content for a word-detail page.
sealed class WordDetailViewData {
  const WordDetailViewData();
}

class EspJpnWordDetailViewData extends WordDetailViewData {
  EspJpnWordDetailViewData({
    required List<EspJpnDictionary> dictionaries,
    this.conjugation,
  }) : dictionaries = List.unmodifiable(dictionaries);

  /// Full catalog entries, including nested examples, idioms, and supplements.
  final List<EspJpnDictionary> dictionaries;
  final EspConjugacions? conjugation;
}

class JpnEspWordDetailViewData extends WordDetailViewData {
  JpnEspWordDetailViewData({required List<JpnEspDictionary> dictionaries})
      : dictionaries = List.unmodifiable(dictionaries);

  /// Full catalog entries, including nested examples.
  final List<JpnEspDictionary> dictionaries;
}
