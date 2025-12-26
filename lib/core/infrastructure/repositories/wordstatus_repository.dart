import 'package:my_dic/core/domain/entity/word/esp_word_status.dart';
import 'package:my_dic/core/domain/i_repository/i_word_status_repository.dart';
import 'package:my_dic/core/infrastructure/database/drift/daos/esp_jpn/esp_jpn_word_status_dao.dart'
    ;
// import 'package:my_dic/_Framework_Driver/local/drift/Entity/word_status.dart'
//     as local;
import 'package:my_dic/core/infrastructure/database/firebase/daos/firebase_word_status_dao.dart'
    ;
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/infrastructure/dtos/wordStatusEntity.dart';

class WordStatusRepository implements IWordStatusRepository {
  final FirebaseWordStatusDao _remote;
  final EspJpnWordStatusDao _local;
  WordStatusRepository(this._remote, this._local);

  @override
  Future<void> updateLocalWordStatus(
      WordStatus wordStatus, DateTime now, String userId,) async {
        //localの更新
        //その後にremoteの更新
    final nowDateTime = now; //DateTime.now().toUtc();
    final localInput = EspJpnWordStatusTableData(
      wordId: wordStatus.wordId,
      isLearned: wordStatus.isLearned ? 1 : 0,
      isBookmarked: wordStatus.isBookmarked ? 1 : 0,
      hasNote: wordStatus.hasNote ? 1 : 0,
      editAt: nowDateTime.toIso8601String(),
    );

    if (await _local.exist(wordStatus.wordId)) {
      await _local.updateStatus(localInput);
      //localInput.createAt = nowDateTime.toString();
    } else {
      await _local.insertStatus(localInput);
    }

  }


  @override
  Future<void> updateRemoteWordStatus(
      WordStatus wordStatus, DateTime now, String userId,) async {
          WordStatusDTO remoteInput = WordStatusDTO.fromAppEntity(wordStatus);
    remoteInput.updatedAt = now;
    await _remote.update(remoteInput, userId);
  }


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
  Stream<WordStatus> watchWordStatusById(int id) {
   return  _local.watchWordStatus(id).map((event) {
      if(event == null){
        return WordStatus(wordId: id);
      }
      return WordStatus(
        wordId: id,
        isBookmarked: event.isBookmarked == 1 ? true : false,
        isLearned: event.isLearned == 1 ? true : false,
        hasNote: event.hasNote == 1 ? true : false,
      );
    });
  }

 }
