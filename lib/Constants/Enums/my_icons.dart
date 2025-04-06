import 'package:flutter/material.dart';

enum MyIcons {
  edit,
  delete,
/*   home,
  search,
  cart,
  user,
  settings,
  notification,
  help,
  logout,
  favorite,
  order,
  wishlist,
  chat,
  location,
  payment,
  history,
  support */
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
