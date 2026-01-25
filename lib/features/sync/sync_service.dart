import 'dart:async';
import 'package:async/async.dart';

import 'package:my_dic/core/domain/usecase/i_sync_usecase.dart';
import 'package:my_dic/core/shared/utils/result.dart';

class SyncService {
   final List<ISyncUseCase> _syncUseCases;
    List<List<ISyncUseCase>> get syncUsecasePriorityGroups => _groupByPriority();

  SyncService(List<ISyncUseCase> syncUseCases)
      : _syncUseCases = syncUseCases..sort((a, b) => a.priority.compareTo(b.priority));


   List<List<ISyncUseCase>> _groupByPriority() {
    final grouped = <List<ISyncUseCase>>[];
    final seen = <int>{};
    for (final uc in _syncUseCases) {
      if (seen.contains(uc.priority)) {
        grouped.last.add(uc);
      } else {
        seen.add(uc.priority);
        grouped.add([uc]);
      }
    }
    return grouped;
  }


  Future<void> syncOnceAll(String userId) async {
    // Execute groups (same priority) in parallel, groups sequentially
    for (final group in syncUsecasePriorityGroups) {
      final futures = group.map((uc) => uc.syncOnce(userId)).toList();
      final results = await Future.wait(futures);

      for (var i = 0; i < group.length; i++) {
        final useCase = group[i];
        final result = results[i];
        result.when(
          success: (_) => print(
              '[SyncService] Sync completed successfully for use case with priority ${useCase.runtimeType}'),
          failure: (error) => print(
              '[SyncService] Sync failed for use case with priority ${useCase.runtimeType}: ${error.message}'),
        );
      }
    }

    // await Future.wait(_syncUseCases.map((usecase) => usecase.syncOnce(userId)));
  }

  StreamSubscription startSyncWithRemote(
    String userId,
  ) {
       final streams = _syncUseCases
        .map((usecase) => usecase.watchRemoteChangedIds(userId)
            .map((ids) => (usecase, ids)));

    return StreamGroup.merge(streams).listen((pair) async {
      final (usecase, ids) = pair;
      for (final id in ids) {
        await usecase.syncOnUpdatedRemote(userId, id.toString());
      }
    });
  }
}
