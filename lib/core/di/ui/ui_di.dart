import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/utils/logger.dart';

class BottomBarHeightNotifier extends StateNotifier<double> {
  BottomBarHeightNotifier() : super(0);
  void setHeight(double height) {
    state = height;
    AppLogger.print(
        "~~~~~~~~~~~~~~~~~~~~~~^^^Bottom bar height set to: $height");
  }
}

final bottomBarHeightProvider =
    StateNotifierProvider<BottomBarHeightNotifier, double>((ref) {
  return BottomBarHeightNotifier();
});
