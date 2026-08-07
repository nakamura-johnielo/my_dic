import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/app/bootstrap/firebase_remote_mutation_transaction.dart';
import 'package:my_dic/features/my_word/data/sync/remote/myword/firebase_my_word_dto.dart';
import 'package:my_dic/features/sync/application/model/remote_mutation.dart';
import 'package:my_dic/features/user/data/dto/user_dto.dart';

class FirebaseMyWordDao {
  final FirebaseFirestore _db;

  FirebaseMyWordDao(this._db);

  /// Get a single MyWord by ID
  Future<MyWordDTO?> getMyWord(String userId, String myWordId) async {
    final doc = await _db
        .collection(UserDTO.collectionName)
        .doc(userId)
        .collection(MyWordDTO.collectionName)
        .doc(myWordId)
        .get();
    if (!doc.exists || doc.data() == null) return null;
    return MyWordDTO.fromFirebase(doc);
  }

  /// Get MyWords updated after a specific timestamp (one-time query)
  Future<List<MyWordDTO>> getMyWordsAfter(
      String userId, DateTime lastSync) async {
    final querySnapshot = await _db
        .collection(UserDTO.collectionName)
        .doc(userId)
        .collection(MyWordDTO.collectionName)
        .where(MyWordDTO.fieldUpdatedAt,
            isGreaterThanOrEqualTo: Timestamp.fromDate(lastSync))
        .get();

    if (querySnapshot.docs.isEmpty) return [];

    return querySnapshot.docs
        .map((doc) => MyWordDTO.fromFirebase(doc))
        .toList();
  }

  /// Merge-writes only [fieldMask] keys plus bookkeeping timestamps, so that
  /// fields not covered by the sync outbox mutation are left untouched.
  /// `deletedAt` values arrive as ISO-8601 strings and are converted to a
  /// Firestore `Timestamp` tombstone marker.
  Future<RemoteMutationAck> patch(RemoteMutationRequest request) {
    final docRef = _db
        .collection(UserDTO.collectionName)
        .doc(request.accountId)
        .collection(MyWordDTO.collectionName)
        .doc(request.entityId);
    return RemoteMutationTransaction.apply(
      firestore: _db,
      reference: docRef,
      request: request,
      identityFields: {MyWordDTO.fieldMyWordId: request.entityId},
      encodeField: (field, value) => {
        field: field == MyWordDTO.fieldDeletedAt && value is String
            ? Timestamp.fromDate(DateTime.parse(value).toUtc())
            : value,
      },
    );
  }
}
