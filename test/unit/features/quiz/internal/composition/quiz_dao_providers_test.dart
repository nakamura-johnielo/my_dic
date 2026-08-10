import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/di/data/data_di.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/quiz/internal/composition/quiz_dao_providers.dart';
import 'package:my_dic/features/quiz/internal/infrastructure/drift/dao/es_en_conjugacion_dao.dart';

void main() {
  test('Quiz composes its Es-En DAO over the shared database runtime', () {
    final database = DatabaseProvider.forTesting(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    addTearDown(container.dispose);
    addTearDown(database.close);

    expect(
        container.read(esEnConjugacionDaoProvider), isA<EsEnConjugacionDao>());
  });
}
