import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

/// Composite class to return all related TableData for a JPN-ESP dictionary entry
class JpnEspDictionaryDataSet {
  final JpnEspDictionaryTableData dictionary;
  final List<JpnEspExampleTableData> examples;

  JpnEspDictionaryDataSet({
    required this.dictionary,
    required this.examples,
  });
}
