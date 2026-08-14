import 'package:flutter/material.dart';
import 'package:my_dic/core/presentation/error/app_error_message.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/shared/consts/ui/ui.dart';
import 'package:my_dic/core/shared/consts/ui/ui2.dart';
import 'package:my_dic/features/word_detail/internal/presentation/components/conjugacion_card.dart';
import 'package:my_dic/features/word_detail/port/word_detail.dart';

class ConjugacionFragment extends StatelessWidget {
  const ConjugacionFragment({super.key, required this.detail, this.highlight});
  final QueryState<WordDetailData> detail;
  final String? highlight;

  @override
  Widget build(BuildContext context) {
    final conjugations = switch (detail.dataOrNull) {
      EspJpnWordDetailData(conjugation: final conjugation) => conjugation,
      _ => null,
    };
    if (conjugations == null) return _ConjugationReadState(state: detail);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        PADDING_X_DISPLAY,
        MARGIN_BOTTOM_SCROLLABLE_CHILD,
        PADDING_X_DISPLAY,
        UIConsts.scrollBottomPadding,
      ),
      children: conjugations.conjugations.entries.map((entry) {
        final moodTense = entry.key;
        final conjugation = entry.value;
        if (moodTense == WordDetailMoodTense.participlePresent ||
            moodTense == WordDetailMoodTense.participlePast) {
          return ParticipleCard(
            moodTense: moodTense,
            conjugacion: conjugation[WordDetailSubject.yo] ?? '',
          );
        }
        return ConjugacionCard(
          moodTense: moodTense,
          conjugacion: conjugation,
          query: highlight ?? '',
        );
      }).toList(),
    );
  }
}

class _ConjugationReadState extends StatelessWidget {
  const _ConjugationReadState({required this.state});
  final QueryState<WordDetailData> state;

  @override
  Widget build(BuildContext context) => Center(
        child: switch (state) {
          QueryLoading() => const CircularProgressIndicator(),
          QueryFailure(error: final error) =>
            Text(AppErrorMessage.from(error).text),
          QueryData(warnings: final warnings) when warnings.isNotEmpty =>
            Text(AppErrorMessage.from(warnings.first.error).text),
          QueryEmpty(warnings: final warnings) when warnings.isNotEmpty =>
            Text(AppErrorMessage.from(warnings.first.error).text),
          QueryEmpty() => const Text('No data available'),
          _ => const SizedBox.shrink(),
        },
      );
}
