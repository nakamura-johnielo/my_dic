import 'package:my_dic/core/shared/consts/dates.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/esp_word_status.dart';

class WordStatusDTO {
  static const String collectionName = "WordStatus";

  static const String fieldwordId = "wordId";
  static const String fieldIsLearned = "isLearned";
  static const String fieldIsBookmarked = "isBookmarked";
  static const String fieldHasNote = "hasNote";
  static const String fieldupdateBy = "updateBy";
  static const String fieldCreatedAt = "createdAt";
  static const String fieldUpdatedAt = "updatedAt";
  static const String fieldRevision = "revision";
  static const String fieldLastMutationId = "lastMutationId";
  static const String fieldClientUpdatedAt = "clientUpdatedAt";

  //!TODO finalにすべき？copywith?

  final int wordId;
  int isLearned;
  int isBookmarked;
  int hasNote;
  String? updateBy;
  DateTime createdAt;
  DateTime updatedAt;
  int remoteRevision;
  String? lastMutationId;
  DateTime? clientUpdatedAt;

  WordStatusDTO({
    required this.wordId,
    required this.isLearned,
    required this.isBookmarked,
    required this.hasNote,
    this.updateBy,
    required this.createdAt,
    required this.updatedAt,
    this.remoteRevision = 0,
    this.lastMutationId,
    this.clientUpdatedAt,
  });

  /// ----------------------------
  /// Firestore → AppUser に変換
  /// ----------------------------
  WordStatus toEntity() {
    return WordStatus(
      wordId: wordId,
      isLearned: isLearned == 1 ? true : false,
      isBookmarked: isBookmarked == 1 ? true : false,
      hasNote: hasNote == 1 ? true : false,
      editAt: updatedAt,
    );
  }

  /// ----------------------------
  /// AppUser → Firestore へ保存
  /// ----------------------------
  factory WordStatusDTO.fromAppEntity(WordStatus data) {
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
