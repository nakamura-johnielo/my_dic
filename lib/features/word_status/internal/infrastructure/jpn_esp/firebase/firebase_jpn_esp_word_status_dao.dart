import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/features/sync/port/model/remote_mutation.dart';
import 'package:my_dic/features/sync/port/remote_mutation_executor.dart';
import 'package:my_dic/features/sync/port/model/sync_cursor.dart';
import 'package:my_dic/features/user_profile/port/user_dto.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/firebase/jpn_esp_word_status_dto.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/firebase/jpn_esp_word_status_mapper.dart';

/// Firestore persistence for the Jpn-Esp word-status dataset.
final class FirebaseJpnEspWordStatusDao {
  FirebaseJpnEspWordStatusDao(this._firestore, this._remoteMutations);

  final FirebaseFirestore _firestore;
  final RemoteMutationExecutor _remoteMutations;

  Future<JpnEspWordStatusDto?> getWordStatus(
    String accountId,
    int wordId,
  ) async {
    final document = await _collection(accountId).doc(wordId.toString()).get();
    if (!document.exists || document.data() == null) return null;
    return JpnEspWordStatusMapper.fromDocument(document);
  }

  Future<RemoteMutationAck> patch(RemoteMutationRequest request) {
    return _remoteMutations.execute(
      target: RemoteMutationTarget.jpnEspWordStatus,
      request: request,
    );
  }

  /// Fetches from an inclusive `(updatedAt, documentId)` cursor. Document ID
  /// is the stable tie-breaker for documents with the same update timestamp.
  Future<List<JpnEspWordStatusDto>> fetchPage(
    String accountId,
    SyncCursor? cursor,
  ) async {
    Query<Map<String, dynamic>> query = _collection(accountId)
        .orderBy(JpnEspWordStatusDto.fieldUpdatedAt)
        .orderBy(FieldPath.documentId);
    if (cursor != null) {
      query = query.startAt([
        Timestamp(cursor.seconds, cursor.nanoseconds),
        cursor.documentId,
      ]);
    }
    final snapshot = await query.get();
    return snapshot.docs.map(JpnEspWordStatusMapper.fromDocument).toList();
  }

  CollectionReference<Map<String, dynamic>> _collection(String accountId) =>
      _firestore
          .collection(UserDTO.collectionName)
          .doc(accountId)
          .collection(JpnEspWordStatusDto.collectionName);
}
