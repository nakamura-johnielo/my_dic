class UpdateMyWordRepositoryInputData {
  String myWordId;
  String headword;
  String description;
  DateTime editAt;
  String? userId;
  UpdateMyWordRepositoryInputData(
      this.myWordId, this.headword, this.description, this.editAt, this.userId);
}
