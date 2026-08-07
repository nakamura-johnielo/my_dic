import 'package:my_dic/core/shared/enums/word/word_type.dart';

/// Identifies the dictionary content needed for a word-detail page.
class WordDetailQuery {
  const WordDetailQuery({
    required this.wordId,
    required this.wordType,
    required this.hasConjugation,
  });

  final int wordId;
  final WordType wordType;
  final bool hasConjugation;
}
