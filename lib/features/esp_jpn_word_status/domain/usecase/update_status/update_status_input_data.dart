import 'package:my_dic/core/shared/enums/feature_tag.dart';

class UpdateStatusInputData {
  int wordId;
  String? accountId;
  Set<FeatureTag> status;
  UpdateStatusInputData(this.accountId, this.wordId, this.status);
}
