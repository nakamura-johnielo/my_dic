import 'package:flutter/foundation.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/dictionary/sub/example/i_example.dart';

@immutable
class SoloEspJpnExample implements IExample {
  @override
  final int exampleId;
  final int dictionaryId;
  @override
  final String japanese;
  @override
  final String espanol;

  const SoloEspJpnExample({
    required this.exampleId,
    required this.dictionaryId,
    required this.japanese,
    required this.espanol,
  });

  SoloEspJpnExample copyWith({
    int? exampleId,
    int? dictionaryId,
    String? japanese,
    String? espanol,
  }) {
    return SoloEspJpnExample(
      exampleId: exampleId ?? this.exampleId,
      dictionaryId: dictionaryId ?? this.dictionaryId,
      japanese: japanese ?? this.japanese,
      espanol: espanol ?? this.espanol,
    );
  }
}
