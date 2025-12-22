import 'package:my_dic/core/common/enums/feature_tag.dart';

class UpdateMyWordStatusInputData {
  int index;
  int wordId;
  Set<FeatureTag> status;
  UpdateMyWordStatusInputData(this.wordId, this.status, this.index);
}
