import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/core/shared/enums/subscription_status.dart';

class UserDTO {
  static const String collectionName = "Users";
  static const String fieldUserId = "userId";
  static const String fieldEmail = "email";
  static const String fieldUserName = "userName";
  static const String fieldCreatedAt = "createdAt";
  static const String fieldUpdatedAt = "updatedAt";
  static const String fieldSubscriptionStatus = "subscriptionStatus";

  final String userId;//TODO accountID
  //TODO List devices
  final String? email;
  final String? userName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final SubscriptionStatus? subscriptionStatus;

  UserDTO({
    this.subscriptionStatus,
    required this.userId,
    this.email,
    this.userName,
    this.createdAt,
    this.updatedAt,
  });

  /// ----------------------------
  /// Firestore → AppUser に変換
  /// ----------------------------
  factory UserDTO.fromFirebase(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserDTO(
      subscriptionStatus: SubscriptionStatus.values
          .firstWhere((e) => e.subscriptionCode == data['subscriptionStatus']),
      userId: doc.id,
      email: data[fieldEmail] ?? "",
      userName: data[fieldUserName],
      //photoUrl: data['photoUrl'],
      //devices: data['devices'],
      createdAt: (data[fieldCreatedAt] is Timestamp)
          ? (data[fieldCreatedAt] as Timestamp).toDate()
          : null,
      updatedAt: (data[fieldUpdatedAt] is Timestamp)
          ? (data[fieldUpdatedAt] as Timestamp).toDate()
          : null,
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
      //'photoUrl': photoUrl,
      //'deviceId': devices,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
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
      //photoUrl: photoUrl ?? this.photoUrl,
      //devices: deviceId ?? this.devices,
      createdAt: createdAt,
      updatedAt: DateTime.now().toUtc(),
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
    );
  }
}
