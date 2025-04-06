import 'package:my_dic/Constants/Enums/feature_tag.dart';

class UpdateStatusRepositoryInputData {
  int wordId;
  Set<FeatureTag> status;
  String editAt;
  UpdateStatusRepositoryInputData(this.wordId, this.status, this.editAt);
}
