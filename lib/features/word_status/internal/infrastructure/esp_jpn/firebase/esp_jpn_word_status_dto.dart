/// Esp-Jpn 単語ステータスドキュメントの Firestore 通信表現です。
///
/// これは意図的にインフラの通信型です。Firestore スキーマを呼び出し元が使用する機能ドメイン
/// モデルから分離します。
final class EspJpnWordStatusDto {
  const EspJpnWordStatusDto({
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

  static const collectionName = 'WordStatus';
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
