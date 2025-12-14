import 'package:flutter/foundation.dart';

@immutable
class JpnEspSoloExample {
  final int exampleId;
  final int dictionaryId;
  final String japanese;
  final String espanol;
  final String espanolHtml;

  const JpnEspSoloExample({
    required this.exampleId,
    required this.dictionaryId,
    required this.japanese,
    required this.espanol,
    required this.espanolHtml,
  });

  JpnEspSoloExample copyWith({
    int? exampleId,
    int? dictionaryId,
    String? japanese,
    String? espanol,
    String? espanolHtml,
  }) {
    return JpnEspSoloExample(
      exampleId: exampleId ?? this.exampleId,
      dictionaryId: dictionaryId ?? this.dictionaryId,
      japanese: japanese ?? this.japanese,
      espanol: espanol ?? this.espanol,
      espanolHtml: espanolHtml ?? this.espanolHtml,
    );
  }
}
