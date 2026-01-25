

// class UpdateMyWordStatusInputData {
//   int index;
//   int wordId;
//   Set<FeatureTag> status;
//   String? userId;
//   UpdateMyWordStatusInputData(this.wordId, this.status, this.index,this.userId);
// }



class UpdateMyWordStatusInputData {
  final int wordId;
  final int? isLearned;
  final int? isBookmarked;
  final int? hasNote;
  final String? userId;

  UpdateMyWordStatusInputData(
      this.wordId,
      this.isLearned,
      this.isBookmarked,  
      this.hasNote,
      this.userId,
      );
}