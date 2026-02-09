import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word.dart';

class MyWordUiState {
  final String wordId;
  final String word;
  final String contents;
  final DateTime editAt;

  MyWordUiState({
    required this.wordId,
    required this.word,
    required this.contents,
    required this.editAt,
  });

  MyWordUiState copyWith({
    String? wordId,
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
        wordId: '',
        word: 'loading',
        contents: 'loading',
        editAt: DateTime.now(),
      ),
      error: (error, stack) => MyWordUiState(
        wordId: '',
        word: 'error',
        contents: 'error',
        editAt: DateTime.now(),
      ),
    );
  }
}

class MyWordFragmentState {
  final List<String> myWordIds;
  MyWordFragmentState({this.myWordIds = const []});

  MyWordFragmentState copyWith({List<String>? myWordIds}) {
    return MyWordFragmentState(myWordIds: myWordIds ?? this.myWordIds);
  }
}
