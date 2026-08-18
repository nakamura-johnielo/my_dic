import 'package:my_dic/features/my_word/internal/application/model/my_word_item_projection.dart';
import 'package:my_dic/features/my_word/internal/domain/entity/my_word.dart';
import 'package:my_dic/features/my_word/internal/domain/entity/my_word_status.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/dao/local/drift_my_word_dao.dart';

/// The canonical conversion from an account-scoped Drift join row to the
/// read-side model consumed by the public MyWord result mapper.
final class MyWordItemProjectionMapper {
  const MyWordItemProjectionMapper._();

  static MyWordItemProjection fromDriftRow(MyWordItemRow row) {
    final word = MyWord(
      wordId: row.word.myWordId,
      word: row.word.word,
      contents: row.word.contents ?? '',
      editAt: DateTime.parse(row.word.editAt).toUtc(),
    );
    final statusRow = row.status;
    final status = statusRow == null || statusRow.deletedAt != null
        ? MyWordStatus(wordId: word.wordId, editAt: word.editAt)
        : MyWordStatus(
            wordId: word.wordId,
            isLearned: statusRow.isLearned == 1,
            isBookmarked: statusRow.isBookmarked == 1,
            hasNote: statusRow.hasNote == 1,
            editAt: DateTime.parse(statusRow.editAt).toUtc(),
          );
    return MyWordItemProjection(word: word, status: status);
  }
}
