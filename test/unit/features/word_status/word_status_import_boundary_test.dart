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
}
