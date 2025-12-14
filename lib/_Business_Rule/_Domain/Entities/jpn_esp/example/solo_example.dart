import 'package:flutter/foundation.dart';

@immutable
class SoloJpnEspExample {
  final int exampleId;
  final int dictionaryId;
  final String japanese;
  final String espanol;
  final String espanolHtml;

  const SoloJpnEspExample({
    required this.exampleId,
    required this.dictionaryId,
    required this.japanese,
    required this.espanol,
    required this.espanolHtml,
  });

  SoloJpnEspExample copyWith({
    int? exampleId,
    int? dictionaryId,
    String? japanese,
    String? espanol,
    String? espanolHtml,
  }) {
    return SoloJpnEspExample(
      exampleId: exampleId ?? this.exampleId,
      dictionaryId: dictionaryId ?? this.dictionaryId,
      japanese: japanese ?? this.japanese,
      espanol: espanol ?? this.espanol,
      espanolHtml: espanolHtml ?? this.espanolHtml,
    );
  }
}
