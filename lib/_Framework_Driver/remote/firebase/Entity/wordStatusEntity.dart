import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/Constants/Enums/subscribe_status.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/user/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WordStatusEntity {
  static const String collectionName = "WordStatus";

  static const String fieldwordId = "wordId";
  static const String fieldIsLearned = "isLearned";
  static const String fieldIsBookmarked = "isBookmarked";
  static const String fieldHasNote = "hasNote";
  static const String fieldupdateBy = "updateBy";
  static const String fieldCreatedAt = "createdAt";
  static const String fieldUpdatedAt = "updatedAt";

  final int wordId;
  final int isLearned;
  final int isBookmarked;
  final int hasNote;
  final String? updateBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  WordStatusEntity({
    required this.wordId,
    required this.isLearned,
    required this.isBookmarked,
    required this.hasNote,
    this.updateBy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// ----------------------------
  /// Firestore → AppUser に変換
  /// ----------------------------
  factory WordStatusEntity.fromFirebase(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return WordStatusEntity(
        wordId: data[fieldwordId],
        isLearned: data[fieldIsLearned],
        isBookmarked: data[fieldIsBookmarked],
        hasNote: data[fieldHasNote],
        updateBy: data[fieldupdateBy],
        createdAt: (data[fieldCreatedAt] as Timestamp).toDate().toUtc(),
        updatedAt: (data[fieldUpdatedAt] as Timestamp).toDate().toUtc());
  }

  /// ----------------------------
  /// AppUser → Firestore へ保存
  /// ----------------------------
  Map<String, dynamic> toFirebase() {
    return {
      fieldwordId: wordId,
      fieldIsLearned: isLearned,
      fieldIsBookmarked: isBookmarked,
      fieldHasNote: hasNote,
      fieldupdateBy: updateBy,
      fieldCreatedAt: Timestamp.fromDate(createdAt.toUtc()),
      fieldUpdatedAt: Timestamp.fromDate(updatedAt.toUtc()),
    };
  }

  /// ----------------------------
  /// コピー（更新用）
  /// ----------------------------
  // WordStatusEntity copyWith({
  //   String? userName,
  //   String? email,
  //   SubscriptionStatus? subscriptionStatus,
  // }) {
  //   return WordStatusEntity(
  //     userId: userId,
  //     email: email ?? this.email,
  //     userName: userName ?? this.userName,
  //     //photoUrl: photoUrl ?? this.photoUrl,
  //     //devices: deviceId ?? this.devices,
  //     createdAt: createdAt,
  //     updatedAt: DateTime.now().toUtc(),
  //     subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
  //   );
  // }
}
