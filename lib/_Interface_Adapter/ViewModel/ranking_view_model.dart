import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/Constants/Enums/feature_tag.dart';
import 'package:my_dic/core/common/enums/word/part_of_speech.dart';
import 'package:my_dic/DI/product.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/ranking.dart';

/// ViewModelをプロバイダーで提供
// final rankingViewModelProvider =
//     ChangeNotifierProvider((ref) => DI<RankingViewModel>());

class RankingViewModel extends ChangeNotifier {
  //現在のページネーションのページ
  //itemsに入っていいる　0-最小のページ , 1-最大のページ
  List<int> currentPage = [-1, -1];
  final int size = 100; //ページごとに取得してくるデータ数
  List<Ranking> _items = [];

  //filter
  bool _isOnUpdatedFilter = false; //フィルタが更新されたかどうか
  bool get isOnUpdatedFilter => _isOnUpdatedFilter;
  set isOnUpdatedFilter(bool value) {
    _isOnUpdatedFilter = value;
    notifyListeners();
  }

  void resetIsOnUpdatedFilter() {
    _isOnUpdatedFilter = false;
    notifyListeners();
  }

  void checkUpdateFilter() async {
    _isOnUpdatedFilter = true;
    notifyListeners();
    await Future.delayed(Duration(milliseconds: 1000));
    _isOnUpdatedFilter = false;
    notifyListeners();
  }

  //0:ナシ 1:あり　-1:除外
  Map<FeatureTag, int> featureTagFilters = {}; // FeatureTag.values.toSet();
  Map<PartOfSpeech, int> partOfSpeechFilters =
      {}; // PartOfSpeech.values.toSet();

  int _pagenationFilter = 0;
  int get pagenationFilter => _pagenationFilter;
  set pagenationFilter(int page) {
    _pagenationFilter = page;
    notifyListeners();
  }

  bool _isNextLoading = false;
  bool get isNextLoading => _isNextLoading;
  set isNextLoading(bool value) {
    _isNextLoading = value;
    //notifyListeners();
  }

  bool _hasNext = true;
  bool get hasNext => _hasNext;
  set hasNext(bool value) {
    _hasNext = value;
    notifyListeners();
  }

  bool _isPreLoading = false;
  bool get isPreLoading => _isPreLoading;
  set isPreLoading(bool value) {
    _isPreLoading = value;
    //notifyListeners();
  }

  bool hasPrevious() {
    return currentPage[0] > 0;
  }

  List<Ranking> get items => _items;
  set items(List<Ranking> value) {
    _items = value;
    notifyListeners();
  }

  void clearItems() {
    items.clear();
    notifyListeners();
  }

  void resetCurrrentPage() {
    currentPage = [-1, -1];
  }

  void updateWordStatus(
      {required index,
      required bool isBookmarked,
      required bool isLearned,
      required bool hasNote}) {
    _items = [
      for (int i = 0; i < _items.length; i++)
        if (i == index)
          _items[i].copyWith(
              //rankedWord: "${_items[i].rankedWord} U",
              isBookmarked: isBookmarked,
              isLearned: isLearned,
              hasNote: hasNote)
        else
          _items[i]
    ];
    notifyListeners();
    log("${_items[index].rankedWord} Bookmark: ${_items[index].isBookmarked},learn: ${_items[index].isLearned}");
  }

  void updateAllWordStatus(
      {required wordId,
      required bool isBookmarked,
      required bool isLearned,
      required bool hasNote}) {
    _items = [
      for (int i = 0; i < _items.length; i++)
        if (_items[i].wordId == wordId)
          _items[i].copyWith(
              //rankedWord: "${_items[i].rankedWord} U",
              isBookmarked: isBookmarked,
              isLearned: isLearned,
              hasNote: hasNote)
        else
          _items[i]
    ];
    notifyListeners();
    //log("${_items[wordId].rankedWord} Bookmark: ${_items[wordId].isBookmarked},learn: ${_items[wordId].isLearned}");
  }

  void addItemsInTail(List<Ranking> l, List<int> requiredPage) {
    _items = [..._items, ...l];
    //itemが正常に追加されてからpage数更新
    //初期化時は-1
    currentPage = requiredPage;
    isNextLoading = false;
    if (l.length < size) {
      hasNext = false;
    }
    log("item length: ${_items.length} ");
    log("added: ${l.length}");
    log("currentPage: ${currentPage} ");
    log("isloadig: ${isNextLoading}");
    notifyListeners();
  }

  void addItemsInHead(List<Ranking> l, List<int> requiredPage) {
    _items = [...l, ..._items];
    //itemが正常に追加されてからpage数更新
    //初期化時は-1
    currentPage = requiredPage;
    isPreLoading = false;
    log("item length: ${_items.length} ");
    log("added: ${l.length}");
    log("currentPage: ${currentPage} ");
    log("isloadig: ${isNextLoading}");
    notifyListeners();
  }

  void setPartOfSpeechFilter(filter, int value) {
    partOfSpeechFilters[filter] = value;
    hasNext = true;
    notifyListeners();
  }

  void setFeatureTagFilter(filter, int value) {
    featureTagFilters[filter] = value;
    hasNext = true;
    notifyListeners();
  }
}
