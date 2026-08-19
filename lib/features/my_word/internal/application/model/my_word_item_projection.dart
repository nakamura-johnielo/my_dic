import 'package:flutter/foundation.dart';
import 'package:my_dic/features/my_word/internal/domain/entity/my_word.dart';
import 'package:my_dic/features/my_word/internal/domain/entity/my_word_status.dart';

/// MyWord とそのアカウントスコープのステータスを読み取り側で合成したもの。
///
/// これには意図的にコマンド操作を含めない。単語とステータスは、それぞれ独立して所有される
/// 書き込み集約のままである。
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
