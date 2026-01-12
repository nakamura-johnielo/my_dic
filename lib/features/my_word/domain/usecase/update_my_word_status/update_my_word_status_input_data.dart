import 'package:my_dic/core/shared/enums/feature_tag.dart';

class UpdateMyWordStatusInputData {
  int index;
  int wordId;
  Set<FeatureTag> status;
  String? userId;
  UpdateMyWordStatusInputData(this.wordId, this.status, this.index,this.userId);
}
