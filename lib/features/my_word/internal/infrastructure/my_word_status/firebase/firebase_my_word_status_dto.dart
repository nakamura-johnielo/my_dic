import 'package:my_dic/core/shared/consts/dates.dart';
import 'package:my_dic/features/my_word/internal/domain/entity/my_word_status.dart';

class MyWordStatusDTO {
  static const String collectionName = "MyWordStatus";

  static const String fieldMyWordId = "myWordId";
  static const String fieldIsLearned = "isLearned";
  static const String fieldIsBookmarked = "isBookmarked";
  static const String fieldUpdateBy = "updateBy";
  static const String fieldCreatedAt = "createdAt";
  static const String fieldUpdatedAt = "updatedAt";
  static const String fieldRevision = "revision";
  static const String fieldLastMutationId = "lastMutationId";
  static const String fieldClientUpdatedAt = "clientUpdatedAt";

  final String myWordId;
  int isLearned;
  int isBookmarked;
  String? updateBy;
  DateTime createdAt;
  DateTime updatedAt;
  int remoteRevision;
  String? lastMutationId;
  DateTime? clientUpdatedAt;

  MyWordStatusDTO({
    required this.myWordId,
    required this.isLearned,
    required this.isBookmarked,
    this.updateBy,
    required this.createdAt,
    required this.updatedAt,
    this.remoteRevision = 0,
    this.lastMutationId,
    this.clientUpdatedAt,
  });

  /// MyWordStatus entity ↁEMyWordStatusDTO
  factory MyWordStatusDTO.fromAppEntity(MyWordStatus data) {
    return MyWordStatusDTO(
      myWordId: data.wordId,
      isLearned: data.isLearned ? 1 : 0,
      isBookmarked: data.isBookmarked ? 1 : 0,
      updateBy: null,
      createdAt: MyDateTime.sentinel,
      updatedAt: data.editAt,
    );
  }
}
