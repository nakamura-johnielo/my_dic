import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/features/sync/port/dataset_contract.dart';

/// 同期機能がFirestore上のドキュメントを安全に更新するための実装。
/// オフラインや複数端末からの同期更新を、重複・競合に配慮してFirestoreへ適用し、その結果を返すアダプター
///
/// Syncのリモートミューテーション契約を、アプリ側が所有するFirestore実装として実装したものです。
/// データセットの所有者は、ドキュメントパスとSDKを使用しない形式でエンコードされたフィールド値を指定します。
/// このアダプターは、SDKによる値の変換、トランザクション、および確認応答の処理を管理します。
final class FirebaseRemoteMutationExecutor implements RemoteMutationExecutor {
  FirebaseRemoteMutationExecutor(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<RemoteMutationAck> execute({
    required RemoteMutationDocument document,
    required RemoteMutationRequest request,
  }) {
    final reference = _referenceFor(document.pathSegments);
    return _apply(
      reference: reference,
      request: request,
      identityFields: document.identityFields,
      encodedFields: document.encodedFields,
    );
  }

  DocumentReference<Map<String, dynamic>> _referenceFor(
    List<String> pathSegments,
  ) {
    DocumentReference<Map<String, dynamic>> reference =
        _firestore.collection(pathSegments[0]).doc(pathSegments[1]);
    for (var index = 2; index < pathSegments.length; index += 2) {
      reference = reference
          .collection(pathSegments[index])
          .doc(pathSegments[index + 1]);
    }
    return reference;
  }

  Future<RemoteMutationAck> _apply({
    required DocumentReference<Map<String, dynamic>> reference,
    required RemoteMutationRequest request,
    required Map<String, Object?> identityFields,
    required Map<String, Object?> encodedFields,
  }) async {
    final provisional = await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);
      final existing = snapshot.data();
      final revision = _revisionOf(existing?['revision']);
      final lastMutationId = existing?['lastMutationId'] as String?;
      final priorClientUpdatedAt = _dateOf(existing?['clientUpdatedAt']) ??
          _dateOf(existing?['updatedAt']);
      if (lastMutationId == request.mutationId) {
        return _ProvisionalAck(
          RemoteMutationAckStatus.duplicate,
          revision,
          lastMutationId,
        );
      }
      if (priorClientUpdatedAt != null &&
          !request.clientUpdatedAt.isAfter(priorClientUpdatedAt)) {
        return _ProvisionalAck(
          RemoteMutationAckStatus.superseded,
          revision,
          lastMutationId,
        );
      }
      final data = <String, dynamic>{...identityFields};
      data.addAll({
        for (final entry in encodedFields.entries)
          entry.key: _encodeValue(entry.value),
      });
      data.addAll({
        'revision': revision + 1,
        'lastMutationId': request.mutationId,
        'clientUpdatedAt': Timestamp.fromDate(request.clientUpdatedAt),
        'updatedAt': FieldValue.serverTimestamp(),
        'schemaVersion': 1,
      });
      if (!snapshot.exists) data['createdAt'] = FieldValue.serverTimestamp();
      transaction.set(reference, data, SetOptions(merge: true));
      return _ProvisionalAck(
        RemoteMutationAckStatus.applied,
        revision + 1,
        request.mutationId,
      );
    });
    final committed = await reference.get();
    return RemoteMutationAck(
      status: provisional.status,
      remoteRevision: provisional.remoteRevision,
      lastMutationId: provisional.lastMutationId,
      serverUpdatedAt: _dateOf(committed.data()?['updatedAt']),
    );
  }

  static int _revisionOf(Object? value) =>
      value is int && value >= 0 ? value : 0;

  static Object? _encodeValue(Object? value) =>
      value is DateTime ? Timestamp.fromDate(value.toUtc()) : value;

  static DateTime? _dateOf(Object? value) {
    if (value is Timestamp) return value.toDate().toUtc();
    if (value is DateTime) return value.toUtc();
    if (value is String) return DateTime.tryParse(value)?.toUtc();
    return null;
  }
}

final class _ProvisionalAck {
  const _ProvisionalAck(
    this.status,
    this.remoteRevision,
    this.lastMutationId,
  );

  final RemoteMutationAckStatus status;
  final int remoteRevision;
  final String? lastMutationId;
}
