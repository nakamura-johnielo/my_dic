import 'package:flutter/material.dart';

class HorizontalFader extends StatelessWidget {
  final Duration _kActionAnimDuration;
  final Cubic _kActionAnimCurve;
  final double height;
  final Widget child;
  final bool isVisible;

  const HorizontalFader({
    super.key,
    Duration kActionAnimDuration = const Duration(milliseconds: 220),
    Cubic kActionAnimCurve = Curves.easeInOut,
    required this.height,
    required this.child,
    required this.isVisible,
  })  : _kActionAnimDuration = kActionAnimDuration,
        _kActionAnimCurve = kActionAnimCurve;

  @override
  Widget build(BuildContext context) {
    return // action button (width: 0->hug, opacity: 0->1)
        SizedBox(
      height: height,
      child: AnimatedSwitcher(
        duration: _kActionAnimDuration,
        switchInCurve: _kActionAnimCurve,
        switchOutCurve: _kActionAnimCurve,
        transitionBuilder: (child, animation) {
          final curved =
              CurvedAnimation(parent: animation, curve: _kActionAnimCurve);
          return FadeTransition(
            opacity: curved,
            child: SizeTransition(
              sizeFactor: curved,
              axis: Axis.horizontal,
              axisAlignment: -1, // 左側基準で伸縮
              child: child,
            ),
          );
        },
        child: isVisible
            ? child
            : const SizedBox.shrink(
                key: ValueKey('no_action'),
              ),
      ),
    );
  }
}
