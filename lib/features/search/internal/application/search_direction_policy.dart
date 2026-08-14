import 'package:my_dic/features/search/port/search.dart';

/// Pure characterization of the direction rule previously held by presentation.
abstract final class SearchDirectionPolicy {
  static final RegExp _espJpnCharacters = RegExp(r'[a-zA-Záéíóúñü]');

  static SearchDirection fromText(String text) =>
      _espJpnCharacters.hasMatch(text)
          ? SearchDirection.espJpn
          : SearchDirection.jpnEsp;
}
