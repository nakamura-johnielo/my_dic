import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/features/sync/port/model/remote_mutation.dart';
import 'package:my_dic/features/sync/port/remote_mutation_executor.dart';

/// Firestore implementation of the Sync remote-mutation port.
///
/// This class is the sole owner of transaction metadata and dataset wire-value
/// mapping; feature adapters supply only a target and pure request.
final class FirebaseRemoteMutationExecutor implements RemoteMutationExecutor {
  FirebaseRemoteMutationExecutor(this._firestore);

  static const _users = 'Users';
  static const _myWords = 'MyWords';
  static const _myWordStatuses = 'MyWordStatus';
  static const _espJpnWordStatuses = 'WordStatus';
  static const _jpnEspWordStatuses = 'JpnEspWordStatus';

  final FirebaseFirestore _firestore;

  @override
  Future<RemoteMutationAck> execute({
    required RemoteMutationTarget target,
    required RemoteMutationRequest request,
  }) {
    final reference = _referenceFor(target, request);
    return _apply(
      reference: reference,
      request: request,
      identityFields: _identityFields(target, request),
      encodeField: (field, value) => _encodeField(target, field, value),
    );
  }

  @override
  Future<RemoteUserProfileProvisioningResult> provisionUserProfile(
    RemoteUserProfileProvisioningRequest request,
  ) {
    final reference = _firestore.collection(_users).doc(request.accountId);
    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);
      final existing = snapshot.data();
      if (snapshot.exists && existing != null) {
        return RemoteUserProfileProvisioningResult(
          alreadyExisted: true,
          fields: _userProfileFields(existing),
        );
      }
      transaction.set(reference, {
        'userId': request.accountId,
        if (request.email != null && request.email!.isNotEmpty)
          'email': request.email,
        if (request.userName != null && request.userName!.isNotEmpty)
          'userName': request.userName,
        'subscriptionStatus': 'free',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'clientUpdatedAt': FieldValue.serverTimestamp(),
        'revision': 0,
        'lastMutationId': null,
        'schemaVersion': 1,
      });
      return RemoteUserProfileProvisioningResult(alreadyExisted: false);
    });
  }

  DocumentReference<Map<String, dynamic>> _referenceFor(
    RemoteMutationTarget target,
    RemoteMutationRequest request,
  ) {
    final user = _firestore.collection(_users).doc(request.accountId);
    return switch (target) {
      RemoteMutationTarget.myWord => user.collection(_myWords).doc(request.entityId),
      RemoteMutationTarget.myWordStatus =>
        user.collection(_myWordStatuses).doc(request.entityId),
      RemoteMutationTarget.userProfile => user,
      RemoteMutationTarget.espJpnWordStatus =>
        user.collection(_espJpnWordStatuses).doc(request.entityId),
      RemoteMutationTarget.jpnEspWordStatus =>
        user.collection(_jpnEspWordStatuses).doc(request.entityId),
    };
  }

  Map<String, dynamic> _identityFields(
    RemoteMutationTarget target,
    RemoteMutationRequest request,
  ) => switch (target) {
        RemoteMutationTarget.myWord => {'wordId': request.entityId},
        RemoteMutationTarget.myWordStatus => {'myWordId': request.entityId},
        RemoteMutationTarget.userProfile => {'userId': request.accountId},
        RemoteMutationTarget.espJpnWordStatus => {'wordId': int.parse(request.entityId)},
        RemoteMutationTarget.jpnEspWordStatus => {'wordId': int.parse(request.entityId)},
      };

  Map<String, dynamic> _encodeField(
    RemoteMutationTarget target,
    String field,
    Object? value,
  ) {
    if (target == RemoteMutationTarget.userProfile) {
      return field == 'username' ? {'userName': value} : const {};
    }
    if (target == RemoteMutationTarget.myWord && field == 'deletedAt' && value is String) {
      return {field: Timestamp.fromDate(DateTime.parse(value).toUtc())};
    }
    if (target != RemoteMutationTarget.myWord && value is bool) {
      return {field: value ? 1 : 0};
    }
    return {field: value};
  }

  Future<RemoteMutationAck> _apply({
    required DocumentReference<Map<String, dynamic>> reference,
    required RemoteMutationRequest request,
    required Map<String, dynamic> identityFields,
    required Map<String, dynamic> Function(String field, Object? value) encodeField,
  }) async {
    final provisional = await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);
      final existing = snapshot.data();
      final revision = _revisionOf(existing?['revision']);
      final lastMutationId = existing?['lastMutationId'] as String?;
      final priorClientUpdatedAt = _dateOf(existing?['clientUpdatedAt']) ?? _dateOf(existing?['updatedAt']);
      if (lastMutationId == request.mutationId) {
        return _ProvisionalAck(RemoteMutationAckStatus.duplicate, revision, lastMutationId);
      }
      if (priorClientUpdatedAt != null && !request.clientUpdatedAt.isAfter(priorClientUpdatedAt)) {
        return _ProvisionalAck(RemoteMutationAckStatus.superseded, revision, lastMutationId);
      }
      final data = <String, dynamic>{...identityFields};
      for (final field in request.fieldMask) {
        data.addAll(encodeField(field, request.fields[field]));
      }
      data.addAll({
        'revision': revision + 1,
        'lastMutationId': request.mutationId,
        'clientUpdatedAt': Timestamp.fromDate(request.clientUpdatedAt),
        'updatedAt': FieldValue.serverTimestamp(),
        'schemaVersion': 1,
      });
      if (!snapshot.exists) data['createdAt'] = FieldValue.serverTimestamp();
      transaction.set(reference, data, SetOptions(merge: true));
      return _ProvisionalAck(RemoteMutationAckStatus.applied, revision + 1, request.mutationId);
    });
    final committed = await reference.get();
    return RemoteMutationAck(
      status: provisional.status,
      remoteRevision: provisional.remoteRevision,
      lastMutationId: provisional.lastMutationId,
      serverUpdatedAt: _dateOf(committed.data()?['updatedAt']),
    );
  }

  static int _revisionOf(Object? value) => value is int && value >= 0 ? value : 0;

  static Map<String, Object?> _userProfileFields(
    Map<String, dynamic> data,
  ) => {
        ...data,
        'createdAt': _dateOf(data['createdAt']),
        'updatedAt': _dateOf(data['updatedAt']),
        'clientUpdatedAt': _dateOf(data['clientUpdatedAt']),
      };

  static DateTime? _dateOf(Object? value) {
    if (value is Timestamp) return value.toDate().toUtc();
    if (value is DateTime) return value.toUtc();
    if (value is String) return DateTime.tryParse(value)?.toUtc();
    return null;
  }
}

final class _ProvisionalAck {
  const _ProvisionalAck(this.status, this.remoteRevision, this.lastMutationId);
  final RemoteMutationAckStatus status;
  final int remoteRevision;
  final String? lastMutationId;
}
