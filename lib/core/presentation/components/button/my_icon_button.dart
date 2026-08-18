import 'package:flutter/material.dart';

class MyIconButton extends StatefulWidget {
  final IconData defaultIcon;
  final IconData? pressedIcon;
  final IconData? hoveredIcon;
  final IconData? runnningIcon;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double? iconSize;
  final Color? defaultIconColor;
  final Color? pressedIconColor;
  final Color? hoveredIconColor;
  final Color? runnningIconColor;

  const MyIconButton(
      {super.key,
      required this.defaultIcon,
      this.pressedIcon,
      this.hoveredIcon,
      this.runnningIcon,
      this.onTap,
      this.padding,
      this.iconSize,
      this.defaultIconColor,
      this.pressedIconColor,
      this.hoveredIconColor,
      this.runnningIconColor});

  @override
  State<MyIconButton> createState() => _MyIconButtonState();
}

class _MyIconButtonState extends State<MyIconButton> {
  Future<void>? currentAction;
  late VoidCallback? onTap;
  late IconData defaultIcon;
  late final IconData? pressedIcon;
  late final IconData? hoveredIcon;
  late final IconData? runnningIcon;
  late final Color? defaultIconColor;
  late final Color? pressedIconColor;
  late final Color? hoveredIconColor;
  late final Color? runnningIconColor;
  late final EdgeInsetsGeometry? padding;
  late final double? iconSize;

  @override
  void initState() {
    super.initState();
    defaultIcon = widget.defaultIcon;
    pressedIcon = widget.pressedIcon;
    hoveredIcon = widget.hoveredIcon;
    runnningIcon = widget.runnningIcon;
    onTap = widget.onTap;
    padding = widget.padding;
    iconSize = widget.iconSize;
    defaultIconColor = widget.defaultIconColor;
    pressedIconColor = widget.pressedIconColor;
    hoveredIconColor = widget.hoveredIconColor;
    runnningIconColor = widget.runnningIconColor;
  }

  @override
  void didUpdateWidget(covariant MyIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.defaultIcon != widget.defaultIcon) {
      setState(() {
        defaultIcon = widget.defaultIcon; // 🔥 新しいアイコンに更新
      });
    }
    if (oldWidget.onTap != widget.onTap) {
      setState(() {
        onTap = widget.onTap; // 🔥 新しいアイコンに更新
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        if (onTap != null) {
          onTap!(); // Execute the callback
        }

        late final Future<void> thisAction;
        thisAction = Future<void>.delayed(const Duration(seconds: 1), () {
          if (mounted && currentAction == thisAction) {
            setState(() {
              currentAction = null;
            });
          }
        });
        if (mounted) {
          setState(() {
            currentAction = thisAction;
          });
        }
      },
      style: TextButton.styleFrom(
        minimumSize: Size(1, 1),
        padding: padding ?? EdgeInsets.all(0),
        overlayColor: Colors.transparent,
        foregroundBuilder:
            (BuildContext context, Set<WidgetState> states, Widget? child) {
          late final IconData currentIcon;
          late final Color? currentIconColor;
          if (currentAction != null) {
            currentIcon = runnningIcon ?? defaultIcon;
            currentIconColor = runnningIconColor ?? defaultIconColor;
          } else if (states.contains(WidgetState.pressed)) {
            currentIcon = pressedIcon ?? defaultIcon;
            currentIconColor = pressedIconColor ?? defaultIconColor;
          } else if (states.contains(WidgetState.hovered)) {
            currentIcon = hoveredIcon ?? defaultIcon;
            currentIconColor = hoveredIconColor ?? defaultIconColor;
          } else {
            currentIcon = defaultIcon;
            currentIconColor = defaultIconColor;
          }
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
      child: const Text('no display this message fuck you baby'),
    );
  }
}
