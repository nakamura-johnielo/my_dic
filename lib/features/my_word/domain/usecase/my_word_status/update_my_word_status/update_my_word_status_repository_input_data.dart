// class UpdateMyWordStatusRepositoryInputData {
//   int wordId;
//   Set<FeatureTag> status;
//   DateTime editAt;
//   String? userId;
  
  
//   UpdateMyWordStatusRepositoryInputData(this.wordId, this.status, this.editAt,this.userId);
// }

class UpdateMyWordStatusRepositoryInputData {
  final String wordId;
  final int? isLearned;
  final int? isBookmarked;
  final int? hasNote;
  DateTime editAt;
  final String? userId;

  UpdateMyWordStatusRepositoryInputData(
      this.wordId,
      this.isLearned,
      this.isBookmarked,  
      this.hasNote,
      this.editAt,
      this.userId,
      );
}