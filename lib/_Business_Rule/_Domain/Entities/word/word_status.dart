import 'package:flutter/material.dart';

@immutable
class WordStatus {
  //final bool hasConj;
  final bool isLearned;
  final bool isBookmarked;
  final bool hasNote;

  const WordStatus({
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
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isLearned: isLearned ?? this.isLearned,
      hasNote: hasNote ?? this.hasNote,
    );
  }
}
