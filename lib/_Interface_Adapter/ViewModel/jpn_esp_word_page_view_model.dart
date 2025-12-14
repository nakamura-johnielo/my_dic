import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/DI/product.dart';
import 'package:my_dic/core/domain/entity/dictionary/esj_dictionary.dart';
import 'package:my_dic/core/domain/entity/jpn_esp/jpn_esp_dictionary.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacion/conjugacions.dart';

/// ViewModelをプロバイダーで提供
// final JpnEspWordPageViewModelProvider =
//     ChangeNotifierProvider((ref) => ref.read(jpnEspWordPageViewModelProvider));

class JpnEspWordPageViewModel extends ChangeNotifier {
  Map<int, List<JpnEspDictionary>> _dictionaryCache = {};
  List<int> _cashOrder = [];

  // 検索クエリの取得と更新
  Map<int, List<JpnEspDictionary>> get dictionaryCache => _dictionaryCache;
  void setDictionaryCache(int wordId, List<JpnEspDictionary> value) {
    _dictionaryCache[wordId] = value;
    _cashOrder.add(wordId);
    notifyListeners();
  }

  void removeData(int wordId) {
    _dictionaryCache.remove(wordId);
    _cashOrder.remove(wordId);
    notifyListeners();
  }

  void popCash() {
    //一番古い野を削除
    _dictionaryCache.remove(_cashOrder[0]);
    _cashOrder.removeAt(0);
  }
}
