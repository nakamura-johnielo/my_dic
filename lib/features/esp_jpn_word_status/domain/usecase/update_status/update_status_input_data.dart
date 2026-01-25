import 'package:my_dic/core/shared/enums/feature_tag.dart';

class UpdateStatusInputData {
  int wordId;
  String? accountId;
  bool? isLearned;
  bool? isBookmarked;
  bool? hasNote;

  UpdateStatusInputData({required this.wordId,this.accountId,  this.isLearned,
      this.isBookmarked, this.hasNote});
}
