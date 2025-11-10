import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_dic/Components/auto_focus_text_field.dart';
import 'package:my_dic/Components/quiz_card.dart';
import 'package:my_dic/Components/searhCard/quiz_search_card.dart';
import 'package:my_dic/Constants/Enums/cardState.dart';
import 'package:my_dic/Constants/tab.dart';
import 'package:my_dic/DI/product.dart';
import 'package:my_dic/_Interface_Adapter/Controller/buffer_controller.dart';
import 'package:my_dic/_Interface_Adapter/Controller/quiz_controller.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/quiz/data.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/quiz/quiz_ui.dart';
import 'package:my_dic/_View/quiz/quiz_game_fragment.dart';
import 'package:my_dic/_View/search/infinity_scroll_view/infinity_scroll_view.dart';

class QuizFragment extends ConsumerWidget {
  const QuizFragment({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(quizSearchQueryProvider);
    final items = ref.watch(quizSearchedItemsProvider);
    //final selectedId = ref.watch(quizSelectedWordIdProvider);
    final bufferController = DI<BufferController>();
    return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz'),
        ),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: AutoFocusTextField(
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                //SchedulerBinding.instance.addPostFrameCallback((_) {
                ref.read(quizSearchQueryProvider.notifier).state = value;
                //});
                //viewModel.query = value;
                //_bufferController.searchWord(value);
              },
            ),
          ),
          Expanded(
            child: SearchInfinityListView(
                size: 30,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return QuizSearchCard(
                    word: items[index].word,
                    meaning: items[index].simpleMeaning,
                    //meaning: viewModel.filteredItems[index].meaning,
                    onTap: () {
                      final int id = items[index].wordId;

                      // if (ref.watch(quizStateProvider).wordId != id &&
                      //     ref.watch(quizStateProvider).wordId != 0) {
                      ref.read(quizStateProvider.notifier).init();
                      ref.read(quizCardStateProvider.notifier).state =
                          QuizCardState.question;

                      ref.read(quizWordProvider.notifier).state =
                          items[index].word;
                      // }
                      context.push(
                          '/${ScreenTab.quiz}/${ScreenPage.quizDetail}',
                          extra: QuizGameFragmentInput(
                              wordId: id, word: items[index].word));

                      //ref.read(quizSelectedWordIdProvider.notifier).state = id;

                      /// ser をデフォルト
                    },
                  );
                },
                loadNext: (query, size, page) async {
                  final results =
                      await bufferController.searchVerbs(query, size, page);
                  // Providerを更新
                  ref.read(quizSearchedItemsProvider.notifier).state = results;
                },
                query: query),
          )
        ]));
  }
}
