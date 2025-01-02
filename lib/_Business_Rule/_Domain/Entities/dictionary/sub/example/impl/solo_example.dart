import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/dictionary/sub/example/i_example.dart';
part '../../../../../../../__generated/_Business_Rule/_Domain/Entities/dictionary/sub/example/impl/solo_example.freezed.dart';

@freezed
class SoloExample with _$SoloExample implements IExample {
  const factory SoloExample({
    required int exampleId,
    required int dictionaryId,
    required String japanese,
    required String espanol,
  }) = _SoloExample;
}
