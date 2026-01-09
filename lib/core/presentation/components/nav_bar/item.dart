
import 'dart:ui';

import 'package:flutter/widgets.dart';

class SelectedColors {
  const SelectedColors({
    required this.selected,
    required this.unselected,
  });
  final Color selected;
  final Color unselected;
}

class DestinatioinItem {
  const DestinatioinItem({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
}
