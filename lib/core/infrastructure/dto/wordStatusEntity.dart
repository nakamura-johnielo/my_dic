import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/core/common/consts/dates.dart';
import 'package:my_dic/core/domain/entity/word/esp_word_status.dart';

class WordStatusDTO {
  static const String collectionName = "WordStatus";

  static const String fieldwordId = "wordId";
  static const String fieldIsLearned = "isLearned";
  static const String fieldIsBookmarked = "isBookmarked";
  static const String fieldHasNote = "hasNote";
  static const String fieldupdateBy = "updateBy";
  static const String fieldCreatedAt = "createdAt";
  static const String fieldUpdatedAt = "updatedAt";

  //!TODO finalにすべき？copywith?

  final int wordId;
  int isLearned;
  int isBookmarked;
  int hasNote;
  String? updateBy;
  DateTime createdAt;
  DateTime updatedAt;

  WordStatusDTO({
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
  factory WordStatusDTO.fromFirebase(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return WordStatusDTO(
        wordId: data[fieldwordId],
        isLearned: data[fieldIsLearned],
        isBookmarked: data[fieldIsBookmarked],
        hasNote: data[fieldHasNote],
        updateBy: data[fieldupdateBy],
        createdAt: (data[fieldCreatedAt] as Timestamp).toDate().toUtc(),
        updatedAt: (data[fieldUpdatedAt] as Timestamp).toDate().toUtc());
  }

  WordStatus toEntity(){
    return WordStatus(
      wordId: wordId,
      isLearned: isLearned == 1 ? true : false,
      isBookmarked: isBookmarked == 1 ? true : false,
      hasNote: hasNote == 1 ? true : false, 
      editAt: updatedAt,
      //editAt: updatedAt,
    );
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

  factory WordStatusDTO.fromAppEntity(WordStatus data) {
    //final data = doc.data()!;
    return WordStatusDTO(
        wordId: data.wordId,
        isLearned: data.isLearned ? 1 : 0,
        isBookmarked: data.isBookmarked ? 1 : 0,
        hasNote: data.hasNote ? 1 : 0,
        updateBy: "data.updateBy",
        createdAt: MyDateTime.sentinel,
        updatedAt: data.editAt);
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
