import 'dart:async';
import 'package:my_dic/core/service/usecase/i_sync_esp_jpn_word_status_usecase.dart';

class EspJpnWordStatusSyncService {
  final ISyncEspJpnWordStatusUseCase _syncUseCase;

  EspJpnWordStatusSyncService(this._syncUseCase);

  StreamSubscription<List<int>>? _remoteSub;
  StreamSubscription<List<int>>? _localSub;

  /// 一回限りの同期
  Future<void> syncOnce(String userId) async {
    print("synconce");
    await _syncUseCase.syncOnce(userId);
  }

  /// 同期開始。onSynced: 同期処理後に最新 updatedAt を渡す

  void startSyncWithRemote(
    //TODO datetimeでフィルタ入れて効率化
    String userId,
  ) {
    _handleOnRemoteChange(userId);
    //_handleOnLocalChange(userId);
  }

  void _handleOnRemoteChange(
    String userId,
  ) {
    _remoteSub?.cancel();
    _remoteSub =
        _syncUseCase.watchRemoteChangedIds(userId).listen((wordIds) async {
      if (wordIds.isEmpty) return;

      for (final wordId in wordIds) {
        print("remote: ${wordId}!!!!!!!!!status UPDATED ");
        await _syncUseCase.syncOnUpdatedRemote(userId, wordId);
      }
    });
  }

  void _handleOnLocalChange(
    String userId,
  ) {
    _localSub?.cancel();
    _localSub = _syncUseCase.watchLocalChangedIds().listen((wordIds) async {
      if (wordIds.isEmpty) return;

      for (final wordId in wordIds) {
        print("local: ${wordId}!!!!!!!!!status UPDATED ");
        await _syncUseCase.syncOnUpdatedLocal(userId, wordId);
      }
    });
  }

  void dispose() {
    _remoteSub?.cancel();
    _remoteSub = null;
    _localSub?.cancel();
    _localSub = null;
  }
}
