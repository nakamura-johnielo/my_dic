import 'package:flutter/foundation.dart';
import 'package:my_dic/core/shared/enums/word/word_type.dart';

/// Identifies the complete read request represented by a word-detail page.
@immutable
class WordPageLoadKey {
  const WordPageLoadKey({
    required this.wordId,
    required this.wordType,
    required this.hasConj,
  });

  final int wordId;
  final WordType wordType;
  final bool hasConj;

  @override
  bool operator ==(Object other) =>
      other is WordPageLoadKey &&
      other.wordId == wordId &&
      other.wordType == wordType &&
      other.hasConj == hasConj;

  @override
  int get hashCode => Object.hash(wordId, wordType, hasConj);
}
