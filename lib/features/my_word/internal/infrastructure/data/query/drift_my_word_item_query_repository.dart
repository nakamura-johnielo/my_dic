import 'package:my_dic/features/my_word/internal/application/query/i_my_word_item_query_repository.dart';
import 'package:my_dic/features/my_word/internal/application/query/my_word_item_projection.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/data_source/local/drift_my_word_dao.dart';
import 'package:my_dic/features/my_word/internal/domain/entity/my_word.dart';
import 'package:my_dic/features/my_word/internal/domain/entity/my_word_status.dart';

/// Drift-backed read adapter. It never writes a missing status row.
class DriftMyWordItemQueryRepository implements IMyWordItemQueryRepository {
  DriftMyWordItemQueryRepository(this._dao);

  final MyWordDao _dao;

  @override
  Stream<MyWordItemProjection?> watchItem(
    String myWordId, {
    required String accountId,
  }) {
    return _dao.watchMyWordItemRow(myWordId, accountId).map((row) {
      if (row == null) return null;
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
    }).distinct();
  }
}
