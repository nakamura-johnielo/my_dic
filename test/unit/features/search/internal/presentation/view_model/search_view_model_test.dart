import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/search/internal/presentation/view_model/viewmodel.dart';
import 'package:my_dic/features/search/internal/presentation/ui_model/search_ui_model.dart';
import 'package:my_dic/features/search/port/search.dart';

void main() {
  group('SearchViewModel pagination', () {
    late _SearchWordUseCaseFake search;
    late SearchViewModel viewModel;
    var disposed = false;

    setUp(() {
      search = _SearchWordUseCaseFake();
      viewModel = SearchViewModel(search);
      disposed = false;
      viewModel.updateQuery('ser');
    });

    tearDown(() {
      if (!disposed) viewModel.dispose();
    });

    test('requests page 0 first, then page 1, and appends the results',
        () async {
      search.responses.addAll([
        Result.success(_page('first', hasNext: true)),
        Result.success(_page('second', hasNext: false, wordId: 2)),
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
        const Result.failure(SearchDataUnavailableError()),
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

    test('a completion for an old query cannot replace the new query loading',
        () async {
      final old = search.defer();
      final oldLoad = viewModel.loadSearchResults(30, 0);
      viewModel.updateQuery('nuevo');
      final current = search.defer();
      final currentLoad = viewModel.loadSearchResults(30, 0);

      old.complete(Result.success(_page('old', hasNext: false)));
      await oldLoad;
      expect(viewModel.state.query, 'nuevo');
      expect(viewModel.state.results, isA<QueryLoading<SearchResults>>());

      current.complete(Result.success(_page('new', hasNext: false)));
      await currentLoad;
      expect(viewModel.state.results.dataOrNull!.items.single.headword, 'new');
    });

    test('dedupes an in-flight request for the same page', () async {
      final response = search.defer();

      final first = viewModel.loadSearchResults(30, 0);
      final duplicate = viewModel.loadSearchResults(30, 0);

      expect(search.queries, hasLength(1));
      response.complete(Result.success(_page('one', hasNext: false)));
      expect(await first, isFalse);
      expect(await duplicate, isFalse);
    });

    test('does not start page 1 while page 0 is active in the same generation',
        () async {
      final response = search.defer();

      final first = viewModel.loadSearchResults(30, 0);
      expect(await viewModel.loadSearchResults(30, 1), isFalse);
      expect(search.queries.map((query) => query.page), [0]);

      response.complete(Result.success(_page('one', hasNext: true)));
      expect(await first, isTrue);
    });

    test('retries the failed page rather than advancing pagination', () async {
      search.responses.addAll([
        Result.success(_page('first', hasNext: true)),
        const Result.failure(SearchDataUnavailableError()),
        Result.success(_page('second', hasNext: false, wordId: 2)),
      ]);

      await viewModel.loadSearchResults(30, 0);
      await viewModel.loadSearchResults(30, 1);
      await viewModel.retryFailed();

      expect(search.queries.map((query) => query.page), [0, 1, 1]);
      expect(
        viewModel.state.results.dataOrNull!.items.map((item) => item.headword),
        ['first', 'second'],
      );
    });

    test('dedupes stable word identities when appending', () async {
      search.responses.addAll([
        Result.success(_page('first', hasNext: true, wordId: 1)),
        Result.success(_page('duplicate', hasNext: false, wordId: 1)),
      ]);

      await viewModel.loadSearchResults(30, 0);
      await viewModel.loadSearchResults(30, 1);

      expect(viewModel.state.results.dataOrNull!.items, hasLength(1));
      expect(
          viewModel.state.results.dataOrNull!.items.single.headword, 'first');
    });

    test('publishes supplemental issues as warnings with successful data',
        () async {
      search.responses.add(Result.success(SearchResultPage(
        direction: SearchDirection.espJpn,
        items: _page('first', hasNext: false).items,
        conjugationSuggestions: const [],
        hasNext: false,
        issues: [
          const SearchIssue(
            source: SearchIssueSource.conjugation,
            error: SearchEnrichmentUnavailableError(
              message: 'supplement unavailable',
            ),
          ),
        ],
      )));

      await viewModel.loadSearchResults(30, 0);

      expect(viewModel.state.results, isA<QueryData<SearchResults>>());
      expect(viewModel.state.results.warnings.single.source, 'conjugation');
    });

    test('does not publish when disposed before a request completes', () async {
      final response = search.defer();
      final load = viewModel.loadSearchResults(30, 0);
      viewModel.dispose();
      disposed = true;

      response.complete(Result.success(_page('late', hasNext: false)));
      expect(await load, isFalse);
    });
  });

  test('Search presentation avoids legacy contracts and destination routes',
      () {
    final sources = Directory('lib/features/search/internal/presentation')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .map((file) => file.readAsStringSync())
        .join('\n');

    final searchPortImports = RegExp(
      r"features/search/port/([^']+)'",
    ).allMatches(sources).map((match) => match.group(1));
    expect(
      searchPortImports,
      everyElement(anyOf('search.dart', 'presentation_dependencies.dart')),
    );

    for (final forbidden in [
      'features/word_detail/',
      'features/quiz/',
      'app/routing/',
    ]) {
      expect(sources, isNot(contains(forbidden)), reason: forbidden);
    }
  });
}

SearchResultPage _page(String word, {required bool hasNext, int wordId = 1}) =>
    SearchResultPage(
      direction: SearchDirection.espJpn,
      items: [
        SearchResultItem(
          word: CatalogWordRef(
            catalogId: CatalogId.espJpnMain,
            wordId: wordId,
          ),
          headword: word,
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

class _SearchWordUseCaseFake implements SearchReaderPort {
  final queries = <SearchQuery>[];
  final responses = <Result<SearchResultPage>>[];
  final deferred = <Completer<Result<SearchResultPage>>>[];

  Completer<Result<SearchResultPage>> defer() {
    final value = Completer<Result<SearchResultPage>>();
    deferred.add(value);
    return value;
  }

  @override
  Future<Result<SearchResultPage>> search(SearchQuery query) {
    queries.add(query);
    if (deferred.isNotEmpty) return deferred.removeAt(0).future;
    return Future.value(responses.removeAt(0));
  }
}
