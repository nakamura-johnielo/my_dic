import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/core/shared/consts/firebase.dart';
import 'package:my_dic/core/infrastructure/database/firebase/remote_mutation_transaction.dart';
import 'package:my_dic/features/jpn_esp_word_status/data/jpn_esp_word_status_entity.dart';
import 'package:my_dic/features/sync/application/model/remote_mutation.dart';
import 'package:my_dic/features/user/data/dto/user_dto.dart';
import 'package:my_dic/core/shared/utils/logger.dart';

class FirebaseJpnEspWordStatusDao {
  final FirebaseFirestore _db;

  FirebaseJpnEspWordStatusDao(this._db);

  Future<void> updateBatch(
      String userId, List<JpnEspWordStatusDTO> wordStatusList) async {
    final batchSize = FirebaseConsts.batchSize;
    AppLogger.print(
        "======================updateBatch JpnEsp=====================");
    wordStatusList.map((e) => AppLogger.print("wordId: ${e.wordId}"));

    for (int i = 0; i < wordStatusList.length; i += batchSize) {
      final batch = _db.batch();
      final end = (i + batchSize < wordStatusList.length)
          ? i + batchSize
          : wordStatusList.length;

      for (int j = i; j < end; j++) {
        final wordStatus = wordStatusList[j];
        AppLogger.print("$j Updating wordId: ${wordStatus.wordId}");
        final docRef = _db
            .collection(UserDTO.collectionName)
            .doc(userId)
            .collection(JpnEspWordStatusDTO.collectionName)
            .doc(wordStatus.wordId.toString());
        batch.set(docRef, wordStatus.toMap(), SetOptions(merge: true));
      }
      await batch.commit();
    }
  }

  Future<JpnEspWordStatusDTO?> getWordStatus(String userId, int wordId) async {
    final doc = await _db
        .collection(UserDTO.collectionName)
        .doc(userId)
        .collection(JpnEspWordStatusDTO.collectionName)
        .doc(wordId.toString())
        .get();
    if (!doc.exists || doc.data() == null) return null;
    return JpnEspWordStatusDTO.fromFirebase(doc);
  }

  Future<void> update(
      JpnEspWordStatusDTO wordStatusEntity, String userId) async {
    final docRef = _db
        .collection(UserDTO.collectionName)
        .doc(userId)
        .collection(JpnEspWordStatusDTO.collectionName)
        .doc(wordStatusEntity.wordId.toString());
    await docRef.set(wordStatusEntity.toMap(), SetOptions(merge: true));
  }

  Future<void> create(JpnEspWordStatusDTO wordStatusEntity) async {
    final docRef = _db
        .collection(JpnEspWordStatusDTO.collectionName)
        .doc(wordStatusEntity.wordId.toString());
    await docRef.set(wordStatusEntity.toMap());
  }

  /// Merge-writes only [fieldMask] keys plus bookkeeping timestamps, so that
  /// fields not covered by the sync outbox mutation are left untouched.
  Future<RemoteMutationAck> patch(RemoteMutationRequest request) {
    final docRef = _db
        .collection(UserDTO.collectionName)
        .doc(request.accountId)
        .collection(JpnEspWordStatusDTO.collectionName)
        .doc(request.entityId);
    return RemoteMutationTransaction.apply(
      firestore: _db,
      reference: docRef,
      request: request,
      identityFields: {
        JpnEspWordStatusDTO.fieldwordId: int.parse(request.entityId)
      },
      encodeField: (field, value) => {
        field: value is bool ? (value ? 1 : 0) : value,
      },
    );
  }

  Stream<List<JpnEspWordStatusDTO>> watchAll(String userId) {
    return _db
        .collection(UserDTO.collectionName)
        .doc(userId)
        .collection(JpnEspWordStatusDTO.collectionName)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => JpnEspWordStatusDTO.fromFirebase(doc))
            .toList())
        .distinct();
  }

  Stream<List<int>> watchChangedWordIds(String userId) {
    return _db
        .collection(UserDTO.collectionName)
        .doc(userId)
        .collection(JpnEspWordStatusDTO.collectionName)
        .snapshots()
        .skip(1)
        .map((snapshot) => snapshot.docChanges
            .where((change) =>
                change.type == DocumentChangeType.modified ||
                change.type == DocumentChangeType.added)
            .map((change) =>
                change.doc.data()?[JpnEspWordStatusDTO.fieldwordId] as int)
            .toList());
  }

  Stream<List<JpnEspWordStatusDTO>> watchUpdatedAfter(
      String userId, DateTime lastSync) {
    return _db
        .collection(UserDTO.collectionName)
        .doc(userId)
        .collection(JpnEspWordStatusDTO.collectionName)
        .where(JpnEspWordStatusDTO.fieldUpdatedAt, isGreaterThan: lastSync)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => JpnEspWordStatusDTO.fromFirebase(doc))
            .toList());
  }

  Future<List<JpnEspWordStatusDTO>> getWordStatusAfter(
      String userId, DateTime lastSync) async {
    final snapshot = await _db
        .collection(UserDTO.collectionName)
        .doc(userId)
        .collection(JpnEspWordStatusDTO.collectionName)
        .where(JpnEspWordStatusDTO.fieldUpdatedAt, isGreaterThan: lastSync)
        .get();

    return snapshot.docs
        .map((doc) => JpnEspWordStatusDTO.fromFirebase(doc))
        .toList();
  }
}
