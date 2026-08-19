import 'package:my_dic/core/shared/enums/auth/subscription_status.dart';

/// UserProfile 所有の Firestore 通信表現です。
final class UserProfileRemoteDto {
  static const fieldEmail = 'email';
  static const fieldUserName = 'userName';
  static const fieldCreatedAt = 'createdAt';
  static const fieldUpdatedAt = 'updatedAt';
  static const fieldSubscriptionStatus = 'subscriptionStatus';
  static const fieldRevision = 'revision';
  static const fieldLastMutationId = 'lastMutationId';
  static const fieldClientUpdatedAt = 'clientUpdatedAt';

  UserProfileRemoteDto({
    required this.userId,
    this.email,
    this.userName,
    this.createdAt,
    this.updatedAt,
    this.subscriptionStatus,
    this.remoteRevision = 0,
    this.lastMutationId,
    this.clientUpdatedAt,
  });

  final String userId;
  final String? email;
  final String? userName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final SubscriptionStatus? subscriptionStatus;
  final int remoteRevision;
  final String? lastMutationId;
  final DateTime? clientUpdatedAt;

  factory UserProfileRemoteDto.fromRemoteData({
    required String userId,
    required Map<String, dynamic> data,
  }) {
    return UserProfileRemoteDto(
      subscriptionStatus: SubscriptionStatus.values.firstWhere(
        (value) =>
            value.subscriptionCode == data[fieldSubscriptionStatus],
        orElse: () => SubscriptionStatus.free,
      ),
      userId: userId,
      email: data[fieldEmail] ?? '',
      userName: data[fieldUserName],
      createdAt: data[fieldCreatedAt] as DateTime?,
      updatedAt: data[fieldUpdatedAt] as DateTime?,
      remoteRevision: data[fieldRevision] as int? ?? 0,
      lastMutationId: data[fieldLastMutationId] as String?,
      clientUpdatedAt: data[fieldClientUpdatedAt] as DateTime?,
    );
  }

  Map<String, dynamic> toFirebase() => {
        fieldEmail: email,
        fieldUserName: userName,
        fieldSubscriptionStatus: subscriptionStatus?.subscriptionCode,
        fieldCreatedAt: createdAt,
        fieldUpdatedAt: updatedAt,
        fieldRevision: remoteRevision,
        fieldLastMutationId: lastMutationId,
        if (clientUpdatedAt != null) fieldClientUpdatedAt: clientUpdatedAt,
      };

  UserProfileRemoteDto copyWith({
    String? userName,
    String? email,
    SubscriptionStatus? subscriptionStatus,
  }) =>
      UserProfileRemoteDto(
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
