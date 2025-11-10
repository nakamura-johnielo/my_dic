import 'package:freezed_annotation/freezed_annotation.dart';

part '../../../../../__generated/_Business_Rule/_Domain/Entities/jpn_esp/example/solo_example.freezed.dart';

@freezed
class SoloJpnEspExample with _$SoloJpnEspExample {
  const factory SoloJpnEspExample({
    required int exampleId,
    required int dictionaryId,
    required String japanese,
    required String espanol,
    required String espanolHtml,
  }) = _SoloJpnEspExample;
}
