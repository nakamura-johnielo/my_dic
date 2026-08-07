import 'dart:collection';

/// The complete, idempotent remote-write contract shared by every sync
/// dataset. Entity identifiers stay strings at this boundary because Firestore
/// document identifiers are strings as well.
class RemoteMutationRequest {
  RemoteMutationRequest({
    required this.accountId,
    required this.entityId,
    required this.mutationId,
    required Map<String, Object?> fields,
    required Iterable<String> fieldMask,
    required DateTime clientUpdatedAt,
    this.baseRemoteRevision,
  })  : fields = UnmodifiableMapView(Map.of(fields)),
        fieldMask = List.unmodifiable(fieldMask),
        clientUpdatedAt = clientUpdatedAt.toUtc(),
        assert(accountId != ''),
        assert(entityId != ''),
        assert(mutationId != ''),
        assert(fieldMask.every(fields.containsKey));

  final String accountId;
  final String entityId;
  final String mutationId;
  final Map<String, Object?> fields;
  final List<String> fieldMask;
  final DateTime clientUpdatedAt;
  final String? baseRemoteRevision;
}

enum RemoteMutationAckStatus { applied, duplicate, superseded }

/// Result read from the authoritative Firestore transaction.
class RemoteMutationAck {
  const RemoteMutationAck({
    required this.status,
    required this.remoteRevision,
    required this.lastMutationId,
    required this.serverUpdatedAt,
  });

  final RemoteMutationAckStatus status;
  final int remoteRevision;
  final String? lastMutationId;
  final DateTime? serverUpdatedAt;
}
