import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/presentation/components/auto_focus_text_field.dart';
import 'package:my_dic/core/presentation/components/infinityscroll.dart';
import 'package:my_dic/core/presentation/error/app_error_message.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/features/catalog/port/catalog.dart' show CatalogWordRef;
import 'package:my_dic/features/search/internal/application/search_suggestion_policy.dart';
import 'package:my_dic/features/search/internal/presentation/provider/view_model_di.dart';
import 'package:my_dic/features/search/internal/presentation/components/search_result_card.dart';
import 'package:my_dic/features/search/internal/presentation/ui_model/search_ui_model.dart';
import 'package:my_dic/features/search/internal/presentation/view_model/viewmodel.dart';
import 'package:my_dic/features/search/port/search.dart';

class SearchFragment extends ConsumerStatefulWidget {
  const SearchFragment({
    super.key,
    required this.reader,
    required this.onOpenWordDetail,
    required this.onOpenQuiz,
    required this.wordStatusRenderer,
  });

  final SearchQueryPort reader;
  final ValueChanged<CatalogWordRef> onOpenWordDetail;
  final void Function(CatalogWordRef word, String? displayHint) onOpenQuiz;
  final Widget Function(CatalogWordRef word) wordStatusRenderer;
  @override
  ConsumerState<SearchFragment> createState() => _SearchFragmentState();
}

class _SearchFragmentState extends ConsumerState<SearchFragment> {
  static const _size = 30;
  static const _conjCount = SearchSuggestionPolicy.displayLimit;
  late final InfinityScrollController _scroll;
  @override
  void initState() {
    super.initState();
    _scroll = InfinityScrollController();
  }

  Future<bool> _load(int nextPage) async {
    return ref
        .read(searchViewModelProviderFor(widget.reader).notifier)
        .loadSearchResults(_size, nextPage);
  }

  void _toWordDetail(CatalogWordRef word) => widget.onOpenWordDetail(word);

  void _toQuiz(CatalogWordRef word, String? displayHint) =>
      widget.onOpenQuiz(word, displayHint);
  @override
  Widget build(BuildContext context) {
    final screen = ref.watch(searchViewModelProviderFor(widget.reader));
    final notifier =
        ref.read(searchViewModelProviderFor(widget.reader).notifier);
    return Scaffold(
        appBar: AppBar(title: const Text('search')),
        body: Column(children: [
          Padding(
              padding: const EdgeInsets.all(8),
              child: AutoFocusTextField(
                  decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: const Icon(Icons.search, size: 16),
                      ),
                      hintText: 'Search',
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(160),
                          borderSide:
                              BorderSide(color: Colors.white.withAlpha(125))),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        // borderSide:
                        //     BorderSide(color: Colors.red.withAlpha(180))
                      )),
                  onChanged: (text) {
                    notifier.updateQuery(text);
                    _scroll.reset();
                    if (text.trim().isNotEmpty) {
                      _load(0);
                    }
                  })),
          Expanded(child: _content(screen, notifier))
        ]));
  }

  Widget _content(SearchState screen, SearchViewModel notifier) =>
      switch (screen.results) {
        QueryInitial() => const Center(child: Text('Enter a search term.')),
        QueryLoading(previousData: null) =>
          const Center(child: CircularProgressIndicator()),
        QueryEmpty() => _empty(screen, notifier),
        QueryFailure(previousData: null, error: final error) => Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(AppErrorMessage.from(error).text),
            TextButton(
                onPressed: notifier.retryFailed, child: const Text('Retry'))
          ])),
        QueryData(value: final data) ||
        QueryLoading(previousData: final data?) ||
        QueryFailure(previousData: final data?, error: _) =>
          _withFeedback(screen, _list(screen.query, data, notifier)),
      };

  Widget _empty(SearchState screen, SearchViewModel notifier) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final warning in screen.results.warnings)
            _warning(warning, onRetry: () => _reload(notifier, screen.query)),
          const Text('No matching words found.'),
        ],
      );

  Widget _withFeedback(SearchState screen, Widget list) => Column(
        children: [
          for (final warning in screen.results.warnings)
            _warning(warning,
                onRetry: () => _reload(
                    ref.read(
                        searchViewModelProviderFor(widget.reader).notifier),
                    screen.query)),
          if (screen.results
              case QueryFailure(error: final error, previousData: final _?))
            MaterialBanner(
              content: Text(AppErrorMessage.from(error).text),
              actions: [
                TextButton(
                  onPressed: _scroll.retryCurrentPage,
                  child: const Text('Retry'),
                ),
              ],
            ),
          Expanded(child: list),
        ],
      );

  Widget _warning(QueryWarning warning, {required VoidCallback onRetry}) =>
      MaterialBanner(
        content: Text(AppErrorMessage.from(warning.error).text),
        actions: [TextButton(onPressed: onRetry, child: const Text('Retry'))],
      );

  void _reload(SearchViewModel notifier, String query) {
    notifier.updateQuery(query);
    _scroll.reset();
    _load(0);
  }

  Widget _list(String query, SearchResults data, SearchViewModel notifier) {
    if (data.direction == SearchDirection.jpnEsp) {
      return InfinityScrollListView(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          // The first page is loaded explicitly when the query changes.
          initialPage: 1,
          initialHasMore: data.hasNext,
          controller: _scroll,
          itemCount: data.items.length,
          itemBuilder: (context, index) {
            final word = data.items[index];
            return Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: SearchResultCard(
                    query: query,
                    wordId: word.word.wordId,
                    showRanking: false,
                    word: word.headword,
                    meaning: word.meaningText ?? '',
                    status: widget.wordStatusRenderer(word.word),
                    onTap: () => _toWordDetail(word.word)));
          },
          onLoadMore: _load);
    }
    final conjunctions =
        data.conjugationSuggestions.take(_conjCount).toList(growable: false);
    return InfinityScrollListView(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        // The first page is loaded explicitly when the query changes.
        initialPage: 1,
        initialHasMore: data.hasNext,
        controller: _scroll,
        itemCount: conjunctions.length + data.items.length,
        itemBuilder: (context, index) {
          if (index < conjunctions.length) {
            return _conjugationCard(query, conjunctions[index]);
          }
          return _espCard(query, data.items[index - conjunctions.length]);
        },
        onLoadMore: _load);
  }

  Widget _espCard(String query, SearchResultItem item) => Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: SearchResultCard(
          status: widget.wordStatusRenderer(item.word),
          onQuizTap: item.hasConjugation
              ? () => _toQuiz(item.word, item.headword)
              : null,
          query: query,
          wordId: item.word.wordId,
          ranking: item.rankingNo,
          showRanking: true,
          word: item.headword,
          meaning: item.meaningText ?? '',
          onTap: () => _toWordDetail(item.word)));

  Widget _conjugationCard(
    String query,
    SearchConjugationSuggestion item,
  ) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 11),
        child: SearchResultCard(
          status: widget.wordStatusRenderer(item.word),
          onQuizTap: () => _toQuiz(item.word, item.headword),
          query: query,
          wordId: item.word.wordId,
          ranking: item.rankingNo,
          showRanking: true,
          word: item.headword,
          conjugations: item.matches,
          meaning: item.meaningText ?? '',
          onTap: () => _toWordDetail(item.word),
        ),
      );
}
