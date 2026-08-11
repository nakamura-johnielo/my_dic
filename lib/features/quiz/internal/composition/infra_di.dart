import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/features/quiz/internal/infrastructure/drift/dao/es_en_conjugacion_dao.dart';

/// Quiz-owned DAO composition over the application-managed database runtime.
final esEnConjugacionDaoProvider = Provider<EsEnConjugacionDao>(
  (ref) => EsEnConjugacionDao(ref.read(databaseProvider)),
);
