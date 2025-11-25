import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/Components/conjugacion_card.dart';
import 'package:my_dic/Constants/Enums/mood_tense.dart';
import 'package:my_dic/Constants/ui.dart';
import 'package:my_dic/DI/product.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/verb/conjugacion/conjugacions.dart';
import 'package:my_dic/_Interface_Adapter/Controller/word_page_controller.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/main_view_model.dart';
import 'package:my_dic/_Interface_Adapter/ViewModel/search_view_model.dart';

class ConjugacionFragment extends ConsumerWidget {
  const ConjugacionFragment({super.key, required this.wordId});

  //final WordPageController wordPageController;
  //=DI<IConjugacionsRepository>();
  final int wordId;

  //log("getwordbyid: ${result[]}");
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log("conj key: $key");
    final wordPageController = ref.read(wordPageControllerProvider);
    final mainViewModel = ref.watch(mainViewModelProvider);
    if (!mainViewModel.conjugacionCache.containsKey(wordId)) {
      wordPageController.fetchConjugacionById(wordId);
      return Center(
        child: Text("Loading..."),
      );
    }
    final Conjugacions? conjugacions = mainViewModel.conjugacionCache[wordId]!;

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
