import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/features/sync/port/model/remote_mutation.dart';
import 'package:my_dic/features/sync/port/remote_mutation_executor.dart';
import 'package:my_dic/features/user_profile/port/user_dto.dart';

class UserDao {
  final FirebaseFirestore _db;
  final RemoteMutationExecutor _remoteMutations;

  UserDao(this._db, this._remoteMutations);

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
    return _fromDocument(doc);
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
    final result = await _remoteMutations.provisionUserProfile(
      RemoteUserProfileProvisioningRequest(
        accountId: defaults.userId,
        email: defaults.email,
        userName: defaults.userName,
      ),
    );
    if (!result.alreadyExisted) return defaults;
    return UserDTO.fromRemoteData(
      userId: defaults.userId,
      data: Map<String, dynamic>.from(result.fields),
    );
  }

  /// Writes only the fields named in [fieldMask], leaving every other remote
  /// field (including authorization fields) untouched. [isNew] controls
  /// whether `createdAt` is also stamped.
  Future<RemoteMutationAck> patch(RemoteMutationRequest request) {
    return _remoteMutations.execute(
      target: RemoteMutationTarget.userProfile,
      request: request,
    );
  }

  UserDTO _fromDocument(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return UserDTO.fromRemoteData(
      userId: document.id,
      data: {
        ...data,
        fieldCreatedAt: _dateOf(data[fieldCreatedAt]),
        fieldUpdatedAt: _dateOf(data[fieldUpdatedAt]),
        UserDTO.fieldClientUpdatedAt:
            _dateOf(data[UserDTO.fieldClientUpdatedAt]),
      },
    );
  }

  DateTime? _dateOf(Object? value) {
    if (value is Timestamp) return value.toDate().toUtc();
    if (value is DateTime) return value.toUtc();
    return null;
  }
}
