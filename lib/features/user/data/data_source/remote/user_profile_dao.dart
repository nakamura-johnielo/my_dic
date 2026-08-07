import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/core/infrastructure/database/firebase/remote_mutation_transaction.dart';
import 'package:my_dic/features/sync/application/model/remote_mutation.dart';
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
    await ensure(userEntity);
  }

  Future<void> create(UserDTO userEntity) async {
    await ensure(userEntity);
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

      final data = _provisioningData(defaults);
      transaction.set(docRef, data);
      return defaults;
    });
  }

  Map<String, dynamic> _provisioningData(UserDTO defaults) => {
        fieldUserId: defaults.userId,
        if (defaults.email != null && defaults.email!.isNotEmpty)
          fieldEmail: defaults.email,
        if (defaults.userName != null && defaults.userName!.isNotEmpty)
          fieldUserName: defaults.userName,
        fieldSubscriptionStatus: 'free',
        fieldCreatedAt: FieldValue.serverTimestamp(),
        fieldUpdatedAt: FieldValue.serverTimestamp(),
        'clientUpdatedAt': FieldValue.serverTimestamp(),
        'revision': 0,
        'lastMutationId': null,
        'schemaVersion': 1,
      };

  /// Maps the local-first editable profile field key to its Firestore field
  /// name. Only `username` is editable via this path today.
  static const Map<String, String> _editableFieldNames = {
    'username': fieldUserName,
  };

  /// Writes only the fields named in [fieldMask], leaving every other remote
  /// field (including authorization fields) untouched. [isNew] controls
  /// whether `createdAt` is also stamped.
  Future<RemoteMutationAck> patch(RemoteMutationRequest request) {
    final docRef = _db.collection(collectionName).doc(request.accountId);
    return RemoteMutationTransaction.apply(
      firestore: _db,
      reference: docRef,
      request: request,
      identityFields: {fieldUserId: request.accountId},
      encodeField: (field, value) {
        final remoteField = _editableFieldNames[field];
        return remoteField == null ? const {} : {remoteField: value};
      },
    );
  }
}
