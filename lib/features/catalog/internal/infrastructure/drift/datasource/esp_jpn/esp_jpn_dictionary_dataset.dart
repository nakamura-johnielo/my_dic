import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

/// 1 つのスペイン語から日本語への辞書エントリを構成する Drift 行。
class EspJpnDictionaryDataSet {
  EspJpnDictionaryDataSet({
    required this.dictionary,
    required this.examples,
    required this.idioms,
    required this.supplements,
  });

  final EspJpnDictionaryTableData dictionary;
  final List<EspJpnExampleTableData> examples;
  final List<EspJpnIdiomTableData> idioms;
  final List<EspJpnSupplementTableData> supplements;
}
