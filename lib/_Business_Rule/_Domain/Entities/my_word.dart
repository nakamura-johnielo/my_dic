import 'package:flutter/foundation.dart';

@immutable
class MyWord {
  final int wordId;
  final String word;
  final String contents;
  final bool isLearned;
  final bool isBookmarked;

  const MyWord({
    required this.wordId,
    required this.word,
    required this.contents,
    this.isLearned = false,
    this.isBookmarked = false,
  });

  MyWord copyWith({
    int? wordId,
    String? word,
    String? contents,
    bool? isLearned,
    bool? isBookmarked,
  }) {
    return MyWord(
      wordId: wordId ?? this.wordId,
      word: word ?? this.word,
      contents: contents ?? this.contents,
      isLearned: isLearned ?? this.isLearned,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}
