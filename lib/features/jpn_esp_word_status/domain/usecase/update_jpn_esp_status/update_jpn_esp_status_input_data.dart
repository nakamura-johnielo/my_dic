
class UpdateJpnEspStatusInputData {
  int wordId;
  bool? isLearned;
  bool? isBookmarked;
  bool? hasNote;

  UpdateJpnEspStatusInputData({
    required this.wordId,
    this.isLearned,
    this.isBookmarked,
    this.hasNote,
  });
}
