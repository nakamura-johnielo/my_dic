import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import '../../../../../support/database/schema_snapshot.dart';

void main() {
  test('fresh v7 schema preserves the physical and emitted table contract',
      () async {
    final database = DatabaseProvider.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    final snapshot = await captureSchemaSnapshot(database);
    const expectedTables = {
      'conjugations',
      'dictionaries',
      'es_en_conjugacions',
      'examples',
      'idioms',
      'jpn_esp_dictionaries',
      'jpn_esp_examples',
      'jpn_esp_word_status',
      'jpn_esp_words',
      'my_word_status',
      'my_words',
      'part_of_speech_lists',
      'rankings',
      'supplements',
      'sync_checkpoints',
      'sync_outbox',
      'user_profiles',
      'word_status',
      'words',
    };
    expect(snapshot.tables.keys.toSet(), expectedTables);
    expect(snapshot.emittedTableNames.toSet(), expectedTables);

    expect(
      snapshot.indexes.map((index) => index.name),
      [
        'sync_outbox_entity_idx',
        'sync_outbox_lease_idx',
        'sync_outbox_pending_idx',
      ],
    );

    final myWords = snapshot.tables['my_words']!;
    expect(myWords.columns.map((column) => column.name), [
      'my_word_id',
      'word',
      'contents',
      'edit_at',
      'account_id',
      'local_revision',
      'remote_revision',
      'deleted_at',
      'last_mutation_id',
    ]);
    expect(myWords.columns.map((column) => column.primaryKeyOrder),
        [2, 0, 0, 0, 1, 0, 0, 0, 0]);
    expect(myWords.createSql, contains("CHECK(account_id <> '')"));
    expect(myWords.columns[5].defaultValue, '0');

    final wordStatus = snapshot.tables['word_status']!;
    expect(wordStatus.foreignKeys, hasLength(1));
    expect(wordStatus.foreignKeys.single.table, 'words');
    expect(wordStatus.foreignKeys.single.from, 'word_id');
    expect(wordStatus.foreignKeys.single.to, 'word_id');
    expect(wordStatus.foreignKeys.single.onDelete, 'CASCADE');

    final outbox = snapshot.tables['sync_outbox']!;
    expect(
        outbox.columns.map((column) => column.name),
        containsAll([
          'mutation_id',
          'account_id',
          'dataset',
          'state',
          'attempt_count',
          'next_attempt_at',
          'lease_token',
          'lease_until',
          'created_at',
          'client_updated_at',
        ]));
    expect(outbox.columns.first.primaryKeyOrder, 1);
  });
}
