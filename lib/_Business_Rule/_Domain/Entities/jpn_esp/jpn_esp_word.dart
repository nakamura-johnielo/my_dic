import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part '../../../../__generated/_Business_Rule/_Domain/Entities/jpn_esp/jpn_esp_word.freezed.dart';

@freezed
class JpnEspWord with _$JpnEspWord {
  const factory JpnEspWord({
    required int id,
    required String word,
    @Default(false) bool isLearned,
    @Default(false) bool isBookmarked,
    @Default(false) bool hasNote,
  }) = _JpnEspWord;
}
