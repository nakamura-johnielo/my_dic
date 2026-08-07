import 'package:my_dic/core/shared/utils/logger.dart';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/consts/ui/ui.dart';
import 'package:my_dic/core/shared/consts/ui/ui2.dart';
import 'package:my_dic/core/domain/entity/dictionary/esj_dictionary.dart';
import 'package:my_dic/features/word_page/di/view_model_di.dart';
import 'package:my_dic/features/word_page/presentation/ui_model/word_page_load_key.dart';
import 'package:my_dic/features/word_page/presentation/view/html_style_kotobank.dart';
import 'package:my_dic/core/presentation/error/app_error_message.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';

class EspJpnDictionaryFragment extends ConsumerWidget {
  const EspJpnDictionaryFragment({super.key, required this.loadKey});

  final WordPageLoadKey loadKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppLogger.print("dic key: $key");

    final viewModel = ref.watch(wordPageViewModelProvider(loadKey));

    final dictionaryState = viewModel.espJpnDictionary;
    final List<EspJpnDictionary>? dictionaries = dictionaryState.dataOrNull;

    return dictionaries == null
        ? _DictionaryReadState(state: dictionaryState)
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
                if (dictionaryState.hasWarnings)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      AppErrorMessage.from(dictionaryState.warnings.first.error)
                          .text,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
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

class _DictionaryReadState extends StatelessWidget {
  const _DictionaryReadState({required this.state});
  final QueryState<List<EspJpnDictionary>> state;

  @override
  Widget build(BuildContext context) => Center(
        child: switch (state) {
          QueryLoading() => const CircularProgressIndicator(),
          QueryFailure(error: final error) =>
            Text(AppErrorMessage.from(error).text),
          QueryEmpty() => const Text('No data available'),
          _ => const SizedBox.shrink(),
        },
      );
}

class DicSection extends StatelessWidget {
  const DicSection({super.key, required this.dictionary});
  final EspJpnDictionary dictionary;

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
