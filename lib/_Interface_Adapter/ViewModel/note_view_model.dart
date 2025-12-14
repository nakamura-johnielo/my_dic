import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/DI/product.dart';
import 'package:my_dic/core/domain/entity/jpn_esp/jpn_esp_word.dart';

// final noteViewModelProvider =
//     ChangeNotifierProvider((ref) => DI<NoteViewModel>());

class NoteViewModel extends ChangeNotifier {
  List<JpnEspWord> _items = [];
  List<JpnEspWord> get items => _items;
  set items(List<JpnEspWord> value) {
    _items = value;
    notifyListeners();
  }

  void addItemsInTail(List<JpnEspWord> l) {
    _items = [..._items, ...l];
    //itemが正常に追加されてからpage数更新
    //初期化時は-1
    notifyListeners();
  }
}
