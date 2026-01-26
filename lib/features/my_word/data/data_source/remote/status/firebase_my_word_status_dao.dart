import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/core/shared/consts/firebase.dart';
import 'package:my_dic/features/my_word/data/data_source/remote/status/firebase_my_word_status_dto.dart';
import 'package:my_dic/features/user/data/dto/user_dto.dart';

class FirebaseMyWordStatusDao {
  final FirebaseFirestore _db;

  FirebaseMyWordStatusDao(this._db);

  /// Batch update for multiple MyWordStatus
  Future<void> updateBatch(
      String userId, List<MyWordStatusDTO> statusList) async {
    final batchSize = FirebaseConsts.batchSize;

    for (int i = 0; i < statusList.length; i += batchSize) {
      final batch = _db.batch();
      final end = min(i + batchSize, statusList.length);

      for (int j = i; j < end; j++) {
        final status = statusList[j];
        final docRef = _db
            .collection(UserDTO.collectionName)
            .doc(userId)
            .collection(MyWordStatusDTO.collectionName)
            .doc(status.myWordId);
        batch.set(docRef, status.toFirebase(), SetOptions(merge: true));
      }
      await batch.commit();
    }
  }

  /// Get a single MyWordStatus by word ID
  Future<MyWordStatusDTO?> getStatus(String userId, String myWordId) async {
    final doc = await _db
        .collection(UserDTO.collectionName)
        .doc(userId)
        .collection(MyWordStatusDTO.collectionName)
        .doc(myWordId)
        .get();
    if (!doc.exists || doc.data() == null) return null;
    return MyWordStatusDTO.fromFirebase(doc);
  }

  /// Update a single MyWordStatus
  Future<void> update(MyWordStatusDTO status, String userId) async {
    final docRef = _db
        .collection(UserDTO.collectionName)
        .doc(userId)
        .collection(MyWordStatusDTO.collectionName)
        .doc(status.myWordId);
    await docRef.set(status.toFirebase(), SetOptions(merge: true));
  }

  /// Create a new MyWordStatus
  Future<void> create(MyWordStatusDTO status, String userId) async {
    final docRef = _db
        .collection(UserDTO.collectionName)
        .doc(userId)
        .collection(MyWordStatusDTO.collectionName)
        .doc(status.myWordId);
    await docRef.set(status.toFirebase());
  }

  /// Watch all MyWordStatus (real-time)
  Stream<List<MyWordStatusDTO>> watchAll(String userId) {
    return _db
        .collection(UserDTO.collectionName)
        .doc(userId)
        .collection(MyWordStatusDTO.collectionName)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MyWordStatusDTO.fromFirebase(doc))
            .toList())
        .distinct();
  }

  /// Watch changed MyWordStatus IDs (for sync)
    Stream<List<String>> watchChangedStatusIds(String userId) {
    return _db
        .collection(UserDTO.collectionName)
        .doc(userId)
        .collection(MyWordStatusDTO.collectionName)
        .snapshots()
        .skip(1) // Skip initial snapshot
        .map((snapshot) => snapshot.docChanges
            .where((change) =>
                change.type == DocumentChangeType.modified ||
                change.type == DocumentChangeType.added)
            .map((change) =>
          change.doc.data()?[MyWordStatusDTO.fieldMyWordId] as String)
            .toList());
        //.distinct();
  }

  /// Watch MyWordStatus updated after a specific timestamp (stream)
  Stream<List<MyWordStatusDTO>> watchUpdatedAfter(
      String userId, DateTime lastSync) {
    return _db
        .collection(UserDTO.collectionName)
        .doc(userId)
        .collection(MyWordStatusDTO.collectionName)
        .where(MyWordStatusDTO.fieldUpdatedAt, isGreaterThan: lastSync)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MyWordStatusDTO.fromFirebase(doc))
            .toList())
        .distinct();
  }

  /// Get MyWordStatus updated after a specific timestamp (one-time query)
  Future<List<MyWordStatusDTO>> getStatusAfter(
      String userId, DateTime lastSync) async {
    final querySnapshot = await _db
        .collection(UserDTO.collectionName)
        .doc(userId)
        .collection(MyWordStatusDTO.collectionName)
        .where(MyWordStatusDTO.fieldUpdatedAt,
            isGreaterThan: Timestamp.fromDate(lastSync))
        .get();

    if (querySnapshot.docs.isEmpty) return [];

    return querySnapshot.docs
        .map((doc) => MyWordStatusDTO.fromFirebase(doc))
        .toList();
  }

  /// Delete a MyWordStatus
  Future<void> delete(String userId, String myWordId) async {
    final docRef = _db
        .collection(UserDTO.collectionName)
        .doc(userId)
        .collection(MyWordStatusDTO.collectionName)
        .doc(myWordId);
    await docRef.delete();
  }
}
