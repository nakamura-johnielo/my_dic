// class UpdateMyWordStatusInputData {
//   int index;
//   int wordId;
//   Set<FeatureTag> status;
//   String? userId;
//   UpdateMyWordStatusInputData(this.wordId, this.status, this.index,this.userId);
// }

class UpdateMyWordStatusInputData {
  final String wordId;
  final int? isLearned;
  final int? isBookmarked;
  final int? hasNote;

  UpdateMyWordStatusInputData(
      this.wordId, this.isLearned, this.isBookmarked, this.hasNote);
}
