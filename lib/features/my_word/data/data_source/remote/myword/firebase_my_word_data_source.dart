import 'package:my_dic/features/my_word/data/data_source/remote/myword/firebase_my_word_dao.dart';
import 'package:my_dic/features/my_word/data/data_source/remote/myword/firebase_my_word_dto.dart';
import 'package:my_dic/features/my_word/data/data_source/remote/myword/i_my_word_remote_data_source.dart';

class FirebaseMyWordDataSource implements IMyWordRemoteDataSource {
  final FirebaseMyWordDao _dao;
  FirebaseMyWordDataSource(this._dao);

  @override
  Future<MyWordDTO?> getMyWordById(String userId, String myWordId) async {
    return await _dao.getMyWord(userId, myWordId);
  }

  @override
  Future<List<MyWordDTO>> getMyWordsAfter(
      String userId, DateTime datetime) async {
    return await _dao.getMyWordsAfter(userId, datetime);
  }

  @override
  Future<void> updateMyWord(String userId, MyWordDTO myWord) async {
    await _dao.update(myWord, userId);
  }

  @override
  Stream<List<String>> watchChangedIds(String userId) =>
      _dao.watchChangedWordIds(userId);

  @override
  Future<void> updateMyWordBatch(
      String userId, List<MyWordDTO> myWordList) async {
    await _dao.updateBatch(userId, myWordList);
  }

  @override
  Future<void> deleteMyWord(String userId, String myWordId) async {
    await _dao.delete(userId, myWordId);
  }
}