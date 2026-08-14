import 'package:my_dic/features/catalog/port/catalog.dart';

/// The account-scoped status facts owned by WordStatus for one Catalog word.
final class WordStatus {
  const WordStatus({
    required this.word,
    required this.isLearned,
    required this.isBookmarked,
    required this.hasNote,
    required this.updatedAt,
  });

  /// The status used when no physical row exists for [word].
  const WordStatus.initial(this.word)
      : isLearned = false,
        isBookmarked = false,
        hasNote = false,
        updatedAt = null;

  final CatalogWordRef word;
  final bool isLearned;
  final bool isBookmarked;
  final bool hasNote;

  /// The last persisted update, or `null` when this is an initial status.
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
