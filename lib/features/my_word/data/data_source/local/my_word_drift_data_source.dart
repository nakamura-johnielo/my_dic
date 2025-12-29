import 'package:my_dic/features/my_word/data/data_source/local/drift_my_word_dao.dart';
import 'package:my_dic/features/my_word/data/data_source/local/drift_my_word_status_dao.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart' as db;
import 'package:my_dic/features/my_word/data/data_source/local/i_my_word_local_data_source.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word.dart';

class MyWordDriftDataSource implements IMyWordLocalDataSource {
  final MyWordDao _myWordDao;
  final MyWordStatusDao _wordStatusDao;

  MyWordDriftDataSource(this._myWordDao, this._wordStatusDao);

    @override
    Future<MyWord?> getMyWordById(int id) async {
        final data = await _myWordDao.getMyWordById(id);
        if (data == null) return null;
        return MyWord(
            wordId: data.myWordId,
            word: data.word,
            contents: data.contents ?? '',
            isLearned: false,
            isBookmarked: false,
        );
    }

    @override
    Future<List<MyWord>?> getFilteredMyWordByPage(int size, int offset) async {
        final list = await _myWordDao.getFilteredMyWordByPage(size, offset);
        if (list == null) return null;
        return list
                .map((data) => MyWord(
                            wordId: data.myWordId,
                            word: data.word,
                            contents: data.contents ?? '',
                            isLearned: false,
                            isBookmarked: false,
                        ))
                .toList();
    }

  @override
  Future<int> insertMyWord(String headword, String description, String dateTime) =>
      _myWordDao.insertMyWord(headword, description, dateTime);

  @override
  Future<int> deleteMyword(int wordId, String editAt) => _myWordDao.deleteMyword(wordId, editAt);

  @override
  Future<int> updateMyWord(int id, String word, String contents, String dateTime) =>
      _myWordDao.updateMyWord(id, word, contents, dateTime);

  @override
  Future<void> updateStatus(db.MyWordStatusTableData data) => _wordStatusDao.updateStatus(data);

  @override
  Future<void> insertStatus(db.MyWordStatusTableData data) => _wordStatusDao.insertStatus(data);

  @override
  Future<bool> existStatus(int id) => _wordStatusDao.exist(id);
}
