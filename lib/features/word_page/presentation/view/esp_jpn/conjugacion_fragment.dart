import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/presentation/search_view_models.dart';
import 'package:my_dic/core/presentation/error/app_error_message.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/shared/consts/ui/ui.dart';
import 'package:my_dic/core/shared/consts/ui/ui2.dart';
import 'package:my_dic/core/shared/enums/conjugacion/mood_tense.dart';
import 'package:my_dic/features/word_page/application/query/word_detail_view_data.dart';
import 'package:my_dic/features/word_page/presentation/components/conjugacion_card.dart';

class ConjugacionFragment extends ConsumerWidget {
  const ConjugacionFragment({super.key, required this.detail});
  final QueryState<WordDetailViewData> detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conjugations = switch (detail.dataOrNull) {
      EspJpnWordDetailViewData(conjugation: final conjugation) => conjugation,
      _ => null,
    };
    if (conjugations == null) return _ConjugationReadState(state: detail);

    final query = ref.watch(searchViewModelProvider).query;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        PADDING_X_DISPLAY,
        MARGIN_BOTTOM_SCROLLABLE_CHILD,
        PADDING_X_DISPLAY,
        UIConsts.scrollBottomPadding,
      ),
      children: conjugations.conjugacions.entries.map((entry) {
        final moodTense = entry.key;
        final conjugation = entry.value;
        if (moodTense == MoodTense.participlePresent ||
            moodTense == MoodTense.participlePast) {
          return ParticipleCard(
            moodTense: moodTense,
            conjugacion: conjugation.yo,
          );
        }
        return ConjugacionCard(
          moodTense: moodTense,
          conjugacion: conjugation,
          query: query,
        );
      }).toList(),
    );
  }
}

class _ConjugationReadState extends StatelessWidget {
  const _ConjugationReadState({required this.state});
  final QueryState<WordDetailViewData> state;

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
