import 'package:my_dic/core/shared/consts/dates.dart';
import 'package:my_dic/features/my_word/internal/domain/entity/my_word.dart';

class MyWordDTO {
  static const String collectionName = "MyWords";

  static const String fieldMyWordId = "wordId";
  static const String fieldMyWord = "word";
  static const String fieldContents = "contents";
  static const String fieldupdateBy = "updateBy";
  static const String fieldCreatedAt = "createdAt";
  static const String fieldUpdatedAt = "updatedAt";
  static const String fieldDeletedAt = "deletedAt";
  static const String fieldRevision = "revision";
  static const String fieldLastMutationId = "lastMutationId";
  static const String fieldClientUpdatedAt = "clientUpdatedAt";

  //!TODO finalにすべき？copywith?

  final String myWordId;
  String word;
  String contents;
  String? updateBy;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;
  int remoteRevision;
  String? lastMutationId;
  DateTime? clientUpdatedAt;

  MyWordDTO({
    required this.myWordId,
    required this.word,
    required this.contents,
    this.updateBy,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.remoteRevision = 0,
    this.lastMutationId,
    this.clientUpdatedAt,
  });

  MyWord toEntity() {
    return MyWord(
      wordId: myWordId,
      word: word,
      contents: contents,
      editAt: updatedAt,
    );
  }

  factory MyWordDTO.fromAppEntity(MyWord data, {DateTime? dateTime}) {
    return MyWordDTO(
        myWordId: data.wordId,
        word: data.word,
        contents: data.contents,
        updateBy: "data.updateBy",
        createdAt: dateTime ?? MyDateTime.sentinel,
        updatedAt: data.editAt);
  }

  /// ----------------------------
  /// コピー・更新用
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
