import 'package:flutter/material.dart';
import 'package:my_dic/core/domain/entity/jpn_esp/jpn_esp_word.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacion/result_conjugacions.dart';
import 'package:my_dic/core/domain/entity/word/word.dart';

// query -> 検索結果マッチ部分の色変える in conf_fragment
class SearchViewModel extends ChangeNotifier {
  List<EspJpnWord> _filteredItems = [];
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

  List<EspJpnWord> get filteredItems => _filteredItems;
  set filteredItems(List<EspJpnWord> value) {
    _filteredItems = value;
    _filteredJpnEspItems.clear();
    notifyListeners();
  }

  void addEspJpnItems(List<EspJpnWord> values) {
    _filteredItems = [..._filteredItems, ...values];
    notifyListeners();
  }

  void inicializeEspJpnItems(List<EspJpnWord> values) {
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

  void addJpnEspItems(List<JpnEspWord> values) {
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

  void addConjugacionItems(List<SearchResultConjugacions> values) {
    _filteredConjugacionItems = [..._filteredConjugacionItems, ...values];
    notifyListeners();
  }

  void inicializeConjugacionItems(List<SearchResultConjugacions> values) {
    _filteredConjugacionItems = values;
    _filteredJpnEspItems.clear();
    notifyListeners();
  }
}
