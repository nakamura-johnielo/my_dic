import 'package:flutter/material.dart';

class FloatAboveNavBar extends FloatingActionButtonLocation {
  final double bottomNavBarHeight;
  const FloatAboveNavBar(this.bottomNavBarHeight);
  static const double adjustment = 16.0;

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double fabX = scaffoldGeometry.scaffoldSize.width -
        scaffoldGeometry.floatingActionButtonSize.width -
        16.0 -
        adjustment;
    final double fabY = scaffoldGeometry.scaffoldSize.height -
        scaffoldGeometry.floatingActionButtonSize.height -
        scaffoldGeometry.minInsets.bottom -
        bottomNavBarHeight -
        16.0;
    return Offset(fabX, fabY);
  }
}
