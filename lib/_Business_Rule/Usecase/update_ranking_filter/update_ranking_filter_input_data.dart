import 'package:my_dic/Constants/Enums/i_enum.dart';

class UpdateRankingFilterInputData {
  DisplayEnumMixin data;
  int filterType; //0:なし 1:あり -1:除外
  UpdateRankingFilterInputData(this.data, this.filterType);
}
