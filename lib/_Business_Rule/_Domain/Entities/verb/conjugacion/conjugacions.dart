import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_dic/Constants/Enums/mood_tense.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/verb/conjugacion/tense_conjugacion.dart';

// 生成されるdartファイルを記述

part '../../../../../__generated/_Business_Rule/_Domain/Entities/verb/conjugacion/conjugacions.freezed.dart';

//全部のconjを持ってる

@freezed
class Conjugacions with _$Conjugacions {
  // プロパティを指定
  const factory Conjugacions({
    required int conjugacionId,
    required int wordId,
    required Map<MoodTense, TenseConjugacion> conjugacions,
    // デフォルト値は「@Default([デフォルト値]])」の形式で指定可能
  }) = _Conjugacions;
}
