import 'package:flutter/material.dart';

class MyIconButton2 extends StatefulWidget {
  final IconData defaultIcon;
  final IconData? pressedIcon;
  final IconData? hoveredIcon;
  final IconData? runningIcon;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double? iconSize;
  final Color? defaultIconColor;
  final Color? pressedIconColor;
  final Color? hoveredIconColor;
  final Color? runningIconColor;

  const MyIconButton2(
      {super.key,
      required this.defaultIcon,
      this.pressedIcon,
      this.hoveredIcon,
      this.runningIcon,
      this.onTap,
      this.padding,
      this.iconSize,
      this.defaultIconColor,
      this.pressedIconColor,
      this.hoveredIconColor,
      this.runningIconColor});

  @override
  _MyIconButton2State createState() => _MyIconButton2State();
}

/* class _MyIconButtonState extends State<MyIconButton> {
  Future<void>? currentAction;
  late final IconData defaultIcon;
  late final IconData? pressedIcon;
  late final IconData? hoveredIcon;
  late final IconData? runnningIcon;
  late final VoidCallback? onTap;

  @override
  void initState() {
    super.initState();
    defaultIcon = widget.defaultIcon;
    pressedIcon = widget.pressedIcon;
    hoveredIcon = widget.hoveredIcon;
    runnningIcon = widget.runnningIcon;
    onTap = widget.onTap;
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        late final Future<void> thisAction;
        thisAction = Future<void>.delayed(const Duration(seconds: 1), () {
          if (currentAction == thisAction) {
            setState(() {
              currentAction = null;
            });
          }
        });
        setState(() {
          currentAction = thisAction;
        });
      },
      style: TextButton.styleFrom(
        overlayColor: Colors.transparent,
        foregroundBuilder:
            (BuildContext context, Set<WidgetState> states, Widget? child) {
          late final IconData currentIcon;
          if (currentAction != null) {
            currentIcon = runnningIcon ?? defaultIcon;
          } else if (states.contains(WidgetState.pressed)) {
            currentIcon = pressedIcon ?? defaultIcon;
          } else if (states.contains(WidgetState.hovered)) {
            currentIcon = hoveredIcon ?? defaultIcon;
          } else {
            currentIcon = defaultIcon;
          }
          return AnimatedContainer(
            padding: EdgeInsets.all(0),
            margin: EdgeInsets.all(0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn,
            child: Icon(currentIcon),
          );
        },
      ),
      child: const Text('This child is not used'),
    );
  }
}
 */

class _MyIconButton2State extends State<MyIconButton2> {
  Future<void>? currentAction;
  late VoidCallback? onTap;
  late IconData defaultIcon;
  late final IconData? pressedIcon;
  late final IconData? hoveredIcon;
  late final IconData? runningIcon;
  late final Color? defaultIconColor;
  late final Color? pressedIconColor;
  late final Color? hoveredIconColor;
  late final Color? runningIconColor;
  late final EdgeInsetsGeometry? padding;
  late final double? iconSize;

  @override
  void initState() {
    super.initState();
    defaultIcon = widget.defaultIcon;
    pressedIcon = widget.pressedIcon;
    hoveredIcon = widget.hoveredIcon;
    runningIcon = widget.runningIcon;
    onTap = widget.onTap;
    padding = widget.padding;
    iconSize = widget.iconSize;
    defaultIconColor = widget.defaultIconColor;
    pressedIconColor = widget.pressedIconColor;
    hoveredIconColor = widget.hoveredIconColor;
    runningIconColor = widget.runningIconColor;
  }

  @override
  void didUpdateWidget(covariant MyIconButton2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.defaultIcon != widget.defaultIcon) {
      setState(() {
        defaultIcon = widget.defaultIcon;
      });
    }
    if (oldWidget.onTap != widget.onTap) {
      setState(() {
        onTap = widget.onTap;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        onTap!();
        late final Future<void> thisAction;
        thisAction = Future<void>.delayed(const Duration(seconds: 1), () {
          if (currentAction == thisAction) {
            setState(() {
              currentAction = null;
            });
          }
        });
        setState(() {
          currentAction = thisAction;
        });
      },
      icon: Builder(
        builder: (BuildContext context) {
          late final IconData currentIcon;
          late final Color? currentIconColor;

          currentIcon = defaultIcon;
          currentIconColor = defaultIconColor;

          return AnimatedContainer(
            padding: padding ?? EdgeInsets.all(0),
            margin: EdgeInsets.all(0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn,
            child: Icon(
              currentIcon,
              size: iconSize,
              color: currentIconColor,
            ),
          );
        },
      ),
    );
  }
}
