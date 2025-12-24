import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/core/domain/i_repository/i_conjugation_repository.dart';
import 'package:my_dic/core/domain/i_repository/i_esj_dictionary_repository.dart';
import 'package:my_dic/core/domain/i_repository/i_esj_word_repository.dart';
import 'package:my_dic/core/domain/i_repository/i_jpn_esp_dictionary_repository.dart';
import 'package:my_dic/core/domain/i_repository/i_jpn_esp_word_repository.dart';
import 'package:my_dic/core/domain/i_repository/i_sync_status_repository.dart';
import 'package:my_dic/core/domain/i_repository/i_word_status_repository.dart';
import 'package:my_dic/core/infrastructure/repository/drift_conjugacion_repository.dart';
import 'package:my_dic/core/infrastructure/repository/drift_word_status_repository.dart';
import 'package:my_dic/core/infrastructure/repository/firebase_word_status_repository.dart';
import 'package:my_dic/core/infrastructure/repository/sync_status_repository.dart';
import 'package:my_dic/core/infrastructure/repository/wordstatus_repository.dart';
import 'package:my_dic/features/quiz/data/repository_impl/drift_es_en_conjugacions_repository.dart';
import 'package:my_dic/core/infrastructure/repository/drift_esj_dictionary_repository.dart';
import 'package:my_dic/core/infrastructure/repository/drift_esj_word_repository.dart';
import 'package:my_dic/core/infrastructure/repository/drift_jpn_esp_dictionary_repository.dart';
import 'package:my_dic/core/infrastructure/repository/drift_jpn_esp_word_repository.dart';

final esjDictionaryRepositoryProvider =
    Provider<IEsjDictionaryRepository>((ref) {
  return DriftEsjDictionaryRepository(
    ref.read(dictionaryDaoProvider),
    ref.read(exampleDaoProvider),
    ref.read(idiomDaoProvider),
    ref.read(supplementDaoProvider),
  );
});

final esjWordRepositoryProvider = Provider<IEsjWordRepository>((ref) {
  return DriftEsjWordRepository(
    ref.read(wordDaoProvider),
    ref.read(localWordStatusDaoProvider),
  );
});

final conjugacionsRepositoryProvider = Provider<IConjugacionsRepository>((ref) {
  return DriftConjugacionRepository(ref.read(conjugationDaoProvider));
});

final jpnEspWordRepositoryProvider = Provider<IJpnEspWordRepository>((ref) {
  return DriftJpnEspWordRepository(
    ref.read(jpnEspWordDaoProvider),
    ref.read(jpnEspDictionaryDaoProvider),
  );
});

final jpnEspDictionaryRepositoryProvider =
    Provider<IJpnEspDictionaryRepository>((ref) {
  return DriftJpnEspDictionaryRepository(
    ref.read(jpnEspDictionaryDaoProvider),
    ref.read(jpnEspExampleDaoProvider),
  );
});

final esEnConjugacionRepositoryProvider =
    Provider<DriftEsEnConjugacionRepository>((ref) {
  return DriftEsEnConjugacionRepository(ref.read(esEnConjugacionDaoProvider));
});


final wordStatusRepositoryProvider = Provider<IWordStatusRepository>((ref) {
  final local = ref.read(localWordStatusDaoProvider);
  final remote = ref.read(remoteWordStatusDaoProvider);
  // final localDataSource = ref.watch(localWordStatusDaoProvider);
  // return WordStatusRepository(dataSource, localDataSource);
  return WordStatusRepository(remote, local);
});

final localEspJpnWordStatusRepositoryProvider = Provider<ILocalWordStatusRepository>((ref) {
  final local = ref.read(localWordStatusDaoProvider);
  // final localDataSource = ref.watch(localWordStatusDaoProvider);
  // return WordStatusRepository(dataSource, localDataSource);
  return DriftWordStatusRepository( local);
});

final remoteEspJpnWordStatusRepositoryProvider = Provider<IRemoteWordStatusRepository>((ref) {
  final remote = ref.read(remoteWordStatusDaoProvider);
  // final localDataSource = ref.watch(localWordStatusDaoProvider);
  // return WordStatusRepository(dataSource, localDataSource);
  return FirebaseWordStatusRepository( remote);
});

final syncStatusRepositoryProvider = Provider<ISyncStatusRepository>((ref) {
  final local = ref.read(sharedPreferenceSyncStatusDaoProvider);
  // final localDataSource = ref.watch(localWordStatusDaoProvider);
  // return WordStatusRepository(dataSource, localDataSource);
  return SharedPreferenceSyncStatusRepository(local);
});
