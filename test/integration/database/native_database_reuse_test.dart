import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

  group('native asset upgrade and reuse', () {
    late Directory temporaryDirectory;

    setUp(() async {
      temporaryDirectory = await Directory.systemTemp.createTemp(
        'my_dic_native_database_reuse_',
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(pathProviderChannel, (call) async {
        if (call.method == 'getApplicationSupportDirectory') {
          return temporaryDirectory.path;
        }
        return null;
      });
    });

    tearDown(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(pathProviderChannel, null);
      await temporaryDirectory.delete(recursive: true);
    });

    test(
        'uses the real conjugation asset once during v3 upgrade and reopens it',
        () async {
      final fixture = File('${temporaryDirectory.path}${Platform.pathSeparator}'
          'legacy_kotobank.sqlite');
      await File('assets/kotobank.db').copy(fixture.path);

      final legacy = sqlite3.open(fixture.path);
      try {
        legacy.execute('PRAGMA user_version = 3;');
      } finally {
        legacy.dispose();
      }

      final database = DatabaseProvider.forTesting(
        NativeDatabase(fixture),
        seedEsEnConjugacionsOnUpgrade: true,
      );
      try {
        final count = await database
            .customSelect(
              'SELECT COUNT(*) AS count FROM es_en_conjugacions;',
            )
            .getSingle();
        expect(count.read<int>('count'), 6517);

        await database.customStatement(
          "INSERT INTO my_words "
          "(my_word_id, word, edit_at, account_id, local_revision) VALUES "
          "('native-reopen-sentinel', 'hola', '2026-01-01T00:00:00Z', "
          "'native-test', 0);",
        );
      } finally {
        await database.close();
      }

      final copiedSeed =
          File('${temporaryDirectory.path}${Platform.pathSeparator}'
              'es_en_conjugacions.db');
      expect(copiedSeed.existsSync(), isFalse,
          reason: 'the temporary ATTACH database must be detached and deleted');

      final reopened = DatabaseProvider.forTesting(NativeDatabase(fixture));
      try {
        final count = await reopened
            .customSelect(
              'SELECT COUNT(*) AS count FROM es_en_conjugacions;',
            )
            .getSingle();
        final sentinel = await reopened
            .customSelect(
              "SELECT word FROM my_words WHERE account_id = 'native-test' "
              "AND my_word_id = 'native-reopen-sentinel';",
            )
            .getSingle();
        expect(count.read<int>('count'), 6517,
            reason: 'reopen must not seed a second copy');
        expect(sentinel.read<String>('word'), 'hola');
      } finally {
        await reopened.close();
      }
    });
  });
}
