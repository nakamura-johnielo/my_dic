class MyWordStatusState {
  final bool isLearned;
  final bool isBookmarked;

  MyWordStatusState({
    this.isLearned = false,
    this.isBookmarked = false,
  });

  MyWordStatusState copyWith({
    bool? isLearned,
    bool? isBookmarked,
  }) {
    return MyWordStatusState(
      isLearned: isLearned ?? this.isLearned,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}
