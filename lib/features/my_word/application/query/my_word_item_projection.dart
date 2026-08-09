import 'package:flutter/foundation.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word_status.dart';

/// Read-side composition of a MyWord and its account-scoped status.
///
/// This intentionally has no command operations: the word and status remain
/// independently owned write aggregates.
@immutable
class MyWordItemProjection {
  const MyWordItemProjection({
    required this.word,
    required this.status,
  });

  final MyWord word;
  final MyWordStatus status;

  @override
  bool operator ==(Object other) =>
      other is MyWordItemProjection &&
      other.word.wordId == word.wordId &&
      other.word.word == word.word &&
      other.word.contents == word.contents &&
      other.word.editAt == word.editAt &&
      other.status.wordId == status.wordId &&
      other.status.isLearned == status.isLearned &&
      other.status.isBookmarked == status.isBookmarked &&
      other.status.hasNote == status.hasNote &&
      other.status.editAt == status.editAt;

  @override
  int get hashCode => Object.hash(
        word.wordId,
        word.word,
        word.contents,
        word.editAt,
        status.wordId,
        status.isLearned,
        status.isBookmarked,
        status.hasNote,
        status.editAt,
      );
}
