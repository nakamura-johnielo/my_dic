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
  int offset = 100;

  List<Ranking> get items => _items;
  set items(List<Ranking> value) {
    _items = value;
    notifyListeners();
  }

  void addItems(List<Ranking> l) {
    _items = [..._items, ...l];
  }
}
