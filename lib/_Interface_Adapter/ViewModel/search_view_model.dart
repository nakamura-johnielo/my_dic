import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/DI/product.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/word.dart';
import 'package:my_dic/_Interface_Adapter/Controller/buffer_controller.dart';

/// ViewModelをプロバイダーで提供
final searchViewModelProvider =
    ChangeNotifierProvider((ref) => DI<SearchViewModel>());

class SearchViewModel extends ChangeNotifier {
  //final BufferController _bufferController;
  //SearchViewModel(this._bufferController);

  List<Word> _filteredItems = [];
  String _query = "";

  // 検索クエリの取得と更新
  String get query => _query;
  set query(String value) {
    _query = value;
    //_fireController();
    notifyListeners();
  }

  List<Word> get filteredItems => _filteredItems;
  set filteredItems(List<Word> value) {
    _filteredItems = value;
    notifyListeners();
  }

  /* Future<void> _fireController() async {
    if (_query.isEmpty) {
      _filteredItems = [];
      //_filteredItems = await wordRepository.getWordsByWord(_query);
    } else {
      _bufferController.searchWord(_query);
    }
    //notifyListeners();
  } */
}
