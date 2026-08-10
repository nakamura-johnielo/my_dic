import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sync application contract has no Firebase, Drift, or Flutter imports',
      () {
    final files = Directory('lib/features/sync/internal/application')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));
    for (final file in files) {
      final source = file.readAsStringSync();
      expect(source, isNot(contains('package:cloud_firestore/')),
          reason: file.path);
      expect(source, isNot(contains('package:firebase_')), reason: file.path);
      expect(source, isNot(contains('package:drift/')), reason: file.path);
      expect(source, isNot(contains('package:flutter/')), reason: file.path);
    }
  });
}
