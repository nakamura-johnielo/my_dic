import 'package:flutter/foundation.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/jpn_esp/example/example.dart';

@immutable
class JpnEspDictionary {
  final int id;
  final int wordId;
  final String word;
  final String? headword;
  final String? content;
  final List<JpnEspExampleWith>? examples;

  const JpnEspDictionary({
    required this.id,
    required this.wordId,
    required this.word,
    this.headword,
    this.content,
    this.examples,
  });

  JpnEspDictionary copyWith({
    int? id,
    int? wordId,
    String? word,
    String? headword,
    String? content,
    List<JpnEspExampleWith>? examples,
  }) {
    return JpnEspDictionary(
      id: id ?? this.id,
      wordId: wordId ?? this.wordId,
      word: word ?? this.word,
      headword: headword ?? this.headword,
      content: content ?? this.content,
      examples: examples ?? this.examples,
    );
  }
}
