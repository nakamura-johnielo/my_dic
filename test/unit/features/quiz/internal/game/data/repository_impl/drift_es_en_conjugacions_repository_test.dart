import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/enums/conjugacion/mood_tense.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/features/quiz/internal/game/data/data_source/local/i_es_en_conjugacion_local_data_source.dart';
import 'package:my_dic/features/quiz/internal/game/data/repository_impl/drift_es_en_conjugacions_repository.dart';

void main() {
  test('a missing English row is a placeholder-map success, not not-found',
      () async {
    final repository = EsEnConjugacionRepository(_FakeDataSource());

    final result = await repository.getEnglishConjById(42);

    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull, {
      EnglishMoodTense.participlePresent.toString(): 'V-ing',
      EnglishMoodTense.participlePast.toString(): 'V-en',
      EnglishMoodTense.indicativePresent.toString(): 'V',
      EnglishMoodTense.indicativePresent3rd.toString(): 'Vs',
      EnglishMoodTense.indicativePast.toString(): 'V-ed',
    });
  });

  test('a local read exception is mapped to a database failure', () async {
    final repository = EsEnConjugacionRepository(_FakeDataSource(throws: true));

    final result = await repository.getEnglishConjById(42);

    expect(result.isFailure, isTrue);
    expect(result.errorOrNull, isA<DatabaseError>());
  });

  test('uses persisted forms when the English row exists', () async {
    final repository = EsEnConjugacionRepository(_FakeDataSource(
      row: const EsEnConjugacionTableData(
        wordId: 42,
        english: 'speak',
        present3rd: 'speaks',
      ),
    ));

    final result = await repository.getEnglishConjById(42);

    expect(result.dataOrNull?[EnglishMoodTense.indicativePresent.toString()],
        'speak');
    expect(result.dataOrNull?[EnglishMoodTense.indicativePresent3rd.toString()],
        'speaks');
  });
}

final class _FakeDataSource implements IEsEnConjugacionLocalDataSource {
  _FakeDataSource({this.throws = false, this.row});

  final bool throws;
  final EsEnConjugacionTableData? row;

  @override
  Future<EsEnConjugacionTableData?> getEnglishConjById(int id) async {
    if (throws) throw StateError('database offline');
    return row;
  }
}
