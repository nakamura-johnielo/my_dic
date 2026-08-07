import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/data/data_di.dart';

import 'package:my_dic/core/infrastructure/datasource/esj/esj_drift_dictionary_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/esj/drift_esjpn_word_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/esj/i_esj_dictionary_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/esj/i_esj_word_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/conjugacion/conjugacion_drift_datasource.dart';
import 'package:my_dic/core/infrastructure/datasource/conjugacion/i_conjugacion_local_datasource.dart';
import 'package:my_dic/core/infrastructure/datasource/jpn_esp/jpn_esp_drift_word_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/jpn_esp/jpn_esp_drift_dictionary_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/jpn_esp/i_jpn_esp_word_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/jpn_esp/i_jpn_esp_dictionary_data_source.dart';

// --- Datasource providers (wrap DAOs into concrete datasource implementations)
final esjDictionaryDataSourceProvider =
    Provider<IEsjDictionaryLocalDataSource>((ref) {
  return EsjDriftDictionaryDataSource(
    ref.read(dictionaryDaoProvider),
    ref.read(exampleDaoProvider),
    ref.read(idiomDaoProvider),
    ref.read(supplementDaoProvider),
  );
});

final esjWordDataSourceProvider = Provider<IEsjWordLocalDataSource>((ref) {
  return DriftEspJpnWordDataSource(
    ref.read(wordDaoProvider),
  );
});

final conjugacionDataSourceProvider =
    Provider<IConjugacionLocalDataSource>((ref) {
  return ConjugacionDriftDataSource(ref.read(conjugationDaoProvider));
});

final jpnEspWordDataSourceProvider =
    Provider<IJpnEspWordLocalDataSource>((ref) {
  return JpnEspDriftWordDataSource(ref.read(jpnEspWordDaoProvider));
});

final jpnEspDictionaryDataSourceProvider =
    Provider<IJpnEspDictionaryLocalDataSource>((ref) {
  return JpnEspDriftDictionaryDataSource(
    ref.read(jpnEspDictionaryDaoProvider),
    ref.read(jpnEspExampleDaoProvider),
  );
});
