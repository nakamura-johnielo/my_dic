class WordStatusState {
  final bool isLearned;
  final bool isBookmarked;
  final bool hasNote;

  WordStatusState({
     this.isLearned =false,
     this.isBookmarked =false,
     this.hasNote =false,
  });

  WordStatusState copyWith({
    bool? isLearned,
    bool? isBookmarked,
    bool? hasNote,
  }) {
    return WordStatusState(
      isLearned: isLearned ?? this.isLearned,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      hasNote: hasNote ?? this.hasNote,
    );
  }
}
