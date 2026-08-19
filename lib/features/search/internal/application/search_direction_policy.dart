import 'package:my_dic/features/search/port/search.dart';

/// 以前は表示層が保持していた方向ルールを純粋に表現したものです。
abstract final class SearchDirectionPolicy {
  static final RegExp _espJpnCharacters = RegExp(r'[a-zA-Záéíóúñü]');

  static SearchDirection fromText(String text) =>
      _espJpnCharacters.hasMatch(text)
          ? SearchDirection.espJpn
          : SearchDirection.jpnEsp;
}
