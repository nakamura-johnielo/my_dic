import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/word_page/presentation/components/conjugacion_card.dart';
import 'package:my_dic/core/shared/enums/conjugacion/mood_tense.dart';
import 'package:my_dic/core/shared/enums/ui/ui.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacions.dart';
import 'package:my_dic/features/search/di/view_model_di.dart';
import 'package:my_dic/features/word_page/di/view_model_di.dart';

class ConjugacionFragment extends ConsumerWidget {
  const ConjugacionFragment({super.key, required this.wordId});

  //final WordPageController wordPageController;
  //=DI<IConjugacionsRepository>();
  final int wordId;

  //log("getwordbyid: ${result[]}");
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log("conj key: $key");
    // final wordPageController = ref.read(wordPageControllerProvider);
    // final mainViewModel = ref.watch(mainViewModelProvider);
    // if (!mainViewModel.conjugacionCache.containsKey(wordId)) {
    //   wordPageController.fetchConjugacionById(wordId);
    //   return Center(
    //     child: Text("Loading..."),
    //   );
    // }

    final viewModel = ref.watch(wordPageViewModelProvider(wordId));

    //TODO ここ修正
    final EspConjugacions? conjugacions = viewModel.conjugacions;

    // final query = ref.watch(searchViewModelProviderOld).query;
    final query = ref.watch(searchViewModelProvider).query;

    return conjugacions == null
        ? (Center(
            child: Text(
            'No data available',
            style: TextStyle(fontSize: 24),
          )))
        : (ListView(
            //shrinkWrap: true,
            padding: const EdgeInsets.symmetric(
                horizontal: PADDING_X_DISPLAY,
                vertical: MARGIN_BOTTOM_SCROLLABLE_CHILD),

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
