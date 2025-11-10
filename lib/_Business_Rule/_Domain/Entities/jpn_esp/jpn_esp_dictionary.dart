import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/jpn_esp/example/example.dart';

part '../../../../__generated/_Business_Rule/_Domain/Entities/jpn_esp/jpn_esp_dictionary.freezed.dart';

@freezed
class JpnEspDictionary with _$JpnEspDictionary {
  const factory JpnEspDictionary({
    required int id,
    required int wordId,
    required String word,
    String? headword,
    String? content,
    List<JpnEspExampleWith>? examples,
  }) = _JpnEspDictionary;
}
