import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/DI/product.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/dictionary/esj_dictionary.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/my_word.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/verb/conjugacion/conjugacions.dart';

/// ViewModelをプロバイダーで提供
final myWordViewModelProvider =
    ChangeNotifierProvider((ref) => DI<MyWordViewModel>());

class MyWordViewModel extends ChangeNotifier {
  List<MyWord> _item = [];

  List<MyWord> get item => _item;
  set item(List<MyWord> value) {
    _item = value;
    notifyListeners();
  }

  setItemInHead(MyWord value) {
    _item.insert(0, value);
    notifyListeners();
  }
}
