import 'package:flutter/foundation.dart';
import 'package:my_dic/core/domain/entity/dictionary/sub/example/i_example.dart';

@immutable
class EspJpnSoloExample implements IExample {
  @override
  final int exampleId;
  final int dictionaryId;
  @override
  final String japanese;
  @override
  final String espanol;

  const EspJpnSoloExample({
    required this.exampleId,
    required this.dictionaryId,
    required this.japanese,
    required this.espanol,
  });

  EspJpnSoloExample copyWith({
    int? exampleId,
    int? dictionaryId,
    String? japanese,
    String? espanol,
  }) {
    return EspJpnSoloExample(
      exampleId: exampleId ?? this.exampleId,
      dictionaryId: dictionaryId ?? this.dictionaryId,
      japanese: japanese ?? this.japanese,
      espanol: espanol ?? this.espanol,
    );
  }
}
