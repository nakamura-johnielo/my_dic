import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word.dart';

// class MyWordStateOld {
//   final List<MyWord> myWords;
//   MyWordStateOld({this.myWords=const[]});

//   MyWordStateOld copyWith({List<MyWord>? myWords}) {
//     return MyWordStateOld(myWords: myWords ?? this.myWords);
//   }
// }

class MyWordUiState {
  // final MyWord myWords;
  final int wordId;
  final String word;
  final String contents;
  final DateTime editAt;
  //MyWordState({this.myWords }):super(MyWord(wordId:0,word:'',contents:''));

  MyWordUiState({
    required this.wordId,
    required this.word,
    required this.contents,
    required this.editAt,
  });

  MyWordUiState copyWith({
    int? wordId,
    String? word,
    String? contents,
    DateTime? editAt,
  }) {
    return MyWordUiState(
      wordId: wordId ?? this.wordId,
      word: word ?? this.word,
      contents: contents ?? this.contents,
      editAt: editAt ?? this.editAt,
    );
  }

  factory MyWordUiState.fromMyWord(MyWord myWord) {
    return MyWordUiState(
      wordId: myWord.wordId,
      word: myWord.word,
      contents: myWord.contents,
      editAt: myWord.editAt,
    );
  }

  factory MyWordUiState.fromAsync(AsyncValue<MyWord> async) {
    return async.when(
      data: (myWord) => MyWordUiState.fromMyWord(myWord),
      loading: () => MyWordUiState(
        wordId: -1,
        word: 'loading',
        contents: 'loading',
        editAt: DateTime.now(),
      ),
      error: (error, stack) => MyWordUiState(
        wordId: -1,
        word: 'error',
        contents: 'error',
        editAt: DateTime.now(),
      ),
    );
  }

}

class MyWordFragmentState {
  final List<int> myWordIds;
  MyWordFragmentState({this.myWordIds=const[]});

  MyWordFragmentState copyWith({List<int>? myWordIds}) {
    return MyWordFragmentState(myWordIds: myWordIds ?? this.myWordIds);
  }
}
