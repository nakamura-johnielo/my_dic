import 'package:async/async.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/features/my_word/data/data_source/local/drift_my_word_dao.dart';
import 'package:my_dic/features/my_word/data/query/drift_my_word_item_query_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DatabaseProvider database;
  late MyWordDao dao;
  late DriftMyWordItemQueryRepository repository;

  setUp(() {
    database = DatabaseProvider.forTesting(NativeDatabase.memory());
    dao = MyWordDao(database);
    repository = DriftMyWordItemQueryRepository(dao);
  });

  tearDown(() => database.close());

  Future<void> insertWord(String accountId, {String word = 'casa'}) {
    return database.into(database.myWords).insert(
          MyWordsCompanion.insert(
            myWordId: 'same-uuid',
            word: word,
            contents: const Value('home'),
            editAt: '2026-08-09T00:00:00.000Z',
            accountId: Value(accountId),
          ),
        );
  }

  Future<void> insertStatus(
    String accountId, {
    int learned = 0,
    int bookmarked = 0,
    int hasNote = 0,
  }) {
    return database.into(database.myWordStatus).insert(
          MyWordStatusCompanion.insert(
            myWordId: 'same-uuid',
            isLearned: Value(learned),
            isBookmarked: Value(bookmarked),
            hasNote: Value(hasNote),
            editAt: '2026-08-09T00:00:00.000Z',
            accountId: Value(accountId),
          ),
        );
  }

  test('projects initial data and normalizes a missing status without writes',
      () async {
    await insertWord('account-a');

    final projection =
        await repository.watchItem('same-uuid', accountId: 'account-a').first;

    expect(projection, isNot(equals(null)));
    expect(projection!.word.word, 'casa');
    expect(projection.status.isLearned, isFalse);
    expect(projection.status.isBookmarked, isFalse);
    expect(projection.status.hasNote, isFalse);
    expect(await database.select(database.myWordStatus).get(), isEmpty);
    expect(await database.select(database.syncOutbox).get(), isEmpty);
  });

  test('normalizes a deleted status to false without inserting a replacement',
      () async {
    await insertWord('account-a');
    await insertStatus('account-a', learned: 1, bookmarked: 1, hasNote: 1);
    await (database.update(database.myWordStatus)
          ..where((t) =>
              t.accountId.equals('account-a') & t.myWordId.equals('same-uuid')))
        .write(MyWordStatusCompanion(deletedAt: Value(DateTime.utc(2026))));

    final projection =
        await repository.watchItem('same-uuid', accountId: 'account-a').first;

    expect(projection!.status.isLearned, isFalse);
    expect(projection.status.isBookmarked, isFalse);
    expect(projection.status.hasNote, isFalse);
    expect(await database.select(database.myWordStatus).get(), hasLength(1));
    expect(await database.select(database.syncOutbox).get(), isEmpty);
  });

  test('emits status and word edits, then null for a word tombstone', () async {
    await insertWord('account-a');
    final queue =
        StreamQueue(repository.watchItem('same-uuid', accountId: 'account-a'));
    addTearDown(queue.cancel);

    final initial = await queue.next;
    expect(initial!.word.word, 'casa');
    await insertStatus('account-a', learned: 1, hasNote: 1);
    final statusChanged = await queue.next;
    expect(statusChanged!.status.isLearned, isTrue);
    expect(statusChanged.status.hasNote, isTrue);

    await dao.updateMyWordWithRevision(
      id: 'same-uuid',
      word: 'hogar',
      contents: 'edited home',
      editAt: '2026-08-10T00:00:00.000Z',
      accountId: 'account-a',
    );
    final wordChanged = await queue.next;
    expect(wordChanged!.word.word, 'hogar');
    expect(wordChanged.word.contents, 'edited home');

    await dao.tombstoneMyWord(
      'same-uuid',
      '2026-08-11T00:00:00.000Z',
      'account-a',
    );
    expect(await queue.next, equals(null));
  });

  test('isolates guest and signed-in accounts sharing one UUID', () async {
    await insertWord(guestAccountScope, word: 'guest');
    await insertWord('account-a', word: 'alpha');
    await insertWord('account-b', word: 'beta');
    await insertStatus(guestAccountScope, learned: 1);
    await insertStatus('account-a', bookmarked: 1);
    await insertStatus('account-b', hasNote: 1);

    final guest = await repository
        .watchItem('same-uuid', accountId: guestAccountScope)
        .first;
    final a =
        await repository.watchItem('same-uuid', accountId: 'account-a').first;
    final b =
        await repository.watchItem('same-uuid', accountId: 'account-b').first;

    expect(guest!.word.word, 'guest');
    expect(guest.status.isLearned, isTrue);
    expect(a!.word.word, 'alpha');
    expect(a.status.isBookmarked, isTrue);
    expect(b!.word.word, 'beta');
    expect(b.status.hasNote, isTrue);
    expect(a.status.isLearned, isFalse);
    expect(b.status.isBookmarked, isFalse);
  });
}
