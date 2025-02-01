import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/Constants/test.dart';
import 'package:my_dic/Constants/ui.dart';
import 'package:my_dic/DI/product.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/dictionary/esj_dictionary.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_esj_dictionary_repository.dart';
import 'package:my_dic/_Interface_Adapter/Controller/word_page_controller.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/main_view_model.dart';
import 'package:my_dic/html_style_kotobank.dart';
//import 'package:my_dic/Infrastracture/DAO/kotobank_dictionary_dao.dart';

class DictionaryFragment extends ConsumerWidget {
  final int wordId;
  const DictionaryFragment(
      {super.key, required this.wordId, required this.wordPageController});
  //final KotobankDictionaryDao _dao = KotobankDictionaryDao();
  //final DatabaseProvider db = DatabaseProvider();
  final WordPageController wordPageController;
  //=DI<IEsjDictionaryRepository>();

  //log("getwordbyid: ${result[]}");
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mainViewModel = ref.watch(mainViewModelProvider);
    if (!mainViewModel.dictionaryCache.containsKey(wordId)) {
      wordPageController.fetchDictionaryById(wordId);
      return Center(
        child: Text("Loading..."),
      );
    }
    final List<EsjDictionary>? dictionaries =
        mainViewModel.dictionaryCache[wordId]!;

    return dictionaries == null
        ? (Center(
            child: Text(
            'No data available',
            style: TextStyle(fontSize: 24),
          )))
        : (SingleChildScrollView(
            child: Container(
            margin: const EdgeInsets.only(
                top: MARGIN_TOP_SCROLLABLE_CHILD,
                bottom: MARGIN_BOTTOM_SCROLLABLE_CHILD),
            padding: const EdgeInsets.symmetric(horizontal: PADDING_X_DISPLAY),
            child: Column(
              children: [
                Text(
                  //'Word: ${data['word']}',
                  dictionaries[0].word,
                  style: TextStyle(fontSize: 24),
                ),
                for (var item in dictionaries) ...[
                  DicSection(dictionary: item),
                  SizedBox(height: 40),
                ],
              ],
            ),
          )));
  }
}

class DicSection extends StatelessWidget {
  const DicSection({super.key, required this.dictionary});
  final EsjDictionary dictionary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /* Text(
          //'Word: ${data['word']}',
          'Word: ${dictionary.word}',
          style: TextStyle(fontSize: 24),
        ), */
        Html(
          data: '<p class="hw">${dictionary.headword}</p>',
          style: htmlStyles,
        ),
        Html(
          data: dictionary.content,
          style: htmlStyles,
        ),
      ],
    );
  }
}
