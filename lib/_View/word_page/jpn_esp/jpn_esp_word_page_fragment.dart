import 'package:flutter/material.dart';
import 'package:my_dic/_View/word_page/jpn_esp/jpn_esp_dictionary_fragment.dart';

class JpnEspWordPageFragmentInput {
  final int wordId;
  JpnEspWordPageFragmentInput({required this.wordId});
}

class JpnEspWordPageFragment extends StatelessWidget {
  const JpnEspWordPageFragment({super.key, required this.input});
  final JpnEspWordPageFragmentInput input;

  @override
  Widget build(BuildContext context) {
    return JpnEspDictionaryFragment(
        //param1: WordPageChildInputData(wordId:
        wordId: input.wordId //)
        );
  }
}
