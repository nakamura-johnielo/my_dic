import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/features/user/data/dto/user_dto.dart';
import 'package:my_dic/_Framework_Driver/remote/firebase/Entity/wordStatusEntity.dart';

class FirebaseWordStatusDao {
  final FirebaseFirestore _db;

  FirebaseWordStatusDao(this._db);
  // Assume this class has a method to get user profile data from Firestore
  Future<WordStatusEntity?> getWordStatus(int wordId) async {
    final doc = await _db
        .collection(WordStatusEntity.collectionName)
        .doc(wordId.toString())
        .get();
    if (!doc.exists || doc.data() == null) return null;
    return WordStatusEntity.fromFirebase(doc);
  }

  Future<void> update(WordStatusEntity wordStatusEntity, String userId) async {
    final docRef = _db
        .collection(UserDTO.collectionName)
        .doc(userId)
        .collection(WordStatusEntity.collectionName)
        .doc(wordStatusEntity.wordId.toString());
    await docRef.set(wordStatusEntity.toFirebase(), SetOptions(merge: true));
  }

  Future<void> create(WordStatusEntity wordStatusEntity) async {
    final docRef = _db
        .collection(WordStatusEntity.collectionName)
        .doc(wordStatusEntity.wordId.toString());
    await docRef.set(wordStatusEntity.toFirebase());
  }

  /// FirestoreのWordStatusコレクションを監視
  Stream<List<WordStatusEntity>> watchAll(String userId) {
    return _db
        .collection(UserDTO.collectionName)
        .doc(userId)
        .collection(WordStatusEntity.collectionName)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WordStatusEntity.fromFirebase(doc))
            .toList());
  }

  Stream<List<WordStatusEntity>> watchUpdatedAfter(
      String userId, DateTime lastSync) {
    return _db
        .collection(UserDTO.collectionName)
        .doc(userId)
        .collection(WordStatusEntity.collectionName)
        .where(WordStatusEntity.fieldUpdatedAt, isGreaterThan: lastSync)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WordStatusEntity.fromFirebase(doc))
            .toList());
  }
}
