import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/dictionary/sub/example/impl/example.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/dictionary/sub/idiom/impl/idiom.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/dictionary/sub/supplement.dart';

part '../../../../__generated/_Business_Rule/_Domain/Entities/dictionary/esj_dictionary.freezed.dart';

@freezed
class EsjDictionary with _$EsjDictionary {
  const factory EsjDictionary({
    required int dictionaryId,
    required String word,
    String? headword,
    String? content,
    String? origin,
    List<Example>? examples,
    List<Idiom>? idioms,
    List<Supplement>? supplements,
  }) = _EsjDictionary;
}
