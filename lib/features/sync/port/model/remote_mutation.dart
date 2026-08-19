import 'dart:collection';

/// すべての同期データセットで共有する、完全で冪等なリモート書き込みコントラクトです。
/// リモートドキュメント識別子も文字列であるため、この境界ではエンティティ識別子も文字列に保ちます。
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

/// 信頼できるリモートトランザクションから読み取った結果です。
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
