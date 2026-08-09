import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/enums/sync_dataset.dart';
import 'package:my_dic/features/my_word/data/sync/remote/myword/firebase_my_word_dto.dart';
import 'package:my_dic/features/my_word/data/sync/remote/status/firebase_my_word_status_dto.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('schema and sync identifiers retain the Stage 0 baseline', () async {
    final database = DatabaseProvider.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    expect(database.schemaVersion, 7);
    final definitions = await database.customSelect('''
      SELECT name, sql FROM sqlite_master
      WHERE type = 'table' AND name IN
        ('my_words', 'my_word_status', 'jpn_esp_words',
         'jpn_esp_word_status', 'word_status')
    ''').get();
    final schema = {
      for (final row in definitions)
        row.read<String>('name'): row.read<String>('sql'),
    };

    expect(
        schema.keys,
        containsAll([
          'my_words',
          'my_word_status',
          'jpn_esp_words',
          'jpn_esp_word_status',
          'word_status'
        ]));
    expect(schema['my_words'],
        allOf(contains('my_word_id'), contains('account_id')));
    expect(
        schema['my_word_status'],
        allOf(contains('my_word_id'), contains('is_learned'),
            contains('is_bookmarked')));
    expect(schema['jpn_esp_words'],
        allOf(contains('jpn_esp_word_id'), contains('word')));
    expect(
        schema['jpn_esp_word_status'],
        allOf(contains('jpn_esp_word_id'), contains('is_learned'),
            contains('has_note')));
    expect(
        schema['word_status'],
        allOf(contains('word_id'), contains('is_learned'),
            contains('is_bookmarked'), contains('has_note')));

    expect(SyncDataset.myWords.stableId, 'my_words');
    expect(SyncDataset.myWordStatus.stableId, 'my_word_status');
    expect(MyWordDTO.collectionName, 'MyWords');
    expect(MyWordDTO.fieldMyWordId, 'wordId');
    expect(MyWordStatusDTO.collectionName, 'MyWordStatus');
    expect(MyWordStatusDTO.fieldMyWordId, 'myWordId');
  });
}
