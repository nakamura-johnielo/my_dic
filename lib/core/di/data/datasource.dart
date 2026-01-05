

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/data/data_di.dart';

import 'package:my_dic/core/infrastructure/datasource/esj/esj_drift_dictionary_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/esj/esj_drift_word_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/esj/i_esj_dictionary_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/esj/i_esj_word_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/conjugacion/conjugacion_drift_datasource.dart';
import 'package:my_dic/core/infrastructure/datasource/conjugacion/i_conjugacion_local_datasource.dart';
import 'package:my_dic/core/infrastructure/datasource/jpn_esp/jpn_esp_drift_word_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/jpn_esp/jpn_esp_drift_dictionary_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/jpn_esp/i_jpn_esp_word_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/jpn_esp/i_jpn_esp_dictionary_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/word_status/drift_word_status_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/word_status/firebase_word_status_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/word_status/i_local_word_status_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/word_status/i_remote_word_status_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/sync/shared_preferences_sync_status_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/sync/i_sync_status_data_source.dart';

// --- Datasource providers (wrap DAOs into concrete datasource implementations)
final esjDictionaryDataSourceProvider = Provider<IEsjDictionaryLocalDataSource>((ref) {
  return EsjDriftDictionaryDataSource(
    ref.read(dictionaryDaoProvider),
    ref.read(exampleDaoProvider),
    ref.read(idiomDaoProvider),
    ref.read(supplementDaoProvider),
  );
});

final esjWordDataSourceProvider = Provider<IEsjWordLocalDataSource>((ref) {
  return EsjDriftWordDataSource(
    ref.read(wordDaoProvider),
    ref.read(localWordStatusDaoProvider),
  );
});

final conjugacionDataSourceProvider = Provider<IConjugacionLocalDataSource>((ref) {
  return ConjugacionDriftDataSource(ref.read(conjugationDaoProvider));
});

final jpnEspWordDataSourceProvider = Provider<IJpnEspWordLocalDataSource>((ref) {
  return JpnEspDriftWordDataSource(ref.read(jpnEspWordDaoProvider));
});

final jpnEspDictionaryDataSourceProvider =
    Provider<IJpnEspDictionaryLocalDataSource>((ref) {
  return JpnEspDriftDictionaryDataSource(
    ref.read(jpnEspDictionaryDaoProvider),
    ref.read(jpnEspExampleDaoProvider),
  );
});


final sharedPreferencesSyncStatusDataSourceProvider =
    Provider<ISyncStatusDataSource>((ref) {
  return SharedPreferencesSyncStatusDataSource(ref.read(sharedPreferenceSyncStatusDaoProvider));
});
