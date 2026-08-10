import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';

/// The status associated with a word in a specific Catalog dataset.
final class WordStatus {
  const WordStatus({
    required this.word,
    required this.isLearned,
    required this.isBookmarked,
    required this.hasNote,
    required this.updatedAt,
  });

  final CatalogWordRef word;
  final bool isLearned;
  final bool isBookmarked;
  final bool hasNote;
  final DateTime updatedAt;

  WordStatus copyWith({
    CatalogWordRef? word,
    bool? isLearned,
    bool? isBookmarked,
    bool? hasNote,
    DateTime? updatedAt,
  }) => WordStatus(
    word: word ?? this.word,
    isLearned: isLearned ?? this.isLearned,
    isBookmarked: isBookmarked ?? this.isBookmarked,
    hasNote: hasNote ?? this.hasNote,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
