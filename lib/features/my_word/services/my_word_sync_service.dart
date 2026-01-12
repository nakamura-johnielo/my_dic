import 'dart:async';

import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/domain/usecase/sync_my_word/i_sync_my_word_usecase.dart';

class MyWordSyncService {
  final ISyncMyWordUseCase _syncUseCase;

  MyWordSyncService(this._syncUseCase);

  /// One-shot sync.
  Future<void> syncOnce(String userId) async {
    final Result<void> result = await _syncUseCase.syncOnce(userId);
    result.when(
      success: (_) => print('[MyWord Sync] Sync completed successfully'),
      failure: (error) => print('[MyWord Sync] Sync failed: ${error.message}'),
    );
  }

  /// Remote-driven incremental sync (NO local watcher to avoid ping-pong loops).
  StreamSubscription<List<int>> startSyncWithRemote(String userId) {
    return _syncUseCase.watchRemoteChangedIds(userId).listen((wordIds) async {
      if (wordIds.isEmpty) return;

      for (final wordId in wordIds) {
        final Result<void> result =
            await _syncUseCase.syncOnUpdatedRemote(userId, wordId);
        result.when(
          success: (_) => print('[MyWord Sync] Remote sync wordId=$wordId OK'),
          failure: (error) =>
              print('[MyWord Sync] Remote sync wordId=$wordId NG: ${error.message}'),
        );
      }
    });
  }

  Stream<List<int>> watchRemoteChangedIds(String userId) {
    return _syncUseCase.watchRemoteChangedIds(userId);
  }

  Stream<List<int>> watchLocalChangedIds() {
    return _syncUseCase.watchLocalChangedIds();
  }

  Future<void> syncOnUpdatedRemote(String userId, int wordId) async {
    final result = await _syncUseCase.syncOnUpdatedRemote(userId, wordId);
    result.when(
      success: (_) => print('[MyWord Sync] Remote sync wordId=$wordId OK'),
      failure: (error) =>
          print('[MyWord Sync] Remote sync wordId=$wordId NG: ${error.message}'),
    );
  }

  Future<void> syncOnUpdatedLocal(String userId, int wordId) async {
    final result = await _syncUseCase.syncOnUpdatedLocal(userId, wordId);
    result.when(
      success: (_) => print('[MyWord Sync] Local sync wordId=$wordId OK'),
      failure: (error) =>
          print('[MyWord Sync] Local sync wordId=$wordId NG: ${error.message}'),
    );
  }
}
