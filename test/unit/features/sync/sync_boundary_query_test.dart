import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('checkpoint queries retain their inclusive boundary', () {
    const remoteDaoPaths = [
      'lib/features/my_word/data/sync/remote/myword/firebase_my_word_dao.dart',
      'lib/features/my_word/data/sync/remote/status/firebase_my_word_status_dao.dart',
    ];
    const localDaoPaths = [
      'lib/features/my_word/data/data_source/local/drift_my_word_dao.dart',
      'lib/features/word_status/internal/infrastructure/esp_jpn/drift/esp_jpn_word_status_dao.dart',
    ];

    for (final path in remoteDaoPaths) {
      final source = File(path).readAsStringSync();
      expect(source.contains('isGreaterThanOrEqualTo:'), isTrue,
          reason: '$path must retry records exactly at the checkpoint.');
      expect(RegExp(r'\bisGreaterThan:').hasMatch(source), isFalse,
          reason: '$path must not exclude the checkpoint timestamp.');
    }

    for (final path in localDaoPaths) {
      final source = File(path).readAsStringSync();
      expect(source.contains('isBiggerOrEqualValue'), isTrue,
          reason: '$path must retry records exactly at the checkpoint.');
    }
  });

  test('word-status remote stores use an inclusive document-ID cursor', () {
    const statusDaoPaths = [
      'lib/features/word_status/internal/infrastructure/esp_jpn/firebase/firebase_esp_jpn_word_status_dao.dart',
      'lib/features/word_status/internal/infrastructure/jpn_esp/firebase/firebase_jpn_esp_word_status_dao.dart',
    ];

    for (final path in statusDaoPaths) {
      final source = File(path).readAsStringSync();
      expect(source.contains('Future<List<'), isTrue);
      expect(source.contains('.orderBy(FieldPath.documentId)'), isTrue);
      expect(source.contains('query = query.startAt(['), isTrue);
      expect(source.contains('Timestamp(cursor.seconds, cursor.nanoseconds)'),
          isTrue);
      expect(source.contains('cursor.documentId'), isTrue);
    }
  });
}
