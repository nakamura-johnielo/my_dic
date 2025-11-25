import 'package:my_dic/_Business_Rule/_Domain/Entities/word/word_status.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_word_status_repository.dart';
import 'package:my_dic/_Framework_Driver/local/drift/DAO/word_status_dao.dart'
    as local;
// import 'package:my_dic/_Framework_Driver/local/drift/Entity/word_status.dart'
//     as local;
import 'package:my_dic/_Framework_Driver/remote/firebase/DAO/word_status_dao.dart'
    as remote;

class WordStatusRepository implements IWordStatusRepository {
  final remote.FirebaseWordStatusDao _remote;
  final local.WordStatusDao _local;
  WordStatusRepository(this._remote, this._local);

  @override
  Future<void> deleteWordStatus(WordStatus wordStatus) async {
    // await _local.delete(wordStatus);
    // await _remote.delete(wordStatus);
  }

  @override
  Future<WordStatus> getWordStatusById(int id) async {
    final res = await _local.getStatusById(id);
    if (res != null) {
      return WordStatus(
        wordId: id,
        isBookmarked: res.isBookmarked == 1 ? true : false,
        isLearned: res.isLearned == 1 ? true : false,
        hasNote: res.hasNote == 1 ? true : false,
      );
    }
    return WordStatus(wordId: id);
  }

  @override
  Future<void> updateWordStatus(WordStatus wordStatus) async {
    // await _local.update();
    // await _remote.update();
  }

  @override
  Stream<WordStatus> watchWordStatusById(int id) {
    // _local.watchWordStatusById(id).listen((event) {
    //   return WordStatus(
    //     wordId: id,
    //     isBookmarked: event.isBookmarked == 1 ? true : false,
    //     isLearned: event.isLearned == 1 ? true : false,
    //     hasNote: event.hasNote == 1 ? true : false,
    //   );
    // });
    throw UnimplementedError();
  }
}
