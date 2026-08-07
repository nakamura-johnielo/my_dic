import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/core/shared/consts/firebase.dart';
import 'package:my_dic/core/infrastructure/database/firebase/remote_mutation_transaction.dart';
import 'package:my_dic/features/esp_jpn_word_status/data/word_status_entity.dart';
import 'package:my_dic/features/sync/application/model/remote_mutation.dart';
import 'package:my_dic/features/user/data/dto/user_dto.dart';
import 'package:my_dic/core/shared/utils/logger.dart';

class FirebaseWordStatusDao {
  final FirebaseFirestore _db;

  FirebaseWordStatusDao(this._db);

  Future<void> updateBatch(
      String userId, List<WordStatusDTO> wordStatusList) async {
    //batch sizeごとにまとめて実行
    final batchSize = FirebaseConsts.batchSize;
    AppLogger.print("======================updateBatch=====================");
    wordStatusList.map((e) => AppLogger.print("wordId: ${e.wordId}"));

    for (int i = 0; i < wordStatusList.length; i += batchSize) {
      final batch = _db.batch();
      final end = (i + batchSize < wordStatusList.length)
          ? i + batchSize
          : wordStatusList.length;

      for (int j = i; j < end; j++) {
        final wordStatus = wordStatusList[j];
        AppLogger.print("$j Updating wordId: ${wordStatus.wordId}");
        //final batch = _db.batch();
        final docRef = _db
            .collection(UserDTO.collectionName)
            .doc(userId)
            .collection(WordStatusDTO.collectionName)
            .doc(wordStatus.wordId.toString());
        batch.set(docRef, wordStatus.toFirebase(), SetOptions(merge: true));
      }
      await batch.commit();
    }
  }

  Future<WordStatusDTO?> getWordStatus(String userId, int wordId) async {
    final doc = await _db
        .collection(UserDTO.collectionName)
        .doc(userId)
        .collection(WordStatusDTO.collectionName)
        .doc(wordId.toString())
        .get();
    if (!doc.exists || doc.data() == null) return null;
    return WordStatusDTO.fromFirebase(doc);
  }

  Future<void> update(WordStatusDTO wordStatusEntity, String userId) async {
    final docRef = _db
        .collection(UserDTO.collectionName)
        .doc(userId)
        .collection(WordStatusDTO.collectionName)
        .doc(wordStatusEntity.wordId.toString());
    await docRef.set(wordStatusEntity.toFirebase(), SetOptions(merge: true));
  }

  Future<void> create(WordStatusDTO wordStatusEntity) async {
    final docRef = _db
        .collection(WordStatusDTO.collectionName)
        .doc(wordStatusEntity.wordId.toString());
    await docRef.set(wordStatusEntity.toFirebase());
  }

  /// Merge-writes only [fieldMask] keys plus bookkeeping timestamps, so that
  /// fields not covered by the sync outbox mutation are left untouched.
  Future<RemoteMutationAck> patch(RemoteMutationRequest request) {
    final docRef = _db
        .collection(UserDTO.collectionName)
        .doc(request.accountId)
        .collection(WordStatusDTO.collectionName)
        .doc(request.entityId);
    return RemoteMutationTransaction.apply(
      firestore: _db,
      reference: docRef,
      request: request,
      identityFields: {WordStatusDTO.fieldwordId: int.parse(request.entityId)},
      encodeField: (field, value) => {
        field: value is bool ? (value ? 1 : 0) : value,
      },
    );
  }

  /// FirestoreのWordStatusコレクションを監視
  Stream<List<WordStatusDTO>> watchAll(String userId) {
    return _db
        .collection(UserDTO.collectionName)
        .doc(userId)
        .collection(WordStatusDTO.collectionName)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WordStatusDTO.fromFirebase(doc))
            .toList())
        .distinct();
  }

  /// リアルタイムで更新を監視し、変更されたドキュメントのIDのみを返す
  Stream<List<int>> watchChangedWordIds(String userId) {
    return _db
        .collection(UserDTO.collectionName)
        .doc(userId)
        .collection(WordStatusDTO.collectionName)
        .snapshots()
        .skip(1)
        .map((snapshot) => snapshot.docChanges
            .where((change) =>
                change.type == DocumentChangeType.modified ||
                change.type == DocumentChangeType.added)
            .map((change) =>
                change.doc.data()?[WordStatusDTO.fieldwordId] as int)
            .toList());
  }

  Stream<List<WordStatusDTO>> watchUpdatedAfter(
      String userId, DateTime lastSync) {
    return _db
        .collection(UserDTO.collectionName)
        .doc(userId)
        .collection(WordStatusDTO.collectionName)
        .where(WordStatusDTO.fieldUpdatedAt, isGreaterThanOrEqualTo: lastSync)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WordStatusDTO.fromFirebase(doc))
            .toList())
        .distinct();
  }

  Future<List<WordStatusDTO>> getWordStatusAfter(
      String userId, DateTime lastSync) async {
    final querySnapshot = await _db
        .collection(UserDTO.collectionName)
        .doc(userId)
        .collection(WordStatusDTO.collectionName)
        .where(WordStatusDTO.fieldUpdatedAt, isGreaterThanOrEqualTo: lastSync)
        .get();

    if (querySnapshot.docs.isEmpty) return [];

    return querySnapshot.docs
        .map((doc) => WordStatusDTO.fromFirebase(doc))
        .toList();
  }
}
