import 'package:my_dic/features/catalog/port/model/catalog_part_of_speech.dart';

class EspJpnWord {
  final int wordId;
  final String word;
  final List<CatalogPartOfSpeech> partOfSpeech;

  const EspJpnWord({
    required this.wordId,
    required this.word,
    required this.partOfSpeech,
  });

  bool hasVerb() => partOfSpeech.contains(CatalogPartOfSpeech.verb);

  EspJpnWord copyWith({
    int? wordId,
    String? word,
    List<CatalogPartOfSpeech>? partOfSpeech,
  }) {
    return EspJpnWord(
      wordId: wordId ?? this.wordId,
      word: word ?? this.word,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
    );
  }
}
