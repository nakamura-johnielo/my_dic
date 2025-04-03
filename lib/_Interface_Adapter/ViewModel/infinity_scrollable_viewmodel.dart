import 'package:flutter/foundation.dart';

abstract class InfinityScrollableViewModel<T> extends ChangeNotifier {
  //bool hasNext = true; // 必須のプロパティ
  //bool isNextLoading = false; // 状態管理プロパティ（初期値を提供）

  List<int> currentPage = [-1, -1];
  final int size = 100;

  List<T> _items = [];
  List<T> get items => _items;
  set items(List<T> value) {
    _items = value;
    notifyListeners();
  }

  bool _hasNext = true;
  bool get hasNext => _hasNext;
  set hasNext(bool value) {
    _hasNext = value;
    notifyListeners();
  }

  bool _hasPrevious = false;
  bool get hasPrevious => _hasPrevious;
  set hasPrevious(bool value) {
    _hasPrevious = value;
    notifyListeners();
  }

  bool _isNextLoading = false;
  bool get isNextLoading => _isNextLoading;
  set isNextLoading(bool value) {
    _isNextLoading = value;
    //notifyListeners();
  }

  bool _isPreLoading = false;
  bool get isPreLoading => _isPreLoading;
  set isPreLoading(bool value) {
    _isPreLoading = value;
    //notifyListeners();
  }
}
