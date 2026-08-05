import 'dart:collection';

import 'package:my_dic/core/shared/enums/sync_dataset.dart';

enum SyncMutationOperation { upsert, patch, delete }

class SyncMutation {
  SyncMutation({
    required this.mutationId,
    required this.accountId,
    required this.dataset,
    required this.entityId,
    required this.operation,
    required Map<String, Object?> payload,
    required Iterable<String> fieldMask,
    required this.localRevision,
    this.baseRemoteRevision,
    this.payloadVersion = 1,
  })  : payload = UnmodifiableMapView(Map.of(payload)),
        fieldMask = List.unmodifiable(fieldMask),
        assert(mutationId != ''),
        assert(accountId != ''),
        assert(entityId != ''),
        assert(localRevision >= 0),
        assert(payloadVersion > 0);

  final String mutationId;
  final String accountId;
  final SyncDataset dataset;
  final String entityId;
  final SyncMutationOperation operation;
  final Map<String, Object?> payload;
  final List<String> fieldMask;
  final int payloadVersion;
  final int localRevision;
  final String? baseRemoteRevision;
}

typedef EnqueueMutation = SyncMutation;
