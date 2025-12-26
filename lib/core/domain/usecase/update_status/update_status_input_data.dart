import 'package:my_dic/core/shared/enums/feature_tag.dart';

class UpdateStatusInputData {
  int wordId;
  String userId;
  Set<FeatureTag> status;
  UpdateStatusInputData(this.userId, this.wordId, this.status);
}
