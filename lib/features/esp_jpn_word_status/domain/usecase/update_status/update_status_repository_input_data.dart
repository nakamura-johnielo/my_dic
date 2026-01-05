import 'package:my_dic/core/shared/enums/feature_tag.dart';

class UpdateStatusRepositoryInputData {
  int wordId;
  Set<FeatureTag> status;
  String editAt;
  UpdateStatusRepositoryInputData(this.wordId, this.status, this.editAt);
}
