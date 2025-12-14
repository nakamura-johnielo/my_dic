import 'package:flutter/foundation.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/dictionary/sub/example/i_example.dart';

@immutable
class EspJpnExample implements IExample {
  @override
  final int exampleId;
  @override
  final String japanese;
  @override
  final String espanol;

  const EspJpnExample({
    required this.exampleId,
    required this.japanese,
    required this.espanol,
  });

  EspJpnExample copyWith({
    int? exampleId,
    String? japanese,
    String? espanol,
  }) {
    return EspJpnExample(
      exampleId: exampleId ?? this.exampleId,
      japanese: japanese ?? this.japanese,
      espanol: espanol ?? this.espanol,
    );
  }
}
