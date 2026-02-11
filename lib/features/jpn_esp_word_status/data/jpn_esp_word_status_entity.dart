import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_dic/core/shared/consts/dates.dart';
import 'package:my_dic/features/jpn_esp_word_status/domain/jpn_esp_word_status.dart';

class JpnEspWordStatusDTO {
  static const String collectionName = "JpnEspWordStatus";

  static const String fieldwordId = "wordId";
  static const String fieldIsLearned = "isLearned";
  static const String fieldIsBookmarked = "isBookmarked";
  static const String fieldHasNote = "hasNote";
  static const String fieldupdateBy = "updateBy";
  static const String fieldCreatedAt = "createdAt";
  static const String fieldUpdatedAt = "updatedAt";

  final int wordId;
  int isLearned;
  int isBookmarked;
  int hasNote;
  String? updateBy;
  DateTime createdAt;
  DateTime updatedAt;

  JpnEspWordStatusDTO({
    required this.wordId,
    required this.isLearned,
    required this.isBookmarked,
    required this.hasNote,
    this.updateBy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Firestore → DTO conversion
  factory JpnEspWordStatusDTO.fromFirebase(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return JpnEspWordStatusDTO(
        wordId: data[fieldwordId],
        isLearned: data[fieldIsLearned],
        isBookmarked: data[fieldIsBookmarked],
        hasNote: data[fieldHasNote],
        updateBy: data[fieldupdateBy],
        createdAt: (data[fieldCreatedAt] as Timestamp).toDate().toUtc(),
        updatedAt: (data[fieldUpdatedAt] as Timestamp).toDate().toUtc());
  }

  /// DTO → Firestore conversion
  Map<String, dynamic> toMap() {
    return {
      fieldwordId: wordId,
      fieldIsLearned: isLearned,
      fieldIsBookmarked: isBookmarked,
      fieldHasNote: hasNote,
      fieldupdateBy: updateBy,
      fieldCreatedAt: Timestamp.fromDate(createdAt),
      fieldUpdatedAt: Timestamp.fromDate(updatedAt),
    };
  }

  /// DTO → Domain Entity conversion
  JpnEspWordStatus toDomain() {
    return JpnEspWordStatus(
      wordId: wordId,
      isLearned: isLearned == 1,
      isBookmarked: isBookmarked == 1,
      hasNote: hasNote == 1,
      editAt: updatedAt,
    );
  }

  /// Domain Entity → DTO conversion
  static JpnEspWordStatusDTO fromDomain(JpnEspWordStatus status, {DateTime? now}) {
    final timestamp = now ?? DateTime.now().toUtc();
    return JpnEspWordStatusDTO(
      wordId: status.wordId,
      isLearned: status.isLearned ? 1 : 0,
      isBookmarked: status.isBookmarked ? 1 : 0,
      hasNote: status.hasNote ? 1 : 0,
      createdAt: timestamp,
      updatedAt: status.editAt,
    );
  }
}
