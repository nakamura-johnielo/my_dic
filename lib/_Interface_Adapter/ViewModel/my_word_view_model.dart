import 'package:flutter/material.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/my_word.dart';

/// ViewModelをプロバイダーで提供
// final myWordViewModelProvider =
//     ChangeNotifierProvider((ref) => DI<MyWordViewModel>());

class MyWordViewModel
    extends ChangeNotifier /* extends InfinityScrollableViewModel<MyWord> */ {
  List<MyWord> _items = [];
  List<MyWord> get items => _items;
  set items(List<MyWord> value) {
    _items = value;
    notifyListeners();
  }

  void updateAllWordStatus({
    required wordId,
    required bool isBookmarked,
    required bool isLearned, //required bool hasNote
  }) {
    _items = [
      for (int i = 0; i < _items.length; i++)
        if (_items[i].wordId == wordId)
          _items[i].copyWith(
            //rankedWord: "${_items[i].rankedWord} U",
            isBookmarked: isBookmarked,
            isLearned: isLearned, //hasNote: hasNote,
          )
        else
          _items[i]
    ];
    notifyListeners();
    //log("${_items[wordId].rankedWord} Bookmark: ${_items[wordId].isBookmarked},learn: ${_items[wordId].isLearned}");
  }

  void addItemsInHead(List<MyWord> l) {
    _items = [...l, ..._items];
    //itemが正常に追加されてからpage数更新
    //初期化時は-1
    notifyListeners();
  }

  void addItemInHead(MyWord value) {
    _items.insert(0, value);
    notifyListeners();
  }

  void replaceItem(MyWord value, int index) {
    _items[index] = value;
    notifyListeners();
  }

  void deleteItemWithIndex(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void inicializeTest() {
    items = [
      MyWord(wordId: 1, word: 'word1', contents: 'contents1'),
      MyWord(wordId: 2, word: 'word2', contents: 'contents2'),
      MyWord(wordId: 3, word: 'word3', contents: 'contents3'),
      MyWord(wordId: 4, word: 'word4', contents: 'contents4'),
      MyWord(wordId: 5, word: 'word5', contents: 'contents5'),
      MyWord(wordId: 6, word: 'word6', contents: 'contents6'),
      MyWord(wordId: 7, word: 'word7', contents: 'contents7'),
      MyWord(wordId: 8, word: 'word8', contents: 'contents8'),
      MyWord(wordId: 9, word: 'word9', contents: 'contents9'),
      MyWord(wordId: 10, word: 'word10', contents: 'contents10'),
      MyWord(wordId: 11, word: 'word11', contents: 'contents11'),
      MyWord(wordId: 12, word: 'word12', contents: 'contents12'),
      MyWord(wordId: 13, word: 'word13', contents: 'contents13'),
      MyWord(wordId: 14, word: 'word14', contents: 'contents14'),
      MyWord(wordId: 15, word: 'word15', contents: 'contents15'),
      MyWord(wordId: 16, word: 'word16', contents: 'contents16'),
      MyWord(wordId: 17, word: 'word17', contents: 'contents17'),
      MyWord(wordId: 18, word: 'word18', contents: 'contents18'),
      MyWord(wordId: 19, word: 'word19', contents: 'contents19'),
      MyWord(wordId: 20, word: 'word20', contents: 'contents20'),
      MyWord(wordId: 21, word: 'word21', contents: 'contents21'),
      MyWord(wordId: 22, word: 'word22', contents: 'contents22'),
      MyWord(wordId: 23, word: 'word23', contents: 'contents23'),
    ];
  }
}
