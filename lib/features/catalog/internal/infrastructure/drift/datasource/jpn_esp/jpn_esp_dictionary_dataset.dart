import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

class JpnEspDictionaryDataSet {
  JpnEspDictionaryDataSet({required this.dictionary, required this.examples});
  final JpnEspDictionaryTableData dictionary;
  final List<JpnEspExampleTableData> examples;
}
