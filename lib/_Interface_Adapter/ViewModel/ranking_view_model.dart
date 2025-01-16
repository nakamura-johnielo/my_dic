import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/DI/product.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/ranking.dart';

/// ViewModelをプロバイダーで提供
final rankingViewModelProvider =
    ChangeNotifierProvider((ref) => DI<RankingViewModel>());

class RankingViewModel extends ChangeNotifier {
  List<Ranking> _items = [];
  int page = 0;
  int size = 100;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool _hasNext = true;
  bool get hasNext => _hasNext;
  set hasNext(bool value) {
    _hasNext = value;
    notifyListeners();
  }

  List<Ranking> get items => _items;
  set items(List<Ranking> value) {
    _items = value;
    notifyListeners();
  }

  void addItems(List<Ranking> l) {
    _items = [..._items, ...l];
    page = page + 1;
    isLoading = false;
    if (l.length < size) {
      hasNext = false;
    }
    log("${_items.length} additems======================");
    notifyListeners();
  }
}
