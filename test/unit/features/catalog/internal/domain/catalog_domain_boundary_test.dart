import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Catalog internal domain stays framework and consumer independent', () {
    final files = Directory('lib/features/catalog/internal/domain')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .toList();
    final source = files.map((file) => file.readAsStringSync()).join('\n');

    expect(files, isNotEmpty);
    for (final forbidden in [
      'package:flutter/',
      'flutter_riverpod',
      'package:drift/',
      'core/domain/',
      'core/shared/enums/',
      'features/search/',
      'features/quiz/',
      'features/word_page/',
      'features/ranking/',
      'features/word_status/',
    ]) {
      expect(source, isNot(contains(forbidden)), reason: forbidden);
    }
  });
}
