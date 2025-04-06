import 'package:my_dic/Constants/Enums/feature_tag.dart';

class UpdateMyWordStatusInputData {
  int index;
  int wordId;
  Set<FeatureTag> status;
  UpdateMyWordStatusInputData(this.wordId, this.status, this.index);
}
