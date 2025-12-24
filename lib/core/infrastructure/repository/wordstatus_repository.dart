import 'package:my_dic/core/domain/entity/word/esp_word_status.dart';
import 'package:my_dic/core/domain/i_repository/i_word_status_repository.dart';
import 'package:my_dic/core/infrastructure/database/dao/local/esp_jpn/esp_jpn_word_status_dao.dart'
    as local;
// import 'package:my_dic/_Framework_Driver/local/drift/Entity/word_status.dart'
//     as local;
import 'package:my_dic/core/infrastructure/database/dao/remote/firebase_word_status_dao.dart'
    as remote;
import 'package:my_dic/core/infrastructure/database/database_provider.dart';
import 'package:my_dic/core/infrastructure/dto/wordStatusEntity.dart';

class WordStatusRepository implements IWordStatusRepository {
  final remote.FirebaseWordStatusDao _remote;
  final local.EspJpnWordStatusDao _local;
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
  Future<void> updateWordStatus(
      WordStatus wordStatus, DateTime now, String userId,
      {bool isFromSync = false}) async {
    final nowDateTime = now; //DateTime.now().toUtc();
    final localInput = EspJpnWordStatusTableData(
      wordId: wordStatus.wordId,
      isLearned: wordStatus.isLearned ? 1 : 0,
      isBookmarked: wordStatus.isBookmarked ? 1 : 0,
      hasNote: wordStatus.hasNote ? 1 : 0,
      editAt: nowDateTime.toString(),
    );

    if (await _local.exist(wordStatus.wordId)) {
      await _local.updateStatus(localInput);
      //localInput.createAt = nowDateTime.toString();
    } else {
      await _local.insertStatus(localInput);
    }

    // リモート更新は同期処理の場合は行わない
    //remoteからのデータをローカルに反映するだけ
    if (isFromSync) {
      return;
    }

    WordStatusDTO remoteInput = WordStatusDTO.fromAppEntity(wordStatus);
    remoteInput.updatedAt = nowDateTime;
    await _remote.update(remoteInput, userId);
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

  @override
  Future<void> sync(String userId, DateTime datetime) async {
    //localのラスト更新時刻以降のremoteデータを取得し、localに反映
    final remoteData = await _remote.getWordStatusAfter(userId, datetime);

    for (var remoteItem in remoteData) {
      final localData = await _local.getStatusById(remoteItem.wordId);
      final remoteUpdatedAt = remoteItem.updatedAt.toUtc();

      if (localData == null) {
        // ローカルに存在しない場合は追加
        final newLocalData = EspJpnWordStatusTableData(
          wordId: remoteItem.wordId,
          isLearned: remoteItem.isLearned,
          isBookmarked: remoteItem.isBookmarked,
          hasNote: remoteItem.hasNote,
          editAt: remoteUpdatedAt.toString(),
        );
        await _local.insertStatus(newLocalData);
      } else {
        final localUpdatedAt = DateTime.parse(localData.editAt).toUtc();

        if (remoteUpdatedAt.isAfter(localUpdatedAt)) {
          // リモートの方が新しい場合は更新
          final updatedLocalData = EspJpnWordStatusTableData(
            wordId: remoteItem.wordId,
            isLearned: remoteItem.isLearned,
            isBookmarked: remoteItem.isBookmarked,
            hasNote: remoteItem.hasNote,
            editAt: remoteUpdatedAt.toString(),
          );
          await _local.updateStatus(updatedLocalData);
          return;
        }
        // ローカルの方が新しい場合はremote更新
        else if (localUpdatedAt.isAfter(remoteUpdatedAt)) {
          final updatedRemoteData = WordStatusDTO.fromAppEntity(WordStatus(
            wordId: localData.wordId,
            isLearned: localData.isLearned == 1 ? true : false,
            isBookmarked: localData.isBookmarked == 1 ? true : false,
            hasNote: localData.hasNote == 1 ? true : false,
          ));
          updatedRemoteData.updatedAt = localUpdatedAt;
          await _remote.update(updatedRemoteData, userId);
        }
      }
    }
  }
}
