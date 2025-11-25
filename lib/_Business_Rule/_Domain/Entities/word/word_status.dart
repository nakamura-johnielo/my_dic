import 'package:flutter/material.dart';

@immutable
class WordStatus {
  //final bool hasConj;
  final int wordId;
  final bool isLearned;
  final bool isBookmarked;
  final bool hasNote;

  const WordStatus({
    required this.wordId,
    //required this.hasConj,
    this.isBookmarked = false,
    this.isLearned = false,
    this.hasNote = false,
  });

  WordStatus copyWith({
    bool? isBookmarked,
    bool? isLearned,
    bool? hasNote,
  }) {
    return WordStatus(
      wordId: wordId,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isLearned: isLearned ?? this.isLearned,
      hasNote: hasNote ?? this.hasNote,
    );
  }
}
