
import 'package:flutter/material.dart';
import 'package:my_dic/core/shared/consts/ui/screen_size.dart';
class ScreenSize {
  static double width(BuildContext context) => MediaQuery.of(context).size.width;
  static double height(BuildContext context) => MediaQuery.of(context).size.height;
  static double devicePixelRatio(BuildContext context) => MediaQuery.of(context).devicePixelRatio;

  static bool isSmall(BuildContext context, {double breakpoint = BreakPoint.mobile}) =>
      width(context) < breakpoint;

  static bool isMedium(BuildContext context, {double min = BreakPoint.mobile, double max = BreakPoint.tablet}) {
    final w = width(context);
    return w >= min && w < max;
  }

  static bool isLarge(BuildContext context, {double breakpoint = BreakPoint.tablet}) =>
      width(context) >= breakpoint;

  static T responsiveValue<T>(
    BuildContext context, {
    required T small,
    T? medium,
    required T large,
    double smallMax = 600,
    double mediumMax = 1024,
  }) {
    final w = width(context);
    if (w < smallMax) return small;
    if (w < mediumMax) return medium ?? large;
    return large;
  }
}