import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/features/user/data/dto/user_dto.dart';

class UserDao {
  final FirebaseFirestore _db;

  UserDao(this._db);

  static const String collectionName = "Users";
  static const String fieldUserId = "userId";
  static const String fieldEmail = "email";
  static const String fieldUserName = "userName";
  static const String fieldCreatedAt = "createdAt";
  static const String fieldUpdatedAt = "updatedAt";
  static const String fieldSubscriptionStatus = "subscriptionStatus";

  // Assume this class has a method to get user profile data from Firestore
  Future<UserDTO?> getUser(String uid) async {
    final doc = await _db.collection(collectionName).doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserDTO.fromFirebase(doc);
  }

  Future<void> update(UserDTO userEntity) async {
    final docRef = _db.collection(collectionName).doc(userEntity.userId);
    await docRef.set(userEntity.toFirebase(), SetOptions(merge: true));
  }

  Future<void> create(UserDTO userEntity) async {
    final docRef = _db.collection(collectionName).doc(userEntity.userId);
    await docRef.set(userEntity.toFirebase());
  }

  /// UID 固定のdocumentを冪等にprovisioningする。
  ///
  /// 既存documentの編集可能fieldや認可fieldを上書きしない。
  Future<UserDTO> ensure(UserDTO defaults) async {
    final docRef = _db.collection(collectionName).doc(defaults.userId);

    return _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (snapshot.exists && snapshot.data() != null) {
        return UserDTO.fromFirebase(snapshot);
      }

      final data = <String, dynamic>{
        fieldUserId: defaults.userId,
        fieldCreatedAt: FieldValue.serverTimestamp(),
      };
      if (defaults.email != null && defaults.email!.isNotEmpty) {
        data[fieldEmail] = defaults.email;
      }
      transaction.set(docRef, data);
      return defaults;
    });
  }
}
