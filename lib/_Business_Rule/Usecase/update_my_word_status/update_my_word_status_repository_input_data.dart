import 'package:my_dic/Constants/Enums/feature_tag.dart';

class UpdateMyWordStatusRepositoryInputData {
  int wordId;
  Set<FeatureTag> status;
  String editAt;
  UpdateMyWordStatusRepositoryInputData(this.wordId, this.status, this.editAt);
}
