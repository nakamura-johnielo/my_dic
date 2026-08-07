import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/app/bootstrap/firebase_remote_mutation_transaction.dart';
import 'package:my_dic/features/my_word/data/sync/remote/status/firebase_my_word_status_dto.dart';
import 'package:my_dic/features/sync/application/model/remote_mutation.dart';
import 'package:my_dic/features/user/data/dto/user_dto.dart';

class FirebaseMyWordStatusDao {
  final FirebaseFirestore _db;

  FirebaseMyWordStatusDao(this._db);

  /// Get a single MyWordStatus by word ID
  Future<MyWordStatusDTO?> getStatus(String userId, String myWordId) async {
    final doc = await _db
        .collection(UserDTO.collectionName)
        .doc(userId)
        .collection(MyWordStatusDTO.collectionName)
        .doc(myWordId)
        .get();
    if (!doc.exists || doc.data() == null) return null;
    return MyWordStatusDTO.fromFirebase(doc);
  }

  /// Get MyWordStatus updated after a specific timestamp (one-time query)
  Future<List<MyWordStatusDTO>> getStatusAfter(
      String userId, DateTime lastSync) async {
    final querySnapshot = await _db
        .collection(UserDTO.collectionName)
        .doc(userId)
        .collection(MyWordStatusDTO.collectionName)
        .where(MyWordStatusDTO.fieldUpdatedAt,
            isGreaterThanOrEqualTo: Timestamp.fromDate(lastSync))
        .get();

    if (querySnapshot.docs.isEmpty) return [];

    return querySnapshot.docs
        .map((doc) => MyWordStatusDTO.fromFirebase(doc))
        .toList();
  }

  /// Merge-writes only [fieldMask] keys plus bookkeeping timestamps, so that
  /// fields not covered by the sync outbox mutation are left untouched. Bool
  /// payload values are converted to the DTO's 0/1 int convention.
  Future<RemoteMutationAck> patch(RemoteMutationRequest request) {
    final docRef = _db
        .collection(UserDTO.collectionName)
        .doc(request.accountId)
        .collection(MyWordStatusDTO.collectionName)
        .doc(request.entityId);
    return RemoteMutationTransaction.apply(
      firestore: _db,
      reference: docRef,
      request: request,
      identityFields: {MyWordStatusDTO.fieldMyWordId: request.entityId},
      encodeField: (field, value) => {
        field: value is bool ? (value ? 1 : 0) : value,
      },
    );
  }
}
