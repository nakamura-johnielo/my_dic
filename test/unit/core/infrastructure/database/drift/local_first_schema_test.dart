import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

void main() {
  late DatabaseProvider database;
  setUp(() => database = DatabaseProvider.forTesting(NativeDatabase.memory()));
  tearDown(() => database.close());

  MyWordsCompanion word(String account) => MyWordsCompanion.insert(
        myWordId: 'same-id',
        word: 'hola',
        editAt: '2026-01-01T00:00:00Z',
        accountId: Value(account),
      );

  test('same entity ID is isolated by composite account key', () async {
    await database.into(database.myWords).insert(word('account-a'));
    await database.into(database.myWords).insert(word('account-b'));
    final rows = await database.select(database.myWords).get();
    expect(
        rows.map((row) => row.accountId).toSet(), {'account-a', 'account-b'});
  });

  test('empty account scope is rejected', () async {
    await expectLater(
        database.into(database.myWords).insert(word('')), throwsA(anything));
  });

  test('delete is retained as a tombstone', () async {
    final deletedAt = DateTime.utc(2026, 1, 2);
    await database
        .into(database.myWords)
        .insert(word('account-a').copyWith(deletedAt: Value(deletedAt)));
    final row = await database.select(database.myWords).getSingle();
    expect(row.deletedAt?.toUtc(), deletedAt);
  });
}
