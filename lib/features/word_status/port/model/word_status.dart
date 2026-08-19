import 'package:my_dic/features/catalog/port/catalog.dart';

/// 1 つの Catalog 単語に対して WordStatus が所有する、アカウントスコープのステータス情報です。
final class WordStatus {
  const WordStatus({
    required this.word,
    required this.isLearned,
    required this.isBookmarked,
    required this.hasNote,
    required this.updatedAt,
  });

  /// [word] に対応する物理行が存在しない場合に使用するステータスです。
  const WordStatus.initial(this.word)
      : isLearned = false,
        isBookmarked = false,
        hasNote = false,
        updatedAt = null;

  final CatalogWordRef word;
  final bool isLearned;
  final bool isBookmarked;
  final bool hasNote;

  /// 最後に永続化された更新です。初期ステータスの場合は `null` です。
  final DateTime? updatedAt;

  WordStatus copyWith({
    CatalogWordRef? word,
    bool? isLearned,
    bool? isBookmarked,
    bool? hasNote,
    DateTime? updatedAt,
  }) =>
      WordStatus(
        word: word ?? this.word,
        isLearned: isLearned ?? this.isLearned,
        isBookmarked: isBookmarked ?? this.isBookmarked,
        hasNote: hasNote ?? this.hasNote,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  bool operator ==(Object other) =>
      other is WordStatus &&
      other.word == word &&
      other.isLearned == isLearned &&
      other.isBookmarked == isBookmarked &&
      other.hasNote == hasNote &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      Object.hash(word, isLearned, isBookmarked, hasNote, updatedAt);
}
