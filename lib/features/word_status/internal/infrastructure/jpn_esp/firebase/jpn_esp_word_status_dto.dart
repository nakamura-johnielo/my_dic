/// Firestore wire representation of a Jpn-Esp word-status document.
///
/// This remains an infrastructure transport type so the Firestore schema stays
/// separate from the feature domain model.
final class JpnEspWordStatusDto {
  const JpnEspWordStatusDto({
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

  static const collectionName = 'JpnEspWordStatus';
  static const fieldWordId = 'wordId';
  static const fieldIsLearned = 'isLearned';
  static const fieldIsBookmarked = 'isBookmarked';
  static const fieldHasNote = 'hasNote';
  static const fieldUpdateBy = 'updateBy';
  static const fieldCreatedAt = 'createdAt';
  static const fieldUpdatedAt = 'updatedAt';
  static const fieldRevision = 'revision';
  static const fieldLastMutationId = 'lastMutationId';
  static const fieldClientUpdatedAt = 'clientUpdatedAt';

  final int wordId;
  final int isLearned;
  final int isBookmarked;
  final int hasNote;
  final String? updateBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int remoteRevision;
  final String? lastMutationId;
  final DateTime? clientUpdatedAt;
}
