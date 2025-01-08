enum ScreenTab {
  note,
  search,
  ranking,
}

extension TabExtension on ScreenTab {
  String get name {
    switch (this) {
      case ScreenTab.search:
        return '検索';
      case ScreenTab.ranking:
        return '頻度別';
      case ScreenTab.note:
        return 'メモ';
    }
  }
}

extension TabIndexExtension on ScreenTab {
  int get index {
    switch (this) {
      case ScreenTab.note:
        return 0;
      case ScreenTab.search:
        return 1;
      case ScreenTab.ranking:
        return 2;
    }
  }
}
