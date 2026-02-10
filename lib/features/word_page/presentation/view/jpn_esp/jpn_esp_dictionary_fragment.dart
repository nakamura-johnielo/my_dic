import 'package:my_dic/core/shared/utils/logger.dart';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/consts/ui/ui.dart';
import 'package:my_dic/core/shared/consts/ui/ui2.dart';
import 'package:my_dic/core/domain/entity/jpn_esp/jpn_esp_dictionary.dart';
import 'package:my_dic/features/word_page/di/view_model_di.dart';
import 'package:my_dic/features/word_page/presentation/view/html_style_kotobank.dart';

class JpnEspDictionaryFragmentInputData {
  final int wordId;
  JpnEspDictionaryFragmentInputData({required this.wordId});
}

class JpnEspDictionaryFragment extends ConsumerWidget {
  final int wordId;
  const JpnEspDictionaryFragment({super.key, required this.wordId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppLogger.print("dic key: $key");

    final viewModel = ref.watch(wordPageViewModelProvider(wordId));

    final List<JpnEspDictionary>? dictionaries = viewModel.jpnEspDictionary;

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
            padding: const EdgeInsets.fromLTRB(
              PADDING_X_DISPLAY, 0, PADDING_X_DISPLAY,
              UIConsts.scrollBottomPadding, // FAB分の余白
            ),
            child: Column(
              children: [
                Text(
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
  final JpnEspDictionary dictionary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
