import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/app/bootstrap/firebase_remote_mutation_transaction.dart';
import 'package:my_dic/features/jpn_esp_word_status/data/jpn_esp_word_status_entity.dart';
import 'package:my_dic/features/jpn_esp_word_status/data/sync/remote/firebase_jpn_esp_word_status_mapper.dart';
import 'package:my_dic/features/sync/application/model/remote_mutation.dart';
import 'package:my_dic/features/sync/application/model/sync_cursor.dart';
import 'package:my_dic/features/user/data/dto/user_dto.dart';

class FirebaseJpnEspWordStatusDao {
  FirebaseJpnEspWordStatusDao(this._db);

  final FirebaseFirestore _db;

  Future<JpnEspWordStatusDTO?> getWordStatus(String userId, int wordId) async {
    final doc = await _collection(userId).doc(wordId.toString()).get();
    if (!doc.exists || doc.data() == null) return null;
    return FirebaseJpnEspWordStatusMapper.fromDocument(doc);
  }

  Future<RemoteMutationAck> patch(RemoteMutationRequest request) {
    return RemoteMutationTransaction.apply(
      firestore: _db,
      reference: _collection(request.accountId).doc(request.entityId),
      request: request,
      identityFields: {
        JpnEspWordStatusDTO.fieldwordId: int.parse(request.entityId),
      },
      encodeField: (field, value) =>
          {field: value is bool ? (value ? 1 : 0) : value},
    );
  }

  /// Fetches from an inclusive `(updatedAt, documentId)` cursor. In particular,
  /// this preserves Jpn-Esp rows that have the same timestamp as the checkpoint.
  Future<List<JpnEspWordStatusDTO>> fetchPage(
      String userId, SyncCursor? cursor) async {
    Query<Map<String, dynamic>> query = _collection(userId)
        .orderBy(JpnEspWordStatusDTO.fieldUpdatedAt)
        .orderBy(FieldPath.documentId);
    if (cursor != null) {
      query = query.startAt([
        Timestamp(cursor.seconds, cursor.nanoseconds),
        cursor.documentId,
      ]);
    }
    final snapshot = await query.get();
    return snapshot.docs
        .map(FirebaseJpnEspWordStatusMapper.fromDocument)
        .toList();
  }

  CollectionReference<Map<String, dynamic>> _collection(String userId) => _db
      .collection(UserDTO.collectionName)
      .doc(userId)
      .collection(JpnEspWordStatusDTO.collectionName);
}
