import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/core/shared/consts/firebase.dart';
import 'package:my_dic/features/my_word/data/data_source/remote/myword/firebase_my_word_dto.dart';
import 'package:my_dic/features/user/data/dto/user_dto.dart';

class FirebaseMyWordDao {
  final FirebaseFirestore _db;

  FirebaseMyWordDao(this._db);

  /// Batch update for multiple MyWords
  Future<void> updateBatch(String userId, List<MyWordDTO> myWordList) async {
    final batchSize = FirebaseConsts.batchSize;

    for (int i = 0; i < myWordList.length; i += batchSize) {
      final batch = _db.batch();
      final end = min(i + batchSize, myWordList.length);

      for (int j = i; j < end; j++) {
        final myWord = myWordList[j];
        final docRef = _db
            .collection(UserDTO.collectionName)
            .doc(userId)
            .collection(MyWordDTO.collectionName)
            .doc(myWord.myWordId);
        batch.set(docRef, myWord.toFirebase(), SetOptions(merge: true));
      }
      await batch.commit();
    }
  }

  /// Get a single MyWord by ID
  Future<MyWordDTO?> getMyWord(String userId, String myWordId) async {
    final doc = await _db
        .collection(UserDTO.collectionName)
        .doc(userId)
        .collection(MyWordDTO.collectionName)
        .doc(myWordId)
        .get();
    if (!doc.exists || doc.data() == null) return null;
    return MyWordDTO.fromFirebase(doc);
  }

  /// Update a single MyWord
  Future<void> update(MyWordDTO myWord, String userId) async {
    final docRef = _db
        .collection(UserDTO.collectionName)
        .doc(userId)
        .collection(MyWordDTO.collectionName)
        .doc(myWord.myWordId);
    await docRef.set(myWord.toFirebase(), SetOptions(merge: true));
  }

  /// Create a new MyWord
  Future<void> create(MyWordDTO myWord, String userId) async {
    final docRef = _db
        .collection(UserDTO.collectionName)
        .doc(userId)
        .collection(MyWordDTO.collectionName)
        .doc(myWord.myWordId);
    await docRef.set(myWord.toFirebase());
  }

  /// Watch all MyWords (real-time)
  Stream<List<MyWordDTO>> watchAll(String userId) {
    return _db
        .collection(UserDTO.collectionName)
        .doc(userId)
        .collection(MyWordDTO.collectionName)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MyWordDTO.fromFirebase(doc)).toList())
        .distinct();
  }

  /// Watch changed MyWord IDs (for sync)
    Stream<List<String>> watchChangedWordIds(String userId) {
    return _db
        .collection(UserDTO.collectionName)
        .doc(userId)
        .collection(MyWordDTO.collectionName)
        .snapshots()
        .skip(1) // Skip initial snapshot to avoid full sync on subscription
        .map((snapshot) => snapshot.docChanges
            .where((change) =>
                change.type == DocumentChangeType.modified ||
                change.type == DocumentChangeType.added)
        .map((change) =>
          change.doc.data()?[MyWordDTO.fieldMyWordId] as String)
            .toList());
  }

  /// Watch MyWords updated after a specific timestamp (stream)
  Stream<List<MyWordDTO>> watchUpdatedAfter(String userId, DateTime lastSync) {
    return _db
        .collection(UserDTO.collectionName)
        .doc(userId)
        .collection(MyWordDTO.collectionName)
        .where(MyWordDTO.fieldUpdatedAt, isGreaterThan: lastSync)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MyWordDTO.fromFirebase(doc)).toList())
        .distinct();
  }

  /// Get MyWords updated after a specific timestamp (one-time query)
  Future<List<MyWordDTO>> getMyWordsAfter(
      String userId, DateTime lastSync) async {
    final querySnapshot = await _db
        .collection(UserDTO.collectionName)
        .doc(userId)
        .collection(MyWordDTO.collectionName)
        .where(MyWordDTO.fieldUpdatedAt,
            isGreaterThan: Timestamp.fromDate(lastSync))
        .get();

    if (querySnapshot.docs.isEmpty) return [];

    return querySnapshot.docs
        .map((doc) => MyWordDTO.fromFirebase(doc))
        .toList();
  }

  /// Delete a MyWord (soft delete - set isDeleted flag if implemented, or hard delete)
  Future<void> delete(String userId, String myWordId) async {
    final docRef = _db
        .collection(UserDTO.collectionName)
        .doc(userId)
        .collection(MyWordDTO.collectionName)
        .doc(myWordId);
    await docRef.delete();
  }
}
