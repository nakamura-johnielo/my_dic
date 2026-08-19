/// 機能の外部に公開する不変の MyWord スナップショット。
final class MyWord {
  const MyWord({
    required this.wordId,
    required this.headword,
    required this.description,
    required this.updatedAt,
  });

  final String wordId;
  final String headword;
  final String description;
  final DateTime updatedAt;

  MyWord copyWith({
    String? wordId,
    String? headword,
    String? description,
    DateTime? updatedAt,
  }) =>
      MyWord(
        wordId: wordId ?? this.wordId,
        headword: headword ?? this.headword,
        description: description ?? this.description,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  bool operator ==(Object other) =>
      other is MyWord &&
      other.wordId == wordId &&
      other.headword == headword &&
      other.description == description &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(wordId, headword, description, updatedAt);
}

/// MyWord に関連付けられた不変のステータススナップショット。
final class MyWordStatus {
  const MyWordStatus({
    required this.wordId,
    required this.isLearned,
    required this.isBookmarked,
    required this.hasNote,
    required this.updatedAt,
  });

  final String wordId;
  final bool isLearned;
  final bool isBookmarked;
  final bool hasNote;
  final DateTime updatedAt;

  MyWordStatus copyWith({
    String? wordId,
    bool? isLearned,
    bool? isBookmarked,
    bool? hasNote,
    DateTime? updatedAt,
  }) =>
      MyWordStatus(
        wordId: wordId ?? this.wordId,
        isLearned: isLearned ?? this.isLearned,
        isBookmarked: isBookmarked ?? this.isBookmarked,
        hasNote: hasNote ?? this.hasNote,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  bool operator ==(Object other) =>
      other is MyWordStatus &&
      other.wordId == wordId &&
      other.isLearned == isLearned &&
      other.isBookmarked == isBookmarked &&
      other.hasNote == hasNote &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      Object.hash(wordId, isLearned, isBookmarked, hasNote, updatedAt);
}

/// MyWord カードで使用する読み取り専用の単語およびステータスプロジェクション。
final class MyWordItem {
  const MyWordItem({required this.word, required this.status});

  final MyWord word;
  final MyWordStatus status;

  MyWordItem copyWith({MyWord? word, MyWordStatus? status}) =>
      MyWordItem(word: word ?? this.word, status: status ?? this.status);

  @override
  bool operator ==(Object other) =>
      other is MyWordItem && other.word == word && other.status == status;

  @override
  int get hashCode => Object.hash(word, status);
}
