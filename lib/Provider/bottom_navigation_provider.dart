import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/Constants/screen_tab.dart';

final tabIndexProvider = StateProvider<ScreenTab>((ref) {
  return ScreenTab.search; // 初期タブインデックス
});
