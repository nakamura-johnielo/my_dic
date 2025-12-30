import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/core/di/data/datasource.dart';
import 'package:my_dic/core/domain/i_repository/i_conjugation_repository.dart';
import 'package:my_dic/core/domain/i_repository/i_esj_dictionary_repository.dart';
import 'package:my_dic/core/domain/i_repository/i_esj_word_repository.dart';
import 'package:my_dic/core/domain/i_repository/i_jpn_esp_dictionary_repository.dart';
import 'package:my_dic/core/domain/i_repository/i_jpn_esp_word_repository.dart';
import 'package:my_dic/core/domain/i_repository/i_sync_status_repository.dart';
import 'package:my_dic/core/domain/i_repository/i_word_status_repository.dart';
import 'package:my_dic/core/infrastructure/repositories/drift_conjugacion_repository.dart';
import 'package:my_dic/core/infrastructure/repositories/drift_word_status_repository.dart';
import 'package:my_dic/core/infrastructure/repositories/firebase_word_status_repository.dart';
import 'package:my_dic/core/infrastructure/repositories/sync_status_repository.dart';
import 'package:my_dic/core/infrastructure/repositories/wordstatus_repository.dart';
import 'package:my_dic/core/infrastructure/repositories/drift_esj_dictionary_repository.dart';
import 'package:my_dic/core/infrastructure/repositories/drift_esj_word_repository.dart';
import 'package:my_dic/core/infrastructure/repositories/drift_jpn_esp_dictionary_repository.dart';
import 'package:my_dic/core/infrastructure/repositories/drift_jpn_esp_word_repository.dart';


final esjDictionaryRepositoryProvider =
    Provider<IEsjDictionaryRepository>((ref) {
  final ds = ref.read(esjDictionaryDataSourceProvider);
  return EsjDictionaryRepository(ds);
});

final esjWordRepositoryProvider = Provider<IEsjWordRepository>((ref) {
  final ds = ref.read(esjWordDataSourceProvider);
  final statusDs = ref.read(localWordStatusDataSourceProvider);
  return EsjWordRepository(ds, statusDs);
});

final conjugacionsRepositoryProvider = Provider<IConjugacionsRepository>((ref) {
  final ds = ref.read(conjugacionDataSourceProvider);
  return ConjugacionRepository(ds);
});

final jpnEspWordRepositoryProvider = Provider<IJpnEspWordRepository>((ref) {
  final ds = ref.read(jpnEspWordDataSourceProvider);
  final dictDs = ref.read(jpnEspDictionaryDataSourceProvider);
  return JpnEspWordRepository(ds, dictDs);
});

final jpnEspDictionaryRepositoryProvider =
    Provider<IJpnEspDictionaryRepository>((ref) {
  final ds = ref.read(jpnEspDictionaryDataSourceProvider);
  return JpnEspDictionaryRepository(ds);
});




final wordStatusRepositoryProvider = Provider<IWordStatusRepository>((ref) {
  final local = ref.read(localWordStatusDataSourceProvider );
  final remote = ref.read(remoteWordStatusDataSourceProvider);
  // final localDataSource = ref.watch(localWordStatusDaoProvider);
  // return WordStatusRepository(dataSource, localDataSource);
  return WordStatusRepository(remote, local);
});

final localEspJpnWordStatusRepositoryProvider = Provider<ILocalWordStatusRepository>((ref) {
  final ds = ref.read(localWordStatusDataSourceProvider);
  return DriftWordStatusRepository(ds);
});//TODO 消す

final remoteEspJpnWordStatusRepositoryProvider = Provider<IRemoteWordStatusRepository>((ref) {
  final ds = ref.read(remoteWordStatusDataSourceProvider);
  return FirebaseWordStatusRepository(ds);
});//TODO 消す

final syncStatusRepositoryProvider = Provider<ISyncStatusRepository>((ref) {
  final ds = ref.read(sharedPreferencesSyncStatusDataSourceProvider);
  return SyncStatusRepository(ds);
});
