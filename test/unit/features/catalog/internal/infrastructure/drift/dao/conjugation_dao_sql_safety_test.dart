import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/dao/esp_jpn/conjugation_dao.dart';

void main() {
  late DatabaseProvider database;
  late ConjugationDao dao;

  setUp(() {
    database = DatabaseProvider.forTesting(NativeDatabase.memory());
    dao = ConjugationDao(database);
  });

  tearDown(() => database.close());

  test('legacy DAO source keeps user values bound and debug execution absent',
      () {
    final source = File(
      'lib/features/catalog/internal/infrastructure/drift/dao/esp_jpn/conjugation_dao.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('AppLogger')));
    expect(source, isNot(contains('resTest')));
    expect(source, isNot(contains("LIKE '\$")));
    expect(source, contains('Variable.withString'));
    expect(source, contains('Variable.withInt(size)'));
    expect(source, contains('Variable.withInt(size * page)'));
  });

  Future<void> insert(
    int id,
    String word, {
    String? presentYo,
    String? past,
  }) async {
    await database.into(database.espJpnWords).insert(
          EspJpnWordsCompanion.insert(wordId: Value(id), word: word),
        );
    await database.into(database.espConjugations).insert(
          EspConjugationsCompanion.insert(
            wordId: Value(id),
            word: word,
            indicativePresentYo: Value(presentYo),
            pastParticiple: Value(past),
          ),
        );
  }

  test('forms-only and all-table searches retain their distinct scope',
      () async {
    await insert(1, 'hablar', presentYo: 'hablo', past: 'hablado');
    await insert(2, 'hablante', presentYo: 'digo');

    final forms = await dao.getConjugationByWordWithPage('hab', 10, 0);
    final all = await dao.getConjugationInAllTableByWordWithPage('hab', 10, 0);

    expect(forms.map((row) => row.wordId), [1]);
    expect(forms.single.indicativePresentYo, 'hablo');
    expect(forms.single.pastParticiple, 'hablado');
    expect(all.map((row) => row.wordId), [1, 2]);
  });

  test('exact forms sort first, then word id, with bound paging', () async {
    await insert(1, 'uno', presentYo: 'casamos');
    await insert(2, 'dos', presentYo: 'casa');
    await insert(3, 'tres', presentYo: 'casa');
    await insert(4, 'cuatro', presentYo: 'casar');

    final first = await dao.getConjugationByWordWithPage('casa', 2, 0);
    final second = await dao.getConjugationByWordWithPage('casa', 2, 1);

    expect(first.map((row) => row.wordId), [2, 3]);
    expect(second.map((row) => row.wordId), [1, 4]);
  });

  test("literal special characters and injection-like text stay data",
      () async {
    await insert(1, 'one', presentYo: "o'clock");
    await insert(2, 'two', presentYo: 'a%form');
    await insert(3, 'three', presentYo: 'axform');
    await insert(4, 'four', presentYo: 'a_form');
    await insert(5, 'five', presentYo: 'a!form');

    Future<List<int>> ids(String text) async =>
        (await dao.getConjugationByWordWithPage(text, 10, 0))
            .map((row) => row.wordId)
            .toList();

    expect(await ids("o'"), [1]);
    expect(await ids('a%'), [2]);
    expect(await ids('a_'), [4]);
    expect(await ids('a!'), [5]);
    expect(await ids("x' OR 1=1 --"), isEmpty);
  });
}
