import 'package:flutter/foundation.dart';

@immutable
class MyWordStatus {
  final String wordId;
  final bool isLearned;
  final bool isBookmarked;
  final bool hasNote;
  final DateTime editAt;

  MyWordStatus({
    required this.wordId,
    this.isLearned = false,
    this.isBookmarked = false,
    this.hasNote = false,
    DateTime? editAt,
  }) : editAt = (editAt ?? DateTime.now()).toUtc();

  MyWordStatus copyWith({
    String? wordId,
    bool? isLearned,
    bool? isBookmarked,
    bool? hasNote,
    DateTime? editAt,
  }) {
    return MyWordStatus(
      wordId: wordId ?? this.wordId,
      isLearned: isLearned ?? this.isLearned,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      hasNote: hasNote ?? this.hasNote,
      editAt: editAt ?? this.editAt,
    );
  }
}
