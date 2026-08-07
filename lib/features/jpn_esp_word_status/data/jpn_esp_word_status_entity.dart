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
  static const String fieldRevision = "revision";
  static const String fieldLastMutationId = "lastMutationId";
  static const String fieldClientUpdatedAt = "clientUpdatedAt";

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

  JpnEspWordStatusDTO({
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

  /// Firestore → DTO conversion
  /// DTO → Firestore conversion
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
  static JpnEspWordStatusDTO fromDomain(JpnEspWordStatus status,
      {DateTime? now}) {
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
