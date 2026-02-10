import 'package:my_dic/core/shared/utils/logger.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/shared/consts/ui/ui.dart';
import 'package:my_dic/features/word_page/presentation/components/conjugacion_card.dart';
import 'package:my_dic/core/shared/enums/conjugacion/mood_tense.dart';
import 'package:my_dic/core/shared/consts/ui/ui2.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacions.dart';
import 'package:my_dic/features/search/di/view_model_di.dart';
import 'package:my_dic/features/word_page/di/view_model_di.dart';

class ConjugacionFragment extends ConsumerWidget {
  const ConjugacionFragment({super.key, required this.wordId});

  final int wordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppLogger.print("conj key: $key");

    final viewModel = ref.watch(wordPageViewModelProvider(wordId));

    //TODO ここ修正
    final EspConjugacions? conjugacions = viewModel.conjugacions;

    final query = ref.watch(searchViewModelProvider).query;

    return conjugacions == null
        ? (Center(
            child: Text(
            'No data available',
            style: TextStyle(fontSize: 24),
          )))
        : (ListView(
            padding: const EdgeInsets.fromLTRB(
              PADDING_X_DISPLAY, MARGIN_BOTTOM_SCROLLABLE_CHILD,
              PADDING_X_DISPLAY,
              UIConsts.scrollBottomPadding, // FAB分の余白
            ),
            children: conjugacions.conjugacions.entries.map((entry) {
              final moodTense = entry.key;
              final conjugation = entry.value;
              if (moodTense == MoodTense.participlePresent ||
                  moodTense == MoodTense.participlePast) {
                return ParticipleCard(
                    moodTense: moodTense, conjugacion: conjugation.yo);
              }
              return ConjugacionCard(
                moodTense: moodTense,
                conjugacion: conjugation,
                query: query,
              );
            }).toList(),
          ));
  }
}
