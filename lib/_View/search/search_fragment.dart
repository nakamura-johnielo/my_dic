import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/Components/auto_focus_text_field.dart';
import 'package:my_dic/Components/searhCard/conjugacion_search_card.dart';
import 'package:my_dic/Components/searhCard/jpn_esp_searh_card.dart';
import 'package:my_dic/Components/searhCard/search_card.dart';
import 'package:my_dic/Constants/Enums/part_of_speech.dart';
import 'package:my_dic/Constants/tab.dart';
import 'package:my_dic/DI/product.dart';
import 'package:my_dic/_Interface_Adapter/Controller/buffer_controller.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/search_view_model.dart';
import 'package:my_dic/_View/search/infinity_scroll_view/infinity_scroll_view.dart';
import 'package:my_dic/_View/word_page/jpn_esp/jpn_esp_word_page_fragment.dart';
import 'package:my_dic/_View/word_page/word_page_fragment.dart';

class MyTextField extends ConsumerWidget {
  const MyTextField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(searchViewModelProvider);
    log("1-1 txtfield in build");
    return TextField(
      autofocus: true,
      decoration: InputDecoration(
        labelText: 'Search',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          viewModel.query = value;
        });
        //viewModel.query = value;
        //_bufferController.searchWord(value);
      },
    );
  }
}

class SearchFragment extends ConsumerWidget {
  const SearchFragment({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BufferController bufferController =
        ref.read(bufferControllerProvider);

    final viewModel = ref.watch(searchViewModelProvider);
    log("0 Fragment in build");

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
                //SchedulerBinding.instance.addPostFrameCallback((_) {
                viewModel.query = value;
                //});
                //viewModel.query = value;
                //_bufferController.searchWord(value);
              },
            ),
          ),
          /* Expanded(
            child: SearchInfinityListView(
                size: 30,
                itemCount: viewModel.filteredJpnEspItems.length,
                itemBuilder: (context, index) {
                  return JpnEspSearchCard(
                    word: viewModel.filteredJpnEspItems[index].word,
                    onTap: () {
                      context.push(
                          '/${ScreenTab.search}/${ScreenPage.jpnEspDetail}',
                          extra: JpnEspWordPageFragmentInput(
                              wordId: viewModel.filteredJpnEspItems[index].id));
                    },
                  );
                },
                loadNext: _bufferController.searchWord,
                query: viewModel.query),
          ), */

/*           Expanded(
              child: SearchInfinityListView(
                  size: 30,
                  itemCount: viewModel.filteredConjugacionItems.length +
                      viewModel.filteredItems.length,
                  itemBuilder: (context, index) {
                    //先にconj
                    if (index < viewModel.filteredConjugacionItems.length) {
                      return ConjugacionSearchCard(
                        word: viewModel.filteredConjugacionItems[index].word,
                        conjugacions:
                            viewModel.filteredConjugacionItems[index].matches,
                        query: viewModel.query,
                        //meaning: viewModel.filteredItems[index].meaning,
                        onTap: () {
                          context.push(
                              '/${ScreenTab.search}/${ScreenPage.detail}',
                              extra: WordPageFragmentInput(
                                  wordId: viewModel
                                      .filteredConjugacionItems[index].wordId,
                                  isVerb: true));
                        },
                      );
                    }
                    index = index - viewModel.filteredConjugacionItems.length;
                    return SearchCard(
                      word: viewModel.filteredItems[index].word,
                      //meaning: viewModel.filteredItems[index].meaning,
                      partOfSpeech: viewModel.filteredItems[index].partOfSpeech,
                      onTap: () {
                        context.push(
                            '/${ScreenTab.search}/${ScreenPage.detail}',
                            extra: WordPageFragmentInput(
                                wordId: viewModel.filteredItems[index].wordId,
                                isVerb:
                                    viewModel.filteredItems[index].hasVerb()));
                      },
                    );
                  },
                  loadNext: _bufferController.searchWord,
                  query: viewModel.query)) */

          Expanded(
              child: viewModel.filteredJpnEspItems.isNotEmpty
                  ? SearchInfinityListView(
                      size: 30,
                      itemCount: viewModel.filteredJpnEspItems.length,
                      itemBuilder: (context, index) {
                        return JpnEspSearchCard(
                          word: viewModel.filteredJpnEspItems[index].word,
                          onTap: () {
                            context.push(
                                '/${ScreenTab.search}/${ScreenPage.jpnEspDetail}',
                                extra: JpnEspWordPageFragmentInput(
                                    wordId: viewModel
                                        .filteredJpnEspItems[index].id));
                          },
                        );
                      },
                      loadNext: bufferController.searchWord,
                      query: viewModel.query)
                  : SearchInfinityListView(
                      size: 30,
                      itemCount: viewModel.filteredConjugacionItems.length +
                          viewModel.filteredItems.length,
                      itemBuilder: (context, index) {
                        //先にconj
                        if (index < viewModel.filteredConjugacionItems.length) {
                          return ConjugacionSearchCard(
                            word:
                                viewModel.filteredConjugacionItems[index].word,
                            conjugacions: viewModel
                                .filteredConjugacionItems[index].matches,
                            query: viewModel.query,
                            //meaning: viewModel.filteredItems[index].meaning,
                            onTap: () {
                              context.push(
                                  '/${ScreenTab.search}/${ScreenPage.detail}',
                                  extra: WordPageFragmentInput(
                                      wordId: viewModel
                                          .filteredConjugacionItems[index]
                                          .wordId,
                                      isVerb: true));
                            },
                          );
                        }
                        index =
                            index - viewModel.filteredConjugacionItems.length;
                        return SearchCard(
                          word: viewModel.filteredItems[index].word,
                          //meaning: viewModel.filteredItems[index].meaning,
                          partOfSpeech:
                              viewModel.filteredItems[index].partOfSpeech,
                          onTap: () {
                            context.push(
                                '/${ScreenTab.search}/${ScreenPage.detail}',
                                extra: WordPageFragmentInput(
                                    wordId:
                                        viewModel.filteredItems[index].wordId,
                                    isVerb: viewModel.filteredItems[index]
                                        .hasVerb()));
                          },
                        );
                      },
                      loadNext: bufferController.searchWord,
                      query: viewModel.query)),
        ],
      ),
    );
  }
}
