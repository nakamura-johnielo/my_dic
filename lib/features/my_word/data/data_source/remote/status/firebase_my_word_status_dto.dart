import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/core/shared/consts/dates.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word_status.dart';

class MyWordStatusDTO {
  static const String collectionName = "MyWordStatus";

  static const String fieldMyWordId = "myWordId";
  static const String fieldIsLearned = "isLearned";
  static const String fieldIsBookmarked = "isBookmarked";
  static const String fieldUpdateBy = "updateBy";
  static const String fieldCreatedAt = "createdAt";
  static const String fieldUpdatedAt = "updatedAt";

  final int myWordId;
  int isLearned;
  int isBookmarked;
  String? updateBy;
  DateTime createdAt;
  DateTime updatedAt;

  MyWordStatusDTO({
    required this.myWordId,
    required this.isLearned,
    required this.isBookmarked,
    this.updateBy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Firestore → MyWordStatusDTO
  factory MyWordStatusDTO.fromFirebase(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return MyWordStatusDTO(
      myWordId: data[fieldMyWordId] as int,
      isLearned: data[fieldIsLearned] as int,
      isBookmarked: data[fieldIsBookmarked] as int,
      updateBy: data[fieldUpdateBy] as String?,
      createdAt: (data[fieldCreatedAt] as Timestamp).toDate().toUtc(),
      updatedAt: (data[fieldUpdatedAt] as Timestamp).toDate().toUtc(),
    );
  }

  /// MyWordStatusDTO → MyWordStatus entity
  MyWordStatus toEntity() {
    return MyWordStatus(
      wordId: myWordId,
      isLearned: isLearned == 1,
      isBookmarked: isBookmarked == 1,
      editAt: updatedAt,
    );
  }

  /// MyWordStatusDTO → Firestore
  Map<String, dynamic> toFirebase() {
    return {
      fieldMyWordId: myWordId,
      fieldIsLearned: isLearned,
      fieldIsBookmarked: isBookmarked,
      fieldUpdateBy: updateBy,
      fieldCreatedAt: Timestamp.fromDate(createdAt.toUtc()),
      fieldUpdatedAt: Timestamp.fromDate(updatedAt.toUtc()),
    };
  }

  /// MyWordStatus entity → MyWordStatusDTO
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
