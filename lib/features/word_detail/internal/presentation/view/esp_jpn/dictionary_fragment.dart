import 'package:flutter/material.dart';
import 'package:my_dic/core/presentation/error/app_error_message.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/shared/consts/ui/ui.dart';
import 'package:my_dic/core/shared/consts/ui/ui2.dart';
import 'package:my_dic/features/word_detail/internal/presentation/components/word_detail_content_view.dart';
import 'package:my_dic/features/word_detail/port/word_detail.dart';

class EspJpnDictionaryFragment extends StatelessWidget {
  const EspJpnDictionaryFragment({super.key, required this.detail});

  final QueryState<WordDetailData> detail;

  @override
  Widget build(BuildContext context) {
    final dictionaries = switch (detail.dataOrNull) {
      EspJpnWordDetailData(entries: final entries) => entries,
      _ => null,
    };
    if (dictionaries == null || dictionaries.isEmpty) {
      return Column(
        children: [
          if (detail.hasWarnings)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                AppErrorMessage.from(detail.warnings.first.error).text,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Expanded(child: _DictionaryReadState(state: detail)),
        ],
      );
    }

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
  final QueryState<WordDetailData> state;

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
  final WordDetailEspJpnEntry dictionary;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          WordDetailContentView(content: dictionary.headword, isHeadword: true),
          WordDetailContentView(content: dictionary.content),
        ],
      );
}
