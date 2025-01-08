/* 
各時制のconjugacion

!todo Tenseを含めるか検討
一応Mapのkeyとしてtenseは設定
個別でtense扱いたいか？ 

 */

import 'package:freezed_annotation/freezed_annotation.dart';

// 生成されるdartファイルを記述
part '../../../../../__generated/_Business_Rule/_Domain/Entities/verb/conjugacion/tense_conjugacion.freezed.dart';

@freezed
class TenseConjugacion with _$TenseConjugacion {
  // プロパティを指定
  const factory TenseConjugacion({
    required String yo,
    required String tu,
    required String el,
    required String nosotros,
    required String vosotros,
    required String ellos,
    // デフォルト値は「@Default([デフォルト値]])」の形式で指定可能
  }) = _TenseConjugacion;
}
