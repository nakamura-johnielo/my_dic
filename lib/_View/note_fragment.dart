import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/Components/searhCard/search_card.dart';
import 'package:my_dic/Components/simple_infinity_list_view.dart';
import 'package:my_dic/DI/product.dart';
import 'package:my_dic/core/domain/i_repository/i_jpn_esp_word_repository.dart';
import 'package:my_dic/core/infrastructure/repository/drift_jpn_esp_word_repository.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/note_view_model.dart';

class NoteFragment extends ConsumerWidget {
  const NoteFragment({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final viewModel = ref.watch(noteViewModelProvider);
    // final IJpnEspWordRepository repo = DI<IJpnEspWordRepository>();
    // Future<bool> loadNext(int size, int page) async {
    //   await repo.getWordsByWord("あ", size, page);
    //   return true;
    // }

    return Scaffold(
      appBar: AppBar(
        title: Text('Note'),
      ),
      body: Column(children: [
        Text('This is note screen'),
        // Expanded(
        //     child: SimpleInfinityListView(
        //         size: 50,
        //         itemCount: viewModel.items.length,
        //         itemBuilder: (context, index) {
        //           return SearchCard(
        //             word: viewModel.items[index].word,
        //             //meaning: viewModel.filteredItems[index].meaning,
        //             partOfSpeech: [],
        //             onTap: () {
        //               /* context.push('/${ScreenTab.search}/${ScreenPage.detail}',
        //                   extra: WordPageFragmentInput(
        //                       wordId: viewModel.filteredItems[index].wordId,
        //                       isVerb:
        //                           viewModel.filteredItems[index].hasVerb())); */
        //             },
        //           );
        //         },
        //         loadNext: loadNext))
      ]),
    );
  }
}
