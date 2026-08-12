import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word/firebase/firebase_my_word_dto.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word/firebase/firebase_my_word_mapper.dart';
import 'package:my_dic/features/sync/port/model/remote_mutation.dart';
import 'package:my_dic/features/sync/port/remote_mutation_executor.dart';
import 'package:my_dic/features/user_profile/port/user_dto.dart';

class FirebaseMyWordDao {
  final FirebaseFirestore _db;
  final RemoteMutationExecutor _remoteMutations;

  FirebaseMyWordDao(this._db, this._remoteMutations);

  /// Get a single MyWord by ID
  Future<MyWordDTO?> getMyWord(String userId, String myWordId) async {
    final doc = await _db
        .collection(UserDTO.collectionName)
        .doc(userId)
        .collection(MyWordDTO.collectionName)
        .doc(myWordId)
        .get();
    if (!doc.exists || doc.data() == null) return null;
    return FirebaseMyWordMapper.fromDocument(doc);
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

    return querySnapshot.docs.map(FirebaseMyWordMapper.fromDocument).toList();
  }

  /// Merge-writes only [fieldMask] keys plus bookkeeping timestamps, so that
  /// fields not covered by the sync outbox mutation are left untouched.
  /// `deletedAt` values arrive as ISO-8601 strings and are converted to a
  /// Firestore `Timestamp` tombstone marker.
  Future<RemoteMutationAck> patch(RemoteMutationRequest request) {
    return _remoteMutations.execute(
      target: RemoteMutationTarget.myWord,
      request: request,
    );
  }
}
