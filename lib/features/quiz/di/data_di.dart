import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/features/quiz/data/data_source/local/quiz_json_dao.dart';
import 'package:my_dic/features/quiz/data/data_source/local/i_quiz_local_data_source.dart';
import 'package:my_dic/features/quiz/data/data_source/local/quiz_local_data_source.dart';
import 'package:my_dic/features/quiz/data/repository_impl/drift_es_en_conjugacions_repository.dart';
import 'package:my_dic/features/quiz/data/repository_impl/json_quiz_repository_impl.dart';
import 'package:my_dic/features/quiz/data/data_source/local/i_es_en_conjugacion_local_data_source.dart';
import 'package:my_dic/features/quiz/data/data_source/local/es_en_conjugacion_drift_data_source.dart';
import 'package:my_dic/features/quiz/domain/usecase/english_conj_sub/i_fetch_english_conj_sub_repository.dart';
import 'package:my_dic/features/quiz/domain/usecase/fetch_english_conj.dart/i_fetch_english_conj_repository.dart';


final quizJsonDaoProvider = Provider<QuizJsonDao>((ref) {
  return QuizJsonDao();
});

final quizLocalDataSourceProvider = Provider<IQuizLocalDataSource>((ref) {
  return QuizLocalDataSource(dao: ref.read(quizJsonDaoProvider));
});


//===================repository

final fetchEnglishConjSubRepositoryProvider =
    Provider<IEnglishConjSubRepository>((ref) {
  return JsonQuizRepositoryImpl(
    localDataSource: ref.read(quizLocalDataSourceProvider),
  );
});

final esEnConjugacionRepositoryProvider =
    Provider<IEsEnConjugacionRepository>((ref) {
  return DriftEsEnConjugacionRepository(ref.read(esEnConjugacionDataSourceProvider));
});

final esEnConjugacionDataSourceProvider =
    Provider<IEsEnConjugacionLocalDataSource>((ref) {
  return EsEnConjugacionDriftDataSource(ref.read(esEnConjugacionDaoProvider));
});