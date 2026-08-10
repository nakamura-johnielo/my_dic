import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/features/my_word/internal/application/query/my_word_item_projection.dart';
import 'package:my_dic/features/my_word/internal/domain/entity/my_word.dart';

/// Read-only presentation data for a card or modal.
class MyWordItemUiModel {
  const MyWordItemUiModel({
    required this.wordId,
    required this.word,
    required this.contents,
    required this.editAt,
    required this.isLearned,
    required this.isBookmarked,
  });

  factory MyWordItemUiModel.fromProjection(MyWordItemProjection projection) =>
      MyWordItemUiModel(
        wordId: projection.word.wordId,
        word: projection.word.word,
        contents: projection.word.contents,
        editAt: projection.word.editAt,
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
      word: myWord.word,
      contents: myWord.contents,
      editAt: myWord.editAt);

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
  MyWordListResults append(Iterable<String> next) =>
      MyWordListResults([...ids, ...next]);
}

/// Pagination metadata is independent from the list query lifecycle.
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
