import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('checkpoint queries retain their inclusive boundary', () {
    const remoteDaoPaths = [
      'lib/features/my_word/internal/infrastructure/my_word/firebase/firebase_my_word_dao.dart',
      'lib/features/my_word/internal/infrastructure/my_word_status/firebase/firebase_my_word_status_dao.dart',
    ];
    const myWordAdapterPath =
        'lib/features/my_word/internal/infrastructure/sync/my_word_dataset_sync_service.dart';
    const localDaoPaths = [
      'lib/features/word_status/internal/infrastructure/esp_jpn/drift/esp_jpn_word_status_dao.dart',
    ];

    for (final path in remoteDaoPaths) {
      final source = File(path).readAsStringSync();
      expect(source.contains('fetchUpdatedSince('), isTrue,
          reason: '$path must use the canonical inclusive query gateway.');
      expect(source.contains('since: lastSync'), isTrue,
          reason: '$path must forward the checkpoint without changing it.');
    }

    const updatedDocumentGatewayPath =
        'lib/app/bootstrap/firebase_providers.dart';
    final updatedDocumentGateway =
        File(updatedDocumentGatewayPath).readAsStringSync();
    expect(
      updatedDocumentGateway.contains(
        'isGreaterThanOrEqualTo: Timestamp.fromDate(since)',
      ),
      isTrue,
      reason: '$updatedDocumentGatewayPath must retry records exactly at the '
          'checkpoint.',
    );
    expect(
      RegExp(r'\bisGreaterThan:').hasMatch(updatedDocumentGateway),
      isFalse,
      reason: '$updatedDocumentGatewayPath must not exclude the checkpoint '
          'timestamp.',
    );

    for (final path in localDaoPaths) {
      final source = File(path).readAsStringSync();
      expect(source.contains('isBiggerOrEqualValue'), isTrue,
          reason: '$path must retry records exactly at the checkpoint.');
    }

    // MyWord has no local checkpoint query. Its adapter converts the durable
    // cursor into the timestamp consumed by the Firebase DAO above.
    final myWordAdapter = File(myWordAdapterPath).readAsStringSync();
    expect(myWordAdapter,
        contains('cursor == null ? MyDateTime.sentinel : _toDateTime(cursor)'));
    expect(
        myWordAdapter, contains('_remote.getMyWordsAfter(accountId, since)'));
    expect(myWordAdapter,
        contains('cursor.seconds * 1000000 + cursor.nanoseconds ~/ 1000'));
    expect(myWordAdapter, contains('isUtc: true'));
  });

  test('word-status remote stores use an inclusive document-ID cursor', () {
    const statusDaoPaths = [
      'lib/features/word_status/internal/infrastructure/esp_jpn/firebase/firebase_esp_jpn_word_status_dao.dart',
      'lib/features/word_status/internal/infrastructure/jpn_esp/firebase/firebase_jpn_esp_word_status_dao.dart',
    ];

    for (final path in statusDaoPaths) {
      final source = File(path).readAsStringSync();
      expect(source.contains('Future<List<'), isTrue);
      expect(source.contains('cursorSeconds: cursor?.seconds'), isTrue);
      expect(source.contains('cursorNanoseconds: cursor?.nanoseconds'), isTrue);
      expect(source.contains('cursorDocumentId: cursor?.documentId'), isTrue);
    }

    const gatewayPath = 'lib/app/bootstrap/firebase_providers.dart';
    final gateway = File(gatewayPath).readAsStringSync();
    expect(gateway.contains('.orderBy(updatedAtField)'), isTrue);
    expect(gateway.contains('.orderBy(FieldPath.documentId)'), isTrue);
    expect(gateway.contains('query = query.startAt(['), isTrue);
    expect(gateway.contains('Timestamp(cursorSeconds, cursorNanoseconds)'),
        isTrue);
    expect(gateway.contains('cursorDocumentId'), isTrue);
    expect(gateway.contains('startAfter('), isFalse,
        reason: '$gatewayPath must include the checkpoint row for retry.');
  });
}
