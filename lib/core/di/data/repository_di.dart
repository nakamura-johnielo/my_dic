import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/data/datasource.dart';
import 'package:my_dic/core/domain/i_repository/i_conjugation_repository.dart';
import 'package:my_dic/core/domain/i_repository/i_esj_dictionary_repository.dart';
import 'package:my_dic/core/domain/i_repository/i_esj_word_repository.dart';
import 'package:my_dic/core/domain/i_repository/i_jpn_esp_dictionary_repository.dart';
import 'package:my_dic/core/domain/i_repository/i_jpn_esp_word_repository.dart';
import 'package:my_dic/core/infrastructure/repositories/drift_conjugacion_repository.dart';
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
  return EsjWordRepository(ds);
});

final conjugacionsRepositoryProvider = Provider<IConjugacionsRepository>((ref) {
  final ds = ref.read(conjugacionDataSourceProvider);
  return ConjugacionRepository(ds);
});

final jpnEspWordRepositoryProvider = Provider<IJpnEspWordRepository>((ref) {
  final ds = ref.read(jpnEspWordDataSourceProvider);
  return JpnEspWordRepository(ds);
});

final jpnEspDictionaryRepositoryProvider =
    Provider<IJpnEspDictionaryRepository>((ref) {
  final ds = ref.read(jpnEspDictionaryDataSourceProvider);
  return JpnEspDictionaryRepository(ds);
});
