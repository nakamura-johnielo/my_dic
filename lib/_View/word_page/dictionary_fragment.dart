import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:my_dic/Constants/test.dart';
import 'package:my_dic/Constants/ui.dart';
import 'package:my_dic/DI/product.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/dictionary/esj_dictionary.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_esj_dictionary_repository.dart';
import 'package:my_dic/html_style_kotobank.dart';
//import 'package:my_dic/Infrastracture/DAO/kotobank_dictionary_dao.dart';

class DictionaryFragment extends StatelessWidget {
  final int wordId;
  DictionaryFragment({super.key, required this.wordId});
  //final KotobankDictionaryDao _dao = KotobankDictionaryDao();
  //final DatabaseProvider db = DatabaseProvider();
  final IEsjDictionaryRepository _esjDictionaryRepository =
      DI<IEsjDictionaryRepository>();

  //log("getwordbyid: ${result[]}");
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FutureBuilder<List<EsjDictionary>>(
        future: _esjDictionaryRepository.getDictionaryByWordId(wordId), // データ取得
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // データ取得中の表示
            return CircularProgressIndicator();
          } else if (snapshot.hasData) {
            final dictionaryList = snapshot.data;

            if (dictionaryList == null || dictionaryList.isEmpty) {
              // データが見つからない場合
              return Text(
                'Word not found',
                style: TextStyle(fontSize: 18),
              );
            }

            if (dictionaryList.isNotEmpty) {
              // データが見つかった場合
              //log('dic: ${data.word}');
              //log('headword: ${data.headword}');
              return Container(
                margin: const EdgeInsets.only(
                    top: MARGIN_TOP_SCROLLABLE_CHILD,
                    bottom: MARGIN_BOTTOM_SCROLLABLE_CHILD),
                padding:
                    const EdgeInsets.symmetric(horizontal: PADDING_X_DISPLAY),
                child: Column(
                  children: [
                    Text(
                      //'Word: ${data['word']}',
                      '${dictionaryList[0].word}',
                      style: TextStyle(fontSize: 24),
                    ),
                    for (var item in dictionaryList) ...[
                      DicSection(dictionary: item),
                      SizedBox(height: 40),
                    ],
                  ],
                ),
              );
            }
          }

          // データがない場合の表示
          return Text(
            'No data available',
            style: TextStyle(fontSize: 24),
          );
        },
      ),
    );
  }
}

class DicSection extends StatelessWidget {
  const DicSection({super.key, required this.dictionary});
  final EsjDictionary dictionary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /* Text(
          //'Word: ${data['word']}',
          'Word: ${dictionary.word}',
          style: TextStyle(fontSize: 24),
        ), */
        Html(
          data: '<p flutter="head-word">${dictionary.headword}</p>',
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
