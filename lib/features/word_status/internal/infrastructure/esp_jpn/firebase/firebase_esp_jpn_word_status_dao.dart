import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/features/sync/port/model/remote_mutation.dart';
import 'package:my_dic/features/sync/port/remote_mutation_executor.dart';
import 'package:my_dic/features/sync/port/model/sync_cursor.dart';
import 'package:my_dic/features/user_profile/port/user_dto.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/firebase/esp_jpn_word_status_dto.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/firebase/esp_jpn_word_status_mapper.dart';

/// Firestore persistence for the Esp-Jpn word-status dataset.
final class FirebaseEspJpnWordStatusDao {
  FirebaseEspJpnWordStatusDao(this._firestore, this._remoteMutations);

  final FirebaseFirestore _firestore;
  final RemoteMutationExecutor _remoteMutations;

  Future<EspJpnWordStatusDto?> getWordStatus(
    String accountId,
    int wordId,
  ) async {
    final document = await _collection(accountId).doc(wordId.toString()).get();
    if (!document.exists || document.data() == null) return null;
    return EspJpnWordStatusMapper.fromDocument(document);
  }

  Future<RemoteMutationAck> patch(RemoteMutationRequest request) {
    return _remoteMutations.execute(
      target: RemoteMutationTarget.espJpnWordStatus,
      request: request,
    );
  }

  /// Fetches from an inclusive `(updatedAt, documentId)` cursor. Document ID
  /// is the stable tie-breaker for documents with the same update timestamp.
  Future<List<EspJpnWordStatusDto>> fetchPage(
    String accountId,
    SyncCursor? cursor,
  ) async {
    Query<Map<String, dynamic>> query = _collection(accountId)
        .orderBy(EspJpnWordStatusDto.fieldUpdatedAt)
        .orderBy(FieldPath.documentId);
    if (cursor != null) {
      query = query.startAt([
        Timestamp(cursor.seconds, cursor.nanoseconds),
        cursor.documentId,
      ]);
    }
    final snapshot = await query.get();
    return snapshot.docs.map(EspJpnWordStatusMapper.fromDocument).toList();
  }

  CollectionReference<Map<String, dynamic>> _collection(String accountId) =>
      _firestore
          .collection(UserDTO.collectionName)
          .doc(accountId)
          .collection(EspJpnWordStatusDto.collectionName);
}
