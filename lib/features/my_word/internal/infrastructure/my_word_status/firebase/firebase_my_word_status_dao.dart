import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word_status/firebase/firebase_my_word_status_dto.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/my_word_status/firebase/firebase_my_word_status_mapper.dart';
import 'package:my_dic/features/sync/port/model/remote_mutation.dart';
import 'package:my_dic/features/sync/port/remote_mutation_executor.dart';
import 'package:my_dic/features/user_profile/port/user_dto.dart';

class FirebaseMyWordStatusDao {
  final FirebaseFirestore _db;
  final RemoteMutationExecutor _remoteMutations;

  FirebaseMyWordStatusDao(this._db, this._remoteMutations);

  /// Get a single MyWordStatus by word ID
  Future<MyWordStatusDTO?> getStatus(String userId, String myWordId) async {
    final doc = await _db
        .collection(UserDTO.collectionName)
        .doc(userId)
        .collection(MyWordStatusDTO.collectionName)
        .doc(myWordId)
        .get();
    if (!doc.exists || doc.data() == null) return null;
    return FirebaseMyWordStatusMapper.fromDocument(doc);
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
        .map(FirebaseMyWordStatusMapper.fromDocument)
        .toList();
  }

  /// Merge-writes only [fieldMask] keys plus bookkeeping timestamps, so that
  /// fields not covered by the sync outbox mutation are left untouched. Bool
  /// payload values are converted to the DTO's 0/1 int convention.
  Future<RemoteMutationAck> patch(RemoteMutationRequest request) {
    return _remoteMutations.execute(
      target: RemoteMutationTarget.myWordStatus,
      request: request,
    );
  }
}
