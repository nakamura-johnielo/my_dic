import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/features/my_word/port/result.dart';

/// カードまたはモーダル用の読み取り専用プレゼンテーションデータ。
class MyWordItemUiModel {
  const MyWordItemUiModel({
    required this.wordId,
    required this.word,
    required this.contents,
    required this.editAt,
    required this.isLearned,
    required this.isBookmarked,
  });

  factory MyWordItemUiModel.fromItem(MyWordItem projection) =>
      MyWordItemUiModel(
        wordId: projection.word.wordId,
        word: projection.word.headword,
        contents: projection.word.description,
        editAt: projection.word.updatedAt,
        isLearned: projection.status.isLearned,
        isBookmarked: projection.status.isBookmarked,
      );

  final String wordId;
  final String word;
  final String contents;
  final DateTime editAt;
  final bool isLearned;
  final bool isBookmarked;
}

class MyWordUiState {
  final String wordId;
  final String word;
  final String contents;
  final DateTime editAt;

  MyWordUiState(
      {required this.wordId,
      required this.word,
      required this.contents,
      required this.editAt});

  MyWordUiState copyWith(
          {String? wordId, String? word, String? contents, DateTime? editAt}) =>
      MyWordUiState(
          wordId: wordId ?? this.wordId,
          word: word ?? this.word,
          contents: contents ?? this.contents,
          editAt: editAt ?? this.editAt);

  factory MyWordUiState.fromMyWord(MyWord myWord) => MyWordUiState(
      wordId: myWord.wordId,
      word: myWord.headword,
      contents: myWord.description,
      editAt: myWord.updatedAt);

  factory MyWordUiState.fromAsync(AsyncValue<MyWord> async) => async.when(
        data: MyWordUiState.fromMyWord,
        loading: () => MyWordUiState(
            wordId: '',
            word: 'loading',
            contents: 'loading',
            editAt: DateTime.now()),
        error: (_, __) => MyWordUiState(
            wordId: '',
            word: 'error',
            contents: 'error',
            editAt: DateTime.now()),
      );
}

class MyWordListResults {
  const MyWordListResults(this.ids);
  final List<String> ids;
  MyWordListResults append(Iterable<String> next) {
    final seen = <String>{...ids};
    return MyWordListResults([...ids, ...next.where(seen.add)]);
  }
}

/// ページネーションメタデータはリストクエリのライフサイクルから独立している。
class MyWordFragmentState {
  const MyWordFragmentState({
    this.words = const QueryState.initial(),
    this.currentPage = -1,
    this.hasNext = true,
  });

  final QueryState<MyWordListResults> words;
  final int currentPage;
  final bool hasNext;

  List<String> get myWordIds => words.dataOrNull?.ids ?? const [];

  MyWordFragmentState copyWith({
    QueryState<MyWordListResults>? words,
    int? currentPage,
    bool? hasNext,
  }) =>
      MyWordFragmentState(
        words: words ?? this.words,
        currentPage: currentPage ?? this.currentPage,
        hasNext: hasNext ?? this.hasNext,
      );
}
