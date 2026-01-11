import 'package:flutter_riverpod/flutter_riverpod.dart';

class BottomBarHeightNotifier extends StateNotifier<double> {
  BottomBarHeightNotifier() : super(0);
  void setHeight(double height) {
    state = height;
    print("~~~~~~~~~~~~~~~~~~~~~~^^^Bottom bar height set to: $height");
  }
}

final bottomBarHeightProvider = StateNotifierProvider<BottomBarHeightNotifier, double>((ref) {
  return BottomBarHeightNotifier();
});
