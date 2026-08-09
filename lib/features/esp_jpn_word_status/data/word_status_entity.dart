/// Firestore wire DTO for the Esp-Jpn status dataset.
///
/// It deliberately remains a raw transport type; the unified word-status
/// domain model is not part of the synchronization boundary.
class WordStatusDTO {
  static const String collectionName = 'WordStatus';
  static const String fieldwordId = 'wordId';
  static const String fieldIsLearned = 'isLearned';
  static const String fieldIsBookmarked = 'isBookmarked';
  static const String fieldHasNote = 'hasNote';
  static const String fieldupdateBy = 'updateBy';
  static const String fieldCreatedAt = 'createdAt';
  static const String fieldUpdatedAt = 'updatedAt';
  static const String fieldRevision = 'revision';
  static const String fieldLastMutationId = 'lastMutationId';
  static const String fieldClientUpdatedAt = 'clientUpdatedAt';

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
}
