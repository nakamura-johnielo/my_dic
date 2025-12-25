import 'package:my_dic/core/common/consts/dates.dart';
import 'package:my_dic/core/common/consts/sharedPreference.dart';
import 'package:my_dic/core/domain/entity/word/esp_word_status.dart';
import 'package:my_dic/core/domain/i_repository/i_sync_status_repository.dart';
import 'package:my_dic/core/domain/i_repository/i_word_status_repository.dart';
import 'package:my_dic/core/service/usecase/i_sync_esp_jpn_word_status_usecase.dart';

class SyncEspJpnWordStatusInteractor implements ISyncEspJpnWordStatusUseCase {
  final ISyncStatusRepository _localSyncStatusRepository;
// final ISyncStatusRepository _remote;
  // final IWordStatusRepository _wordStatusRepository;
  final ILocalWordStatusRepository _localWordStatusRepository;
  final IRemoteWordStatusRepository _remoteWordStatusRepository;

  SyncEspJpnWordStatusInteractor(
      this._localSyncStatusRepository,
      // this._wordStatusRepository,
      this._localWordStatusRepository,
      this._remoteWordStatusRepository);

  @override
  Future<void> syncOnce(String userId) async {
    print("syncOnce start");
    //最終同期時刻以降の差分を同期する

    // localの最終同期時刻取得
    final localLastSyncDate = await _getLastSyncDate();

    //remoteのその時刻以降の更新データを取得
    final remoteData = await _remoteWordStatusRepository.getWordStatusAfter(
        userId, localLastSyncDate);

    //remoteの値でlocalを更新した場合、そのwordIdを格納
    final List<int> wordIdsUpdatedByRemote = [];

    if (remoteData.isNotEmpty) {
      for (var remoteItem in remoteData) {
        final id = await _syncHandle(userId, remoteItem);
        if (id != null) {
          wordIdsUpdatedByRemote.add(id);
        }
      }
    }

    await _uploadLocal2Remote(
        userId, localLastSyncDate, wordIdsUpdatedByRemote);

    await _updateLocalLastSyncDate();
  }

  Future<void> _uploadLocal2Remote(
      String userId, DateTime datetime, List<int> ids) async {
    final localData =
        await _localWordStatusRepository.getWordStatusAfter(datetime);
        print("local length hay que sync: ${localData.length}");
    if (localData.isEmpty) return;

    await _remoteWordStatusRepository.updateWordStatusBatch(userId, localData);
  }

  @override
  Future<void> syncOnUpdatedLocal(String userId, int wordId) async {
    print("syncOnUpdatedLocal called for wordId: $wordId");
    //remoteへの反映処理
    //remoteの時刻が古ければ更新
    final remoteItem =
        await _remoteWordStatusRepository.getWordStatusById(userId, wordId);

    if (remoteItem == null) {
      //remoteに存在しない場合はそのまま更新
      final localData =
          await _localWordStatusRepository.getWordStatusById(wordId);
      await _remoteWordStatusRepository.updateWordStatus(userId, localData);
      await _updateLocalLastSyncDate();
      return;
    }

    await _syncHandle(userId, remoteItem);
    await _updateLocalLastSyncDate();
  }

  @override
  Future<void> syncOnUpdatedRemote(String userId, int wordId) async {
    print("syncOnUpdatedRemote called for wordId: $wordId");
    //時刻判定
    //localの時刻が古ければ更新
    final remoteItem =
        await _remoteWordStatusRepository.getWordStatusById(userId, wordId);

    if (remoteItem == null) {
      //remoteに存在しない場合
      //エラー
      return;
    }

    await _syncHandle(userId, remoteItem);
    await _updateLocalLastSyncDate();
  }

  Future<void> _updateLocalLastSyncDate() async {
    //TODO servertimestapで同期時刻取得sる用変更
    final now = DateTime.now().toUtc();
    await _localSyncStatusRepository.updateSyncDate(now);
  }

  Future<DateTime> _getLastSyncDate() async {
    final localLastSyncDate =
        await _localSyncStatusRepository.getLastSyncDate() ??
            MyDateTime.sentinel;
    return localLastSyncDate;
  }

  Future<int?> _syncHandle(String userId, WordStatus remoteItem) async {
    //remoteの値でlocalが更新された場合、wordId そうではない場合null
    //与えられたWordStatusとlocalの時刻を最新の法を同期
    //localに反映、remoteに反映

    final localData =
        await _localWordStatusRepository.getWordStatusById(remoteItem.wordId);
    final remoteUpdatedAt = remoteItem.editAt;

    // ローカルに存在する場合は更新日時を比較して新しい方で上書き
    final localUpdatedAt = localData.editAt;

    print("~~~~~~ Remote: $remoteUpdatedAt, Local: $localUpdatedAt");

    if (remoteUpdatedAt.isAfter(localUpdatedAt)) {
      print("Remote is newer for wordId: ${remoteItem.wordId}");
      // リモートの方が新しい場合
      // local更新
      await _localWordStatusRepository.updateWordStatus(remoteItem);
      return remoteItem.wordId;
    } else if (localUpdatedAt.isAfter(remoteUpdatedAt)) {
      print("Local is newer for wordId: ${remoteItem.wordId}");
      // ローカルの方が新しい場合
      // remote更新
      await _remoteWordStatusRepository.updateWordStatus(userId, localData);
    } else {
      // 同じ場合
      //何もしない
      //loop止める

      // ローカルの方が新しい場合とおなじとする
      //remote更新
      //await _remoteWordStatusRepository.updateWordStatus(userId, localData);
    }
    return null;
  }

  @override
  Stream<List<int>> watchRemoteChangedIds(String userId) {
    //final lastSyncTime =await _getLastSyncDate();
    //final lastSyncTime = DateTime.now().toUtc();
    return _remoteWordStatusRepository.watchChangedIds(userId);
  }

  @override
  Stream<List<int>> watchLocalChangedIds() {
    //TODO driftでは無理
    //final dateTime =await _getLastSyncDate();
    final dateTime = DateTime.now().toUtc();
    return _localWordStatusRepository.watchChangedIds(dateTime);
  }
}
