import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/dictionary/sub/example/i_example.dart';
part '../../../../../../../__generated/_Business_Rule/_Domain/Entities/dictionary/sub/example/impl/example.freezed.dart';

@freezed
class Example with _$Example implements IExample {
  const factory Example({
    required int exampleId,
    required String japanese,
    required String espanol,
  }) = _Example;
}
