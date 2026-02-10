
class UpdateStatusInputData {
  int wordId;
  bool? isLearned;
  bool? isBookmarked;
  bool? hasNote;

  UpdateStatusInputData({
    required this.wordId,
    this.isLearned,
    this.isBookmarked,
    this.hasNote,
  });
}
