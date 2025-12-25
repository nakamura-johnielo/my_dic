import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/features/user/data/dto/user_dto.dart';
import 'package:my_dic/core/infrastructure/dto/wordStatusEntity.dart';

class FirebaseWordStatusDao {
  final FirebaseFirestore _db;

  FirebaseWordStatusDao(this._db);
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
            .toList());
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
            .toList());
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
