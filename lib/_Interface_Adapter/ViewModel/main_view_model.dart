import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/DI/product.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/dictionary/esj_dictionary.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/verb/conjugacion/conjugacions.dart';

/// ViewModelをプロバイダーで提供
final mainViewModelProvider =
    ChangeNotifierProvider((ref) => DI<MainViewModel>());

class MainViewModel extends ChangeNotifier {
  Map<int, List<EsjDictionary>> _dictionaryCache = {};
  Map<int, Conjugacions?> _conjugacionCache = {};

  // 検索クエリの取得と更新
  Map<int, Conjugacions?> get conjugacionCache => _conjugacionCache;
  setConjugacionCache(int wordId, Conjugacions? value) {
    _conjugacionCache[wordId] = value;
    notifyListeners();
  }

  // 検索クエリの取得と更新
  Map<int, List<EsjDictionary>> get dictionaryCache => _dictionaryCache;
  setDictionaryCache(int wordId, List<EsjDictionary> value) {
    _dictionaryCache[wordId] = value;
    notifyListeners();
  }

  removeData(int wordId) {
    _dictionaryCache.remove(wordId);
    _conjugacionCache.remove(wordId);
    notifyListeners();
  }
}
