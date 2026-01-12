import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/consts/ui/ui.dart';
import 'package:my_dic/core/shared/consts/ui/ui2.dart';
import 'package:my_dic/core/domain/entity/dictionary/esj_dictionary.dart';
import 'package:my_dic/features/quiz/di/view_model_di.dart';
import 'package:my_dic/features/word_page/di/view_model_di.dart';
import 'package:my_dic/features/word_page/presentation/view/html_style_kotobank.dart';
//import 'package:my_dic/Infrastracture/DAO/kotobank_dictionary_dao.dart';

class EspJpnDictionaryFragment extends ConsumerWidget {
  final int wordId;
  const EspJpnDictionaryFragment({super.key, required this.wordId});
  //final KotobankDictionaryDao _dao = KotobankDictionaryDao();
  //final DatabaseProvider db = DatabaseProvider();
  //final WordPageController wordPageController;
  //=DI<IEsjDictionaryRepository>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log("dic key: $key");
    // final wordPageController = ref.read(wordPageControllerProvider);
    // final mainViewModel = ref.watch(mainViewModelProvider);
    // if (!mainViewModel.dictionaryCache.containsKey(wordId)) {
    //   wordPageController.fetchDictionaryById(wordId);
    //   return Center(
    //     child: Text("Loading..."),
    //   );
    // }
    
    final viewModel = ref.watch(wordPageViewModelProvider(wordId));

    final List<EspJpnDictionary>? dictionaries =
        viewModel.espJpnDictionary;
    //     final dictionaries = ref.watch(mainViewModelProvider).dictionaryCache[wordId]!;
    // if (dictionaries != null && dictionaries.isNotEmpty) {
    //   //!TODO
    //   ref.read(quizWordProvider.notifier).state = dictionaries[0].word;
    // }
    if (dictionaries != null &&
        dictionaries.isNotEmpty &&
        (ref.watch(quizWordProvider) != dictionaries[0].word)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(quizWordProvider.notifier).state = dictionaries[0].word;
      });
    }

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
            padding:  const EdgeInsets.fromLTRB(PADDING_X_DISPLAY,0, PADDING_X_DISPLAY, 
           UIConsts.scrollBottomPadding,  // FAB分の余白
            ),child: Column(
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
  final EspJpnDictionary dictionary;

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
