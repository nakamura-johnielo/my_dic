import 'package:flutter/foundation.dart';

@immutable
class JpnEspExampleWith {
  final int exampleId;
  final String japanese;
  final String espanol;
  final String espanolHtml;

  const JpnEspExampleWith({
    required this.exampleId,
    required this.japanese,
    required this.espanol,
    required this.espanolHtml,
  });

  JpnEspExampleWith copyWith({
    int? exampleId,
    String? japanese,
    String? espanol,
    String? espanolHtml,
  }) {
    return JpnEspExampleWith(
      exampleId: exampleId ?? this.exampleId,
      japanese: japanese ?? this.japanese,
      espanol: espanol ?? this.espanol,
      espanolHtml: espanolHtml ?? this.espanolHtml,
    );
  }
}
