import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('domain and application remain independent from UI and infrastructure',
      () {
    final source = Directory('lib/features/word_status')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .where((file) =>
            file.path.contains(
                '${Platform.pathSeparator}domain${Platform.pathSeparator}') ||
            file.path.contains(
              '${Platform.pathSeparator}application${Platform.pathSeparator}',
            ))
        .map((file) => file.readAsStringSync())
        .join('\n');

    final forbiddenImports = RegExp(
      r'''import\s+['"]package:(?:flutter(?:_riverpod)?|drift|firebase_[^/]+)\/''',
    );

    expect(forbiddenImports.hasMatch(source), isFalse);
    expect(source, isNot(contains('SyncDataset')));
  });

  test('legacy public files stay deleted and composition stays SDK-free', () {
    for (final path in [
      'lib/features/word_status/port/repository.dart',
      'lib/features/word_status/port/commands.dart',
      'lib/features/word_status/port/guest_migration.dart',
    ]) {
      expect(File(path).existsSync(), isFalse, reason: path);
    }

    final composition =
        File('lib/features/word_status/port/composition.dart').readAsStringSync();
    expect(composition, isNot(contains('cloud_firestore')));
    expect(composition, isNot(contains('FirebaseFirestore')));
    expect(
      composition,
      contains('internal/composition/word_status_composition_factory.dart'),
    );
  });
}
