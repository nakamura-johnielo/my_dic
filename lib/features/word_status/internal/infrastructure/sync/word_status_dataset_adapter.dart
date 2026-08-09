import 'package:my_dic/core/shared/enums/sync_dataset.dart';
import 'package:my_dic/features/sync/application/model/remote_mutation.dart';
import 'package:my_dic/features/sync/application/model/sync_cursor.dart';
import 'word_status_sync_record.dart';

/// Direction-specific bridge between the common sync algorithm and its stores.
abstract interface class WordStatusDatasetAdapter {
  SyncDataset get dataset;

  Future<RemoteMutationAck> patch(RemoteMutationRequest request);
  Future<List<WordStatusSyncRecord>> fetchPage(
    String accountId,
    SyncCursor? cursor,
  );
  Future<T> transaction<T>(Future<T> Function() action);
  Future<bool> acknowledge({
    required int wordId,
    required String accountId,
    required int localRevision,
    required String remoteRevision,
    required String? lastMutationId,
  });
  Future<void> applyRemote(
    WordStatusSyncRecord record, {
    required String accountId,
    required Set<String> skippedFields,
  });
}
