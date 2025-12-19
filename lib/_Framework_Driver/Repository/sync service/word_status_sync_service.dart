import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/core/infrastructure/database/dao/local/word_status_dao.dart';
import 'package:my_dic/core/infrastructure/database/database_provider.dart';
import 'package:my_dic/core/infrastructure/dto/wordStatusEntity.dart';

import 'package:my_dic/core/infrastructure/database/dao/local/word_status_dao.dart'
    as local;
import 'package:my_dic/core/infrastructure/database/dao/remote/word_status_dao.dart'
    as remote;

class WordStatusSyncService {
  final remote.FirebaseWordStatusDao _remote;
  final local.WordStatusDao _local;

  WordStatusSyncService(this._remote, this._local);

  StreamSubscription<List<WordStatusEntity>>? _sub;

  /// 同期開始。onSynced: 同期処理後に最新 updatedAt を渡す
  void startSync(
      String userId, DateTime lastSync, void Function(DateTime) onSynced) {
    _sub?.cancel();
    _sub = _remote.watchUpdatedAfter(userId, lastSync).listen((entities) async {
      if (entities.isEmpty) return;
      DateTime maxUpdated = lastSync;
      for (final entity in entities) {
        print(
            "${entity.wordId}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!status UPDATED");
        await _local.updateStatus(
          WordStatusTableData(
            wordId: entity.wordId,
            isLearned: entity.isLearned,
            isBookmarked: entity.isBookmarked,
            hasNote: entity.hasNote,
            editAt: entity.updatedAt.toIso8601String(),
          ),
        );
        if (entity.updatedAt.isAfter(maxUpdated)) {
          maxUpdated = entity.updatedAt;
        }
      }
      onSynced(maxUpdated);
    });
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }
}
