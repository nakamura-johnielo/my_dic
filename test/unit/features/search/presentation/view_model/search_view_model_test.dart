import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/enums/dictionary/dictionary_type.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/search/application/query/search_direction.dart';
import 'package:my_dic/features/search/application/query/search_query.dart';
import 'package:my_dic/features/search/application/query/search_result_item.dart';
import 'package:my_dic/features/search/application/query/search_result_page.dart';
import 'package:my_dic/features/search/application/usecase/search_word/i_search_word_use_case.dart';
import 'package:my_dic/features/search/domain/usecase/judge_search_word/i_judge_search_word_use_case.dart';
import 'package:my_dic/features/search/domain/usecase/judge_search_word/judge_search_word_input_data.dart';
import 'package:my_dic/features/search/domain/usecase/judge_search_word/judge_search_word_output_data.dart';
import 'package:my_dic/features/search/presentation/view_model/viewmodel.dart';

void main() {
  group('SearchViewModel pagination', () {
    late _SearchWordUseCaseFake search;
    late SearchViewModel viewModel;

    setUp(() {
      search = _SearchWordUseCaseFake();
      viewModel = SearchViewModel(search, _JudgeSearchWordUseCaseFake());
      viewModel.updateQuery('ser');
    });

    tearDown(() => viewModel.dispose());

    test('requests page 0 first, then page 1, and appends the results',
        () async {
      search.responses.addAll([
        Result.success(_page('first', hasNext: true)),
        Result.success(_page('second', hasNext: false)),
      ]);

      final firstHasNext = await viewModel.loadSearchResults(30, 0);
      final secondHasNext = await viewModel.loadSearchResults(30, 1);

      expect(search.queries.map((query) => query.page), [0, 1]);
      expect(firstHasNext, isTrue);
      expect(secondHasNext, isFalse);
      expect(
        viewModel.state.results.dataOrNull?.items.map((item) => item.headword),
        ['first', 'second'],
      );
    });

    test('returns false when the final page has no next page', () async {
      search.responses.add(Result.success(_page('only', hasNext: false)));

      final hasNext = await viewModel.loadSearchResults(30, 0);

      expect(hasNext, isFalse);
      expect(viewModel.state.results.dataOrNull?.hasNext, isFalse);
      expect(search.queries, hasLength(1));
    });

    test('retrying an initial failure requests page 0 again', () async {
      search.responses.addAll([
        Result.failure(DatabaseError(message: 'temporary failure')),
        Result.success(_page('recovered', hasNext: false)),
      ]);

      final failed = await viewModel.loadSearchResults(30, 0);
      final recovered = await viewModel.loadSearchResults(30, 0);

      expect(failed, isFalse);
      expect(recovered, isFalse);
      expect(search.queries.map((query) => query.page), [0, 0]);
      expect(viewModel.state.results.dataOrNull?.items.single.headword,
          'recovered');
    });
  });
}

SearchResultPage _page(String word, {required bool hasNext}) =>
    SearchResultPage(
      items: [
        SearchResultItem(
          wordId: 1,
          headword: word,
          direction: SearchDirection.espJpn,
          hasConjugation: false,
          meaningText: null,
          rankingNo: null,
          starCount: null,
        ),
      ],
      conjugationSuggestions: const [],
      hasNext: hasNext,
      issues: const [],
    );

class _SearchWordUseCaseFake implements ISearchWordUseCase {
  final queries = <SearchQuery>[];
  final responses = <Result<SearchResultPage>>[];

  @override
  Future<Result<SearchResultPage>> execute(SearchQuery query) async {
    queries.add(query);
    return responses.removeAt(0);
  }
}

class _JudgeSearchWordUseCaseFake implements IJudgeSearchWordUseCase {
  @override
  Result<JudgeSearchWordOutputData> execute(JudgeSearchWordInputData input) =>
      Result.success(JudgeSearchWordOutputData(DictionaryType.espJpn));
}
