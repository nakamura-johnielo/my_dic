import 'package:my_dic/features/catalog/internal/domain/dictionary_entry/supplement.dart';
import 'package:my_dic/features/catalog/internal/domain/example/esp_jpn_example.dart';
import 'package:my_dic/features/catalog/internal/domain/idiom/idiom.dart';

class EspJpnDictionary {
  final int dictionaryId;
  final String word;
  final String? headword;
  final String? content;
  final String? origin;
  final List<EspJpnExample>? examples;
  final List<Idiom>? idioms;
  final List<Supplement>? supplements;

  const EspJpnDictionary({
    required this.dictionaryId,
    required this.word,
    this.headword,
    this.content,
    this.origin,
    this.examples,
    this.idioms,
    this.supplements,
  });

  EspJpnDictionary copyWith({
    int? dictionaryId,
    String? word,
    String? headword,
    String? content,
    String? origin,
    List<EspJpnExample>? examples,
    List<Idiom>? idioms,
    List<Supplement>? supplements,
  }) {
    return EspJpnDictionary(
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
