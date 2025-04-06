class UpdateMyWordStatusOutputData {
  int index;
  int wordId;
  bool isBookmarked;
  bool isLearned;
  bool hasNote;
  UpdateMyWordStatusOutputData(
      {required this.index,
      required this.wordId,
      required this.isBookmarked,
      required this.isLearned,
      required this.hasNote});
}
