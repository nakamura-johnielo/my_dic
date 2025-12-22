import 'package:my_dic/core/common/enums/feature_tag.dart';

class UpdateStatusInputData {
  int index;
  int wordId;
  Set<FeatureTag> status;
  UpdateStatusInputData(this.wordId, this.status, this.index);
}
