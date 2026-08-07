import 'package:my_dic/core/shared/utils/logger.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/app/routing/route_name_resolver.dart';
import 'package:my_dic/core/di/router/router.dart';
import 'package:my_dic/core/presentation/components/auto_focus_text_field.dart';
import 'package:my_dic/features/search/presentation/components/conjugacion_search_card.dart';
import 'package:my_dic/features/search/presentation/components/jpn_esp_searh_card.dart';
import 'package:my_dic/features/search/presentation/components/search_card.dart';
import 'package:my_dic/core/shared/enums/word/word_type.dart';
import 'package:my_dic/core/presentation/components/infinityscroll.dart';
import 'package:my_dic/features/search/di/view_model_di.dart';
import 'package:my_dic/app/routing/contracts/word_detail_route.dart';

class SearchFragment extends ConsumerStatefulWidget {
  const SearchFragment({super.key});

  @override
  ConsumerState<SearchFragment> createState() => _SearchFragmentState();
}

class _SearchFragmentState extends ConsumerState<SearchFragment> {
  final int _size = 30; //searchの1ページの取得件数
  int _previousConjItemLength = 0;
  int _previousEspJpnItemLength = 0;
  int _previousJpnEspItemLength = 0;
  late final InfinityScrollController _infinityScrollController;
  final int initialPage = 0;

  @override
  void initState() {
    super.initState();
    _infinityScrollController = InfinityScrollController();
  }

  Future<bool> _loadNextPage(int nextPage) async {
    AppLogger.print("_loadNextPage: $nextPage");

    final viewModel = ref.read(searchViewModelProvider.notifier);

    _setCurrentItemLength();
    await viewModel.loadSearchResults(
      _size,
      nextPage - 1,
    );
    final canFetch = _canFetch();
    AppLogger.print("canfetch:$canFetch");
    return canFetch;
  }

  void _resetPage() {
    _infinityScrollController.reset();
    setState(() {
      _previousEspJpnItemLength = 0;
      _previousConjItemLength = 0;
      _previousJpnEspItemLength = 0;
    });
  }

  void _setCurrentItemLength() {
    final viewModel = ref.read(searchViewModelProvider);
    _previousEspJpnItemLength = viewModel.espJpnWords.length;
    _previousConjItemLength = viewModel.conjugacions.length;
    _previousJpnEspItemLength = viewModel.jpnEspWords.length;
  }

  bool _canFetch() {
    final viewModel = ref.read(searchViewModelProvider);
    final currentEspJpnItemLength = viewModel.espJpnWords.length;
    final currentConjItemLength = viewModel.conjugacions.length;
    final currentJpnEspItemLength = viewModel.jpnEspWords.length;
    AppLogger.print(
        "EspJpn current:$currentEspJpnItemLength, pre:$_previousEspJpnItemLength");
    return currentEspJpnItemLength > _previousEspJpnItemLength ||
        currentConjItemLength > _previousConjItemLength ||
        currentJpnEspItemLength > _previousJpnEspItemLength;
  }

  void _toWordDetail(WordDetailRoute route) => context.pushNamed(
        wordDetailRouteNameFor(ref.read(entryPointProvider)),
        pathParameters: route.pathParameters,
        queryParameters: route.queryParameters,
      );

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(searchViewModelProvider);
    final viewModelNotifier = ref.read(searchViewModelProvider.notifier);
    AppLogger.print("0 Fragment in build");

    return Scaffold(
      appBar: AppBar(
        title: Text('search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: AutoFocusTextField(
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                viewModelNotifier.updateQuery(value);
                viewModelNotifier.clearResults();
                _resetPage();
              },
            ),
          ),
          Expanded(
              child: viewModel.jpnEspWords.isNotEmpty
                  ? InfinityScrollListView(
                      autoLoadFirstPage: true,
                      initialPage: initialPage,
                      controller: _infinityScrollController,
                      itemCount: viewModel.jpnEspWords.length,
                      itemBuilder: (context, index) {
                        final jpnEspWord = viewModel.jpnEspWords[index];
                        return JpnEspSearchCard(
                          word: jpnEspWord.word,
                          onTap: () {
                            //TODO gorouter check
                            _toWordDetail(WordDetailRoute(
                                wordId: jpnEspWord.id,
                                wordType: WordType.jpnEsp,
                                hasConj: false));
                          },
                        );
                      },
                      onLoadMore: _loadNextPage,
                    )
                  : InfinityScrollListView(
                      autoLoadFirstPage: true,
                      initialPage: initialPage,
                      controller: _infinityScrollController,
                      itemCount: (viewModel.conjugacions.length +
                          viewModel.espJpnWords.length),
                      itemBuilder: (context, index) {
                        final conjLength = viewModel.conjugacions.length;
                        final query = viewModel.query;
                        //先にconj
                        if (index < conjLength) {
                          final conjugacion = viewModel.conjugacions[index];
                          return ConjugacionSearchCard(
                            word: conjugacion.word,
                            conjugacions: conjugacion.matches,
                            query: query,
                            onTap: () {
                              //TODO gorouter check

                              _toWordDetail(WordDetailRoute(
                                  wordId: conjugacion.wordId,
                                  wordType: WordType.espJpn,
                                  hasConj: true));
                            },
                          );
                        }
                        index = index - conjLength;
                        final espJpnWord = viewModel.espJpnWords[index];
                        return SearchCard(
                          word: espJpnWord.word,
                          partOfSpeech: espJpnWord.partOfSpeech,
                          onTap: () {
                            //TODO gorouter check
                            _toWordDetail(WordDetailRoute(
                                wordId: espJpnWord.wordId,
                                wordType: WordType.espJpn,
                                hasConj: espJpnWord.hasVerb()));
                          },
                        );
                      },
                      onLoadMore: _loadNextPage,
                    )),
        ],
      ),
    );
  }
}
