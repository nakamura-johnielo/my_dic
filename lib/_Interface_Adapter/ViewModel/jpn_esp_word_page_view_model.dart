import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/DI/product.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/dictionary/esj_dictionary.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/jpn_esp/jpn_esp_dictionary.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/verb/conjugacion/conjugacions.dart';

/// ViewModelをプロバイダーで提供
final JpnEspWordPageViewModelProvider =
    ChangeNotifierProvider((ref) => DI<JpnEspWordPageViewModel>());

class JpnEspWordPageViewModel extends ChangeNotifier {
  Map<int, List<JpnEspDictionary>> _dictionaryCache = {};
  List<int> _cashOrder = [];

  // 検索クエリの取得と更新
  Map<int, List<JpnEspDictionary>> get dictionaryCache => _dictionaryCache;
  setDictionaryCache(int wordId, List<JpnEspDictionary> value) {
    _dictionaryCache[wordId] = value;
    _cashOrder.add(wordId);
    notifyListeners();
  }

  removeData(int wordId) {
    _dictionaryCache.remove(wordId);
    _cashOrder.remove(wordId);
    notifyListeners();
  }

  popCash() {
    //一番古い野を削除
    _dictionaryCache.remove(_cashOrder[0]);
    _cashOrder.removeAt(0);
  }
}
