import 'package:my_dic/core/shared/enums/auth/subscription_status.dart';

class UserDTO {
  static const String collectionName = "Users";
  static const String fieldUserId = "userId";
  static const String fieldEmail = "email";
  static const String fieldUserName = "userName";
  static const String fieldCreatedAt = "createdAt";
  static const String fieldUpdatedAt = "updatedAt";
  static const String fieldSubscriptionStatus = "subscriptionStatus";
  static const String fieldRevision = "revision";
  static const String fieldLastMutationId = "lastMutationId";
  static const String fieldClientUpdatedAt = "clientUpdatedAt";

  final String userId; //TODO accountID
  //TODO List devices
  final String? email;
  final String? userName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final SubscriptionStatus? subscriptionStatus;
  final int remoteRevision;
  final String? lastMutationId;
  final DateTime? clientUpdatedAt;

  UserDTO({
    this.subscriptionStatus,
    required this.userId,
    this.email,
    this.userName,
    this.createdAt,
    this.updatedAt,
    this.remoteRevision = 0,
    this.lastMutationId,
    this.clientUpdatedAt,
  });

  /// ----------------------------
  /// Firestore → AppUser に変換
  /// ----------------------------
  factory UserDTO.fromRemoteData({
    required String userId,
    required Map<String, dynamic> data,
  }) {
    return UserDTO(
      subscriptionStatus: SubscriptionStatus.values.firstWhere(
        (e) => e.subscriptionCode == data[fieldSubscriptionStatus],
        orElse: () => SubscriptionStatus.free,
      ),
      userId: userId,
      email: data[fieldEmail] ?? "",
      userName: data[fieldUserName],
      createdAt: data[fieldCreatedAt] as DateTime?,
      updatedAt: data[fieldUpdatedAt] as DateTime?,
      remoteRevision: data[fieldRevision] as int? ?? 0,
      lastMutationId: data[fieldLastMutationId] as String?,
      clientUpdatedAt: data[fieldClientUpdatedAt] as DateTime?,
    );
  }

  /// ----------------------------
  /// AppUser → Firestore へ保存
  /// ----------------------------
  Map<String, dynamic> toFirebase() {
    return {
      'email': email,
      'userName': userName,
      'subscriptionStatus': subscriptionStatus?.subscriptionCode,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      fieldRevision: remoteRevision,
      fieldLastMutationId: lastMutationId,
      if (clientUpdatedAt != null) fieldClientUpdatedAt: clientUpdatedAt,
    };
  }

  /// ----------------------------
  /// コピー（更新用）
  /// ----------------------------
  UserDTO copyWith({
    String? userName,
    String? email,
    SubscriptionStatus? subscriptionStatus,
  }) {
    return UserDTO(
      userId: userId,
      email: email ?? this.email,
      userName: userName ?? this.userName,
      createdAt: createdAt,
      updatedAt: DateTime.now().toUtc(),
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      remoteRevision: remoteRevision,
      lastMutationId: lastMutationId,
      clientUpdatedAt: clientUpdatedAt,
    );
  }

  @override
  String toString() {
    return 'UserDTO{userId: $userId, email: $email, userName: $userName, createdAt: $createdAt, updatedAt: $updatedAt, subscriptionStatus: $subscriptionStatus}';
  }
}
