import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/DI/product.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/jpn_esp/jpn_esp_word.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/verb/conjugacion/result_conjugacions.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/word.dart';

/// ViewModelをプロバイダーで提供
final searchViewModelProvider =
    ChangeNotifierProvider((ref) => DI<SearchViewModel>());

class SearchViewModel extends ChangeNotifier {
  List<Word> _filteredItems = [];
  String _query = "";

  // 検索クエリの取得と更新
  String get query => _query;
  set query(String value) {
    _query = value.trim();
    if (value.isEmpty) {
      _filteredItems = [];
      _filteredJpnEspItems = [];
    }
    notifyListeners();
  }

  List<Word> get filteredItems => _filteredItems;
  set filteredItems(List<Word> value) {
    _filteredItems = value;
    _filteredJpnEspItems.clear();
    notifyListeners();
  }

  void setEspJpnItemsInTail(List<Word> values) {
    _filteredItems = [..._filteredItems, ...values];
    notifyListeners();
  }

  void inicializeEspJpnItems(List<Word> values) {
    _filteredItems = values;
    _filteredJpnEspItems.clear();
    notifyListeners();
  }

  List<JpnEspWord> _filteredJpnEspItems = [];

  List<JpnEspWord> get filteredJpnEspItems => _filteredJpnEspItems;
  set filteredJpnEspItems(List<JpnEspWord> value) {
    _filteredJpnEspItems = value;
    _filteredItems.clear();
    _filteredConjugacionItems.clear();
    notifyListeners();
  }

  void setJpnEspItemsInTail(List<JpnEspWord> values) {
    _filteredJpnEspItems = [..._filteredJpnEspItems, ...values];
    notifyListeners();
  }

  void inicializeJpnEspItems(List<JpnEspWord> values) {
    _filteredJpnEspItems = values;
    _filteredItems.clear();
    _filteredConjugacionItems.clear();
    notifyListeners();
  }

  List<SearchResultConjugacions> _filteredConjugacionItems = [];

  List<SearchResultConjugacions> get filteredConjugacionItems =>
      _filteredConjugacionItems;
  set filteredConjugacionItems(List<SearchResultConjugacions> value) {
    _filteredConjugacionItems = value;
    _filteredJpnEspItems.clear();
    notifyListeners();
  }

  void setConjugacionItemsInTail(List<SearchResultConjugacions> values) {
    _filteredConjugacionItems = [..._filteredConjugacionItems, ...values];
    notifyListeners();
  }

  void inicializeConjugacionItems(List<SearchResultConjugacions> values) {
    _filteredConjugacionItems = values;
    _filteredJpnEspItems.clear();
    notifyListeners();
  }
}
