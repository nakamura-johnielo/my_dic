import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/app/bootstrap/firebase_remote_mutation_transaction.dart';
import 'package:my_dic/features/esp_jpn_word_status/data/sync/remote/firebase_word_status_mapper.dart';
import 'package:my_dic/features/esp_jpn_word_status/data/word_status_entity.dart';
import 'package:my_dic/features/sync/application/model/remote_mutation.dart';
import 'package:my_dic/features/sync/application/model/sync_cursor.dart';
import 'package:my_dic/features/user/data/dto/user_dto.dart';

class FirebaseWordStatusDao {
  FirebaseWordStatusDao(this._db);

  final FirebaseFirestore _db;

  Future<WordStatusDTO?> getWordStatus(String userId, int wordId) async {
    final doc = await _collection(userId).doc(wordId.toString()).get();
    if (!doc.exists || doc.data() == null) return null;
    return FirebaseWordStatusMapper.fromDocument(doc);
  }

  Future<RemoteMutationAck> patch(RemoteMutationRequest request) {
    return RemoteMutationTransaction.apply(
      firestore: _db,
      reference: _collection(request.accountId).doc(request.entityId),
      request: request,
      identityFields: {WordStatusDTO.fieldwordId: int.parse(request.entityId)},
      encodeField: (field, value) =>
          {field: value is bool ? (value ? 1 : 0) : value},
    );
  }

  /// Fetches from an inclusive `(updatedAt, documentId)` cursor. Ordering by
  /// document ID gives a stable tie-breaker when multiple updates share a timestamp.
  Future<List<WordStatusDTO>> fetchPage(
      String userId, SyncCursor? cursor) async {
    Query<Map<String, dynamic>> query = _collection(userId)
        .orderBy(WordStatusDTO.fieldUpdatedAt)
        .orderBy(FieldPath.documentId);
    if (cursor != null) {
      query = query.startAt([
        Timestamp(cursor.seconds, cursor.nanoseconds),
        cursor.documentId,
      ]);
    }
    final snapshot = await query.get();
    return snapshot.docs.map(FirebaseWordStatusMapper.fromDocument).toList();
  }

  CollectionReference<Map<String, dynamic>> _collection(String userId) => _db
      .collection(UserDTO.collectionName)
      .doc(userId)
      .collection(WordStatusDTO.collectionName);
}
