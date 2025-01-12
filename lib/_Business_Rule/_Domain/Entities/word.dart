import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_dic/Constants/Enums/part_of_speech.dart';
part '../../../__generated/_Business_Rule/_Domain/Entities/word.freezed.dart';

@freezed
class Word with _$Word {
  const factory Word({
    required int wordId,
    required String word,
    required List<PartOfSpeech> partOfSpeech,
  }) = _Word;

  const Word._();
  bool hasVerb() {
    return partOfSpeech.contains(PartOfSpeech.verb);
  }
}
