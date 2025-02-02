import 'package:freezed_annotation/freezed_annotation.dart';
part '../../../__generated/_Business_Rule/_Domain/Entities/my_word.freezed.dart';

@freezed
class MyWord with _$MyWord {
  const factory MyWord({
    required int wordId,
    required String word,
    @Default(false) bool isLearned,
    @Default(false) bool isBookmarked,
  }) = _MyWord;
}
