import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/_Framework_Driver/remote/firebase/Entity/userEntity.dart';

class UserDao {
  final FirebaseFirestore _db;

  UserDao(this._db);
  // Assume this class has a method to get user profile data from Firestore
  Future<UserEntity?> getUser(String uid) async {
    final doc = await _db.collection(UserEntity.collectionName).doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserEntity.fromFirebase(doc);
  }

  Future<void> update(UserEntity userEntity) async {
    final docRef =
        _db.collection(UserEntity.collectionName).doc(userEntity.userId);
    await docRef.set(userEntity.toFirebase(), SetOptions(merge: true));
  }

  Future<void> create(UserEntity userEntity) async {
    final docRef =
        _db.collection(UserEntity.collectionName).doc(userEntity.userId);
    await docRef.set(userEntity.toFirebase());
  }
}
