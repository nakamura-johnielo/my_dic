import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('legacy checkpoint queries include equal timestamps', () {
    const remoteDaoPaths = [
      'lib/features/my_word/data/sync/remote/myword/firebase_my_word_dao.dart',
      'lib/features/my_word/data/sync/remote/status/firebase_my_word_status_dao.dart',
    ];
    const localDaoPaths = [
      'lib/features/my_word/data/data_source/local/drift_my_word_dao.dart',
      'lib/core/infrastructure/database/drift/daos/esp_jpn/esp_jpn_word_status_dao.dart',
    ];

    for (final path in remoteDaoPaths) {
      final source = File(path).readAsStringSync();
      expect(
        source.contains('isGreaterThanOrEqualTo:'),
        isTrue,
        reason: '$path must retry records exactly at the checkpoint.',
      );
      expect(
        RegExp(r'\bisGreaterThan:').hasMatch(source),
        isFalse,
        reason: '$path must not exclude the checkpoint timestamp.',
      );
    }

    for (final path in localDaoPaths) {
      final source = File(path).readAsStringSync();
      expect(
        source.contains('isBiggerOrEqualValue'),
        isTrue,
        reason: '$path must retry records exactly at the checkpoint.',
      );
    }
  });

  test('status remote pages use an inclusive timestamp and document-ID cursor',
      () {
    const statusDaoPaths = [
      'lib/features/esp_jpn_word_status/data/sync/remote/firebase_word_status_dao.dart',
      'lib/features/jpn_esp_word_status/data/sync/remote/firebase_jpn_esp_word_status_dao.dart',
    ];

    for (final path in statusDaoPaths) {
      final source = File(path).readAsStringSync();
      expect(source.contains('Future<List<'), isTrue,
          reason: '$path must expose a one-shot page fetch.');
      expect(source.contains('.orderBy(FieldPath.documentId)'), isTrue,
          reason: '$path must deterministically tie-break equal timestamps.');
      expect(source.contains('query = query.startAt(['), isTrue,
          reason: '$path must include the checkpoint boundary.');
      expect(source.contains('Timestamp(cursor.seconds, cursor.nanoseconds)'),
          isTrue,
          reason: '$path must preserve the full checkpoint precision.');
      expect(source.contains('cursor.documentId'), isTrue,
          reason: '$path must continue from the checkpoint document ID.');
      expect(RegExp(r'\bisGreaterThan:').hasMatch(source), isFalse,
          reason:
              '$path must not exclude records at the checkpoint timestamp.');
    }
  });
}
