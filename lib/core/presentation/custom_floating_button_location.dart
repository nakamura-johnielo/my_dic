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
    // final double fabY = scaffoldGeometry.scaffoldSize.height -
    //     scaffoldGeometry.floatingActionButtonSize.height -
    //     scaffoldGeometry.minInsets.bottom -
    //     bottomNavBarHeight -
    //     16.0;
    // Stable Y: avoid using scaffoldGeometry.minInsets.bottom which can change during scroll
    final double fabY = scaffoldGeometry.scaffoldSize.height -
        scaffoldGeometry.floatingActionButtonSize.height -
        bottomNavBarHeight -
        16.0;
    return Offset(fabX, fabY);
  }
}

class NoScaleFloatingActionButtonAnimator extends FloatingActionButtonAnimator {
  const NoScaleFloatingActionButtonAnimator();
  @override
  Animation<double> getScaleAnimation({required Animation<double> parent}) {
    return const AlwaysStoppedAnimation<double>(1.0);
  }

  @override
  Offset getOffset(
      {required Offset begin, required Offset end, required double progress}) {
    // TODO: implement getOffset
    // print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
    
    return begin;
  }

  @override
  Animation<double> getRotationAnimation({required Animation<double> parent}) {
  
    return const AlwaysStoppedAnimation<double>(1.0);
  }
}
