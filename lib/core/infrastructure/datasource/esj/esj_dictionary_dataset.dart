import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

/// Composite class to return all related TableData for a dictionary entry
class EsjDictionaryDataSet {
  final EspJpnDictionaryTableData dictionary;
  final List<EspJpnExampleTableData> examples;
  final List<EspJpnIdiomTableData> idioms;
  final List<EspJpnSupplementTableData> supplements;

  EsjDictionaryDataSet({
    required this.dictionary,
    required this.examples,
    required this.idioms,
    required this.supplements,
  });
}
