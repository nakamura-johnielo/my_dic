import 'package:my_dic/features/my_word/internal/application/model/my_word_item_projection.dart';
import 'package:my_dic/features/my_word/internal/domain/entity/my_word.dart'
    as domain;
import 'package:my_dic/features/my_word/internal/domain/entity/my_word_status.dart'
    as domain;
import 'package:my_dic/features/my_word/port/result.dart' as port;

/// 所有者内部の読み取りモデルをフレームワーク非依存の公開結果に変換する。
final class MyWordResultMapper {
  const MyWordResultMapper._();

  static port.MyWord word(domain.MyWord value) => port.MyWord(
        wordId: value.wordId,
        headword: value.word,
        description: value.contents,
        updatedAt: value.editAt.toUtc(),
      );

  static port.MyWordStatus status(domain.MyWordStatus value) =>
      port.MyWordStatus(
        wordId: value.wordId,
        isLearned: value.isLearned,
        isBookmarked: value.isBookmarked,
        hasNote: value.hasNote,
        updatedAt: value.editAt.toUtc(),
      );

  static port.MyWordItem item(MyWordItemProjection value) => port.MyWordItem(
        word: word(value.word),
        status: status(value.status),
      );
}
