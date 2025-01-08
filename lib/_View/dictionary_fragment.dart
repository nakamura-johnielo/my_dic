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
      child: Center(
        child: FutureBuilder<EsjDictionary?>(
          future:
              _esjDictionaryRepository.getDictionaryByWordId(wordId), // データ取得
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
                //log('dic: ${data.word}');
                //log('headword: ${data.headword}');
                return SingleChildScrollView(
                  child: Container(
                      margin: const EdgeInsets.only(
                          top: MARGIN_TOP_SCROLLABLE_CHILD,
                          bottom: MARGIN_BOTTOM_SCROLLABLE_CHILD),
                      padding: const EdgeInsets.symmetric(
                          horizontal: PADDING_X_DISPLAY),
                      child: Column(
                        children: [
                          Text(
                            //'Word: ${data['word']}',
                            'Word: ${data.word}',
                            style: TextStyle(fontSize: 24),
                          ),
                          Html(
                            data: data.headword,
                            style: htmlStyles,
                          ),
                          Html(
                            data: data.content,
                            style: htmlStyles,
                          ),
                        ],
                      )),
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
        ),
      ),
    );
  }
}

/* 

class DictionaryFragment extends StatelessWidget {
  final int wordId;
  const DictionaryFragment({super.key, required this.wordId});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.only(
            top: MARGIN_TOP_SCROLLABLE_CHILD,
            bottom: MARGIN_BOTTOM_SCROLLABLE_CHILD),
        padding: const EdgeInsets.symmetric(horizontal: PADDING_X_DISPLAY),
        child: Html(
          data: TEXT_SAMPLE,
          style: htmlStyles,
        ),
      ),
    );
  }
}
 */
