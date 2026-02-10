class UpdateMyWordStatusInputData {
  final String wordId;
  final int? isLearned;
  final int? isBookmarked;
  final int? hasNote;

  UpdateMyWordStatusInputData(
      this.wordId, this.isLearned, this.isBookmarked, this.hasNote);
}
