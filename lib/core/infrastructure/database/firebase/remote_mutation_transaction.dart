import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/features/sync/application/model/remote_mutation.dart';

/// Applies a field-mask mutation together with its sync metadata in a single
/// Firestore transaction. Dataset DAOs provide only their document reference,
/// immutable identity fields, and payload conversion.
class RemoteMutationTransaction {
  static const fieldRevision = 'revision';
  static const fieldLastMutationId = 'lastMutationId';
  static const fieldClientUpdatedAt = 'clientUpdatedAt';
  static const fieldUpdatedAt = 'updatedAt';
  static const fieldCreatedAt = 'createdAt';
  static const fieldSchemaVersion = 'schemaVersion';

  static Future<RemoteMutationAck> apply({
    required FirebaseFirestore firestore,
    required DocumentReference<Map<String, dynamic>> reference,
    required RemoteMutationRequest request,
    required Map<String, dynamic> identityFields,
    required Map<String, dynamic> Function(String field, Object? value)
        encodeField,
  }) async {
    final provisional = await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);
      final existing = snapshot.data();
      final revision = _revisionOf(existing?[fieldRevision]);
      final lastMutationId = existing?[fieldLastMutationId] as String?;
      final priorClientUpdatedAt = _dateOf(existing?[fieldClientUpdatedAt]) ??
          _dateOf(existing?[fieldUpdatedAt]);

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
      for (final field in request.fieldMask) {
        data.addAll(encodeField(field, request.fields[field]));
      }
      data.addAll({
        fieldRevision: revision + 1,
        fieldLastMutationId: request.mutationId,
        fieldClientUpdatedAt: Timestamp.fromDate(request.clientUpdatedAt),
        fieldUpdatedAt: FieldValue.serverTimestamp(),
        fieldSchemaVersion: 1,
      });
      if (!snapshot.exists) {
        data[fieldCreatedAt] = FieldValue.serverTimestamp();
      }
      transaction.set(reference, data, SetOptions(merge: true));
      return _ProvisionalAck(
        RemoteMutationAckStatus.applied,
        revision + 1,
        request.mutationId,
      );
    });

    // A server timestamp is resolved after the transaction commits. Read it
    // back so callers can persist the authoritative pull/ack metadata.
    final committed = await reference.get();
    return RemoteMutationAck(
      status: provisional.status,
      remoteRevision: provisional.remoteRevision,
      lastMutationId: provisional.lastMutationId,
      serverUpdatedAt: _dateOf(committed.data()?[fieldUpdatedAt]),
    );
  }

  static int _revisionOf(Object? value) =>
      value is int && value >= 0 ? value : 0;

  static DateTime? _dateOf(Object? value) {
    if (value is Timestamp) return value.toDate().toUtc();
    if (value is DateTime) return value.toUtc();
    if (value is String) return DateTime.tryParse(value)?.toUtc();
    return null;
  }
}

class _ProvisionalAck {
  const _ProvisionalAck(this.status, this.remoteRevision, this.lastMutationId);

  final RemoteMutationAckStatus status;
  final int remoteRevision;
  final String? lastMutationId;
}
