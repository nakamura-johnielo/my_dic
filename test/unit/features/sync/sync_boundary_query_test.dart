import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('checkpoint boundary queries include equal timestamps', () {
    const remoteDaoPaths = [
      'lib/features/my_word/data/data_source/remote/myword/firebase_my_word_dao.dart',
      'lib/features/my_word/data/data_source/remote/status/firebase_my_word_status_dao.dart',
      'lib/core/infrastructure/database/firebase/daos/firebase_word_status_dao.dart',
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
}
