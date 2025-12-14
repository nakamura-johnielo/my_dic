import 'package:my_dic/Constants/Enums/feature_tag.dart';

class UpdateStatusInputData {
  int index;
  int wordId;
  Set<FeatureTag> status;
  UpdateStatusInputData(this.wordId, this.status, this.index);
}
