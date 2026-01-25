import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/core/shared/consts/firebase.dart';
import 'package:my_dic/features/esp_jpn_word_status/data/wordStatusEntity.dart';
import 'package:my_dic/features/user/data/dto/user_dto.dart';

class FirebaseWordStatusDao {
  final FirebaseFirestore _db;

  FirebaseWordStatusDao(this._db);

  Future<void> updateBatch(
      String userId, List<WordStatusDTO> wordStatusList) async {
    //batch sizeごとにまとめて実行
    final batchSize = FirebaseConsts.batchSize;
    print("======================updateBatch=====================");
    print("userID : ${userId}");
    wordStatusList.map((e) => print("wordId: ${e.wordId}"));

    for (int i = 0; i < wordStatusList.length; i += batchSize) {
      final batch = _db.batch();
      final end = (i + batchSize < wordStatusList.length)
          ? i + batchSize
          : wordStatusList.length;

      for (int j = i; j < end; j++) {
        final wordStatus = wordStatusList[j];
        print("$j Updating wordId: ${wordStatus.wordId}");
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

  // Assume this class has a method to get user profile data from Firestore
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
        //.where(WordStatusDTO.fieldUpdatedAt,isGreaterThan: Timestamp.fromDate(datetime))
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
        .where(WordStatusDTO.fieldUpdatedAt, isGreaterThan: lastSync)
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
        .where(WordStatusDTO.fieldUpdatedAt, isGreaterThan: lastSync)
        .get();

    if (querySnapshot.docs.isEmpty) return [];

    return querySnapshot.docs
        .map((doc) => WordStatusDTO.fromFirebase(doc))
        .toList();
  }
}
