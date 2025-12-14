import 'package:flutter/foundation.dart';
import 'package:my_dic/Constants/Enums/part_of_speech.dart';

@immutable
class EspJpnWord {
  final int wordId;
  final String word;
  final List<PartOfSpeech> partOfSpeech;

  const EspJpnWord({
    required this.wordId,
    required this.word,
    required this.partOfSpeech,
  });

  bool hasVerb() {
    return partOfSpeech.contains(PartOfSpeech.verb);
  }

  EspJpnWord copyWith({
    int? wordId,
    String? word,
    List<PartOfSpeech>? partOfSpeech,
  }) {
    return EspJpnWord(
      wordId: wordId ?? this.wordId,
      word: word ?? this.word,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
    );
  }
}
