import 'package:flutter/material.dart';

@immutable
class WordStatus {
  //final bool hasConj;
  final int wordId;
  final bool isLearned;
  final bool isBookmarked;
  final bool hasNote;
  final DateTime editAt;

   WordStatus({
    required this.wordId,
    //required this.hasConj,
    this.isBookmarked = false,
    this.isLearned = false,
    this.hasNote = false, 
    DateTime? editAt,
  }) : editAt = editAt?.toUtc() ?? DateTime.now().toUtc();

  WordStatus copyWith({
    bool? isBookmarked,
    bool? isLearned,
    bool? hasNote,
    DateTime? editAt,
  }) {
    return WordStatus(
      wordId: wordId,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isLearned: isLearned ?? this.isLearned,
      hasNote: hasNote ?? this.hasNote, 
      editAt: editAt ?? this.editAt,
    );
  }
}
