import 'package:flutter/foundation.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/dictionary/sub/example/impl/example.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/dictionary/sub/idiom/impl/idiom.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/dictionary/sub/supplement.dart';

@immutable
class EsjDictionary {
  final int dictionaryId;
  final String word;
  final String? headword;
  final String? content;
  final String? origin;
  final List<EspJpnExample>? examples;
  final List<Idiom>? idioms;
  final List<Supplement>? supplements;

  const EsjDictionary({
    required this.dictionaryId,
    required this.word,
    this.headword,
    this.content,
    this.origin,
    this.examples,
    this.idioms,
    this.supplements,
  });

  EsjDictionary copyWith({
    int? dictionaryId,
    String? word,
    String? headword,
    String? content,
    String? origin,
    List<EspJpnExample>? examples,
    List<Idiom>? idioms,
    List<Supplement>? supplements,
  }) {
    return EsjDictionary(
      dictionaryId: dictionaryId ?? this.dictionaryId,
      word: word ?? this.word,
      headword: headword ?? this.headword,
      content: content ?? this.content,
      origin: origin ?? this.origin,
      examples: examples ?? this.examples,
      idioms: idioms ?? this.idioms,
      supplements: supplements ?? this.supplements,
    );
  }
}
