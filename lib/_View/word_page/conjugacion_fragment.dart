import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:my_dic/Components/conjugacion_card.dart';
import 'package:my_dic/Constants/Enums/mood_tense.dart';
import 'package:my_dic/Constants/ui.dart';
import 'package:my_dic/DI/product.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/verb/conjugacion/conjugacions.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_conjugation_repository.dart';

class ConjugacionFragment extends StatelessWidget {
  ConjugacionFragment({super.key, required this.wordId});

  final IConjugacionsRepository _conjugacionRepository =
      DI<IConjugacionsRepository>();
  final int wordId;

  //log("getwordbyid: ${result[]}");
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Conjugacions?>(
      future: _conjugacionRepository.getConjugacionByWordId(wordId), // データ取得
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // データ取得中の表示
          return CircularProgressIndicator();
        } else if (snapshot.hasData) {
          final data = snapshot.data;

          if (data == null) {
            // データが見つからない場合
            return Text(
              'Word not found',
              style: TextStyle(fontSize: 18),
            );
          } else {
            // データが見つかった場合
            log('dic: ');
            //log(data.conjugacions);
            //log('headword: ${data.headword}');
            return ListView(
              //shrinkWrap: true,
              padding: const EdgeInsets.symmetric(
                  horizontal: PADDING_X_DISPLAY,
                  vertical: MARGIN_BOTTOM_SCROLLABLE_CHILD),

              children: data.conjugacions.entries.map((entry) {
                final moodTense = entry.key;
                final conjugation = entry.value;
                return ConjugacionCard(
                    moodTense: moodTense, conjugacion: conjugation);
              }).toList(),
            );
          }
        } else {
          // データがない場合の表示
          return Text(
            'No data available',
            style: TextStyle(fontSize: 24),
          );
        }
      },
    );
  }
}
