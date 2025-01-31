import 'package:my_dic/Constants/Enums/feature_tag.dart';

class UpdateStatusRepositoryInputData {
  int wordId;
  Set<FeatureTag> status;
  UpdateStatusRepositoryInputData(this.wordId, this.status);
}
