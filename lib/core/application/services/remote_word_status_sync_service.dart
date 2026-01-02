import 'dart:async';
import 'package:my_dic/core/domain/usecase/sync_esp_jpn_word_status/i_sync_esp_jpn_word_status_usecase.dart';
import 'package:my_dic/core/shared/utils/result.dart';

class EspJpnWordStatusSyncService {
  final ISyncEspJpnWordStatusUseCase _syncUseCase;

  EspJpnWordStatusSyncService(this._syncUseCase);

  // StreamSubscription<List<int>>? _remoteSub;
  // StreamSubscription<List<int>>? _localSub;

  /// 一回限りの同期
  Future<void> syncOnce(String userId) async {
    print("synconce");
    final result = await _syncUseCase.syncOnce(userId);
    result.when(
      success: (_) => print('[SyncService] Sync completed successfully'),
      failure: (error) => print('[SyncService] Sync failed: ${error.message}'),
    );
  }

  /// 同期開始。onSynced: 同期処理後に最新 updatedAt を渡す

  StreamSubscription<List<int>> startSyncWithRemote(
    String userId,
  ) {
    return _handleOnRemoteChange(userId);
    //_handleOnLocalChange(userId);
  }

  StreamSubscription<List<int>> _handleOnRemoteChange(
    String userId,
  ) {
    return
        _syncUseCase.watchRemoteChangedIds(userId).listen((wordIds) async {
      if (wordIds.isEmpty) return;

      for (final wordId in wordIds) {
        print("remote: ${wordId}!!!!!!!!!status UPDATED ");
        final result = await _syncUseCase.syncOnUpdatedRemote(userId, wordId);
        result.when(
          success: (_) => print('[SyncService] Remote sync for wordId $wordId completed'),
          failure: (error) => print('[SyncService] Remote sync for wordId $wordId failed: ${error.message}'),
        );
      }
    });
  }

  StreamSubscription<List<int>> _handleOnLocalChange(
    String userId,
  ) {
    return _syncUseCase.watchLocalChangedIds().listen((wordIds) async {
      if (wordIds.isEmpty) return;

      for (final wordId in wordIds) {
        print("local: ${wordId}!!!!!!!!!status UPDATED ");
        final result = await _syncUseCase.syncOnUpdatedLocal(userId, wordId);
        result.when(
          success: (_) => print('[SyncService] Local sync for wordId $wordId completed'),
          failure: (error) => print('[SyncService] Local sync for wordId $wordId failed: ${error.message}'),
        );
      }
    });
  }

  // void dispose() {
  //   _remoteSub?.cancel();
  //   _remoteSub = null;
  //   _localSub?.cancel();
  //   _localSub = null;
  // }
}
