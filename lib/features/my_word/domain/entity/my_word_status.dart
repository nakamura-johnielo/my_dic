import 'package:flutter/foundation.dart';

@immutable
class MyWordStatus {
  final int wordId;
  final bool isLearned;
  final bool isBookmarked;
  final DateTime editAt;

  MyWordStatus({
    required this.wordId,
    this.isLearned = false,
    this.isBookmarked = false,
    DateTime? editAt,
  }) : editAt = (editAt ?? DateTime.now()).toUtc();

  MyWordStatus copyWith({
    int? wordId,
    bool? isLearned,
    bool? isBookmarked,
    DateTime? editAt,
  }) {
    return MyWordStatus(
      wordId: wordId ?? this.wordId,
      isLearned: isLearned ?? this.isLearned,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      editAt: editAt ?? this.editAt,
    );
  }
}
