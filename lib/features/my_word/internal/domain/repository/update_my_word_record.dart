final class UpdateMyWordInputData {
  String myWordId;
  String headword;
  String description;
  DateTime editAt;
  String? userId;
  UpdateMyWordInputData(
      this.myWordId, this.headword, this.description, this.editAt, this.userId);
}
