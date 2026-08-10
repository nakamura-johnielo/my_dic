import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:my_dic/core/presentation/error/app_error_message.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/shared/consts/ui/ui.dart';
import 'package:my_dic/core/shared/consts/ui/ui2.dart';
import 'package:my_dic/features/catalog/port/model/esp_jpn_entry.dart';
import 'package:my_dic/features/word_detail/internal/presentation/view/html_style_kotobank.dart';
import 'package:my_dic/features/word_detail/port/word_detail_view_data.dart';

class EspJpnDictionaryFragment extends StatelessWidget {
  const EspJpnDictionaryFragment({super.key, required this.detail});

  final QueryState<WordDetailViewData> detail;

  @override
  Widget build(BuildContext context) {
    final dictionaries = switch (detail.dataOrNull) {
      EspJpnWordDetailViewData(entries: final entries) => entries,
      _ => null,
    };
    if (dictionaries == null) return _DictionaryReadState(state: detail);
    if (dictionaries.isEmpty) return _DictionaryReadState(state: detail);

    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.only(
          top: MARGIN_TOP_SCROLLABLE_CHILD,
          bottom: MARGIN_BOTTOM_SCROLLABLE_CHILD,
        ),
        padding: const EdgeInsets.fromLTRB(
          PADDING_X_DISPLAY,
          0,
          PADDING_X_DISPLAY,
          UIConsts.scrollBottomPadding,
        ),
        child: Column(
          children: [
            if (detail.hasWarnings)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  AppErrorMessage.from(detail.warnings.first.error).text,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            Text(dictionaries.first.word, style: const TextStyle(fontSize: 24)),
            for (final item in dictionaries) ...[
              DicSection(dictionary: item),
              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }
}

class _DictionaryReadState extends StatelessWidget {
  const _DictionaryReadState({required this.state});
  final QueryState<WordDetailViewData> state;

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
  final EspJpnEntry dictionary;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Html(
              data:
                  '<p class="hw">${dictionary.headword ?? dictionary.word}</p>',
              style: htmlStyles),
          Html(data: dictionary.content ?? '', style: htmlStyles),
        ],
      );
}
