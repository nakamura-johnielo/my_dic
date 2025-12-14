/* 
各時制のconjugacion

!todo Tenseを含めるか検討
一応Mapのkeyとしてtenseは設定
個別でtense扱いたいか？ 

 */

import 'package:flutter/foundation.dart';

@immutable
class TenseConjugacion {
  final String yo;
  final String tu;
  final String el;
  final String nosotros;
  final String vosotros;
  final String ellos;

  const TenseConjugacion({
    required this.yo,
    required this.tu,
    required this.el,
    required this.nosotros,
    required this.vosotros,
    required this.ellos,
  });

  TenseConjugacion copyWith({
    String? yo,
    String? tu,
    String? el,
    String? nosotros,
    String? vosotros,
    String? ellos,
  }) {
    return TenseConjugacion(
      yo: yo ?? this.yo,
      tu: tu ?? this.tu,
      el: el ?? this.el,
      nosotros: nosotros ?? this.nosotros,
      vosotros: vosotros ?? this.vosotros,
      ellos: ellos ?? this.ellos,
    );
  }
}
