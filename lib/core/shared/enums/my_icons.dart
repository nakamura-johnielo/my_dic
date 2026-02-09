import 'package:flutter/material.dart';

enum MyIcons {
  edit,
  delete,
}

extension MyIconsSource on MyIcons {
  IconData get icon {
    switch (this) {
      case MyIcons.edit:
        return Icons.edit_note_rounded;
      case MyIcons.delete:
        return Icons.delete;
    }
  }
}
