import 'package:flutter/material.dart';

@immutable
class JpnEspWordStatus {
  final int wordId;
  final bool isLearned;
  final bool isBookmarked;
  final bool hasNote;
  final DateTime editAt;

  JpnEspWordStatus({
    required this.wordId,
    this.isBookmarked = false,
    this.isLearned = false,
    this.hasNote = false,
    DateTime? editAt,
  }) : editAt = editAt?.toUtc() ?? DateTime.now().toUtc();

  JpnEspWordStatus copyWith({
    bool? isBookmarked,
    bool? isLearned,
    bool? hasNote,
    DateTime? editAt,
  }) {
    return JpnEspWordStatus(
      wordId: wordId,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isLearned: isLearned ?? this.isLearned,
      hasNote: hasNote ?? this.hasNote,
      editAt: editAt ?? this.editAt,
    );
  }
}
