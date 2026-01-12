import 'package:my_dic/core/shared/enums/feature_tag.dart';

class UpdateMyWordStatusRepositoryInputData {
  int wordId;
  Set<FeatureTag> status;
  DateTime editAt;
  String? userId;
  
  UpdateMyWordStatusRepositoryInputData(this.wordId, this.status, this.editAt,this.userId);
}
