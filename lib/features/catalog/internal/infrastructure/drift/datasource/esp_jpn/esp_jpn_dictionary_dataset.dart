import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

/// Drift rows that make up one Spanish-to-Japanese dictionary entry.
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
