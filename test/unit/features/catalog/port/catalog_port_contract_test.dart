import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_reader.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/conjugation_reader.dart';
import 'package:my_dic/features/catalog/port/model/catalog_conjugation.dart';
import 'package:my_dic/features/catalog/port/model/catalog_entry_detail.dart';

void main() {
  test('readers accept only CatalogWordRef and return typed Catalog results',
      () async {
    final catalogReader = _CatalogReader();
    final conjugationReader = _ConjugationReader();
    const word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 1);

    expect(await catalogReader.getEntryDetail(word),
        isA<Success<CatalogEntryDetail>>());
    expect(
      await conjugationReader.getConjugation(word),
      isA<Success<CatalogConjugation?>>(),
    );
    expect(await conjugationReader.hasConjugation(word), isA<Success<bool>>());
  });

  test('public Catalog port is independent of legacy and presentation layers',
      () {
    final imports = Directory('lib/features/catalog/port')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        // This is an app-composition seam, not a model/reader port contract.
        // It deliberately exposes Riverpod providers for presentation owners.
        .where((file) => !file.path.endsWith('presentation_dependencies.dart'))
        .expand((file) => RegExp(
              r'''^\s*(?:import|export|part)\s+['"]([^'"]+)['"]''',
              multiLine: true,
            )
                .allMatches(file.readAsStringSync())
                .map((match) => match.group(1)!))
        .join('\n');

    for (final forbidden in [
      'core/domain/',
      'features/search',
      'features/word_detail',
      'features/quiz',
      'features/ranking',
      'features/word_status',
      'package:flutter/',
      'flutter_riverpod',
      'package:drift/',
      'cloud_firestore',
    ]) {
      expect(imports, isNot(contains(forbidden)), reason: forbidden);
    }
  });
}

final class _CatalogReader implements CatalogReader {
  @override
  Future<Result<CatalogEntryDetail>> getEntryDetail(
          CatalogWordRef word) async =>
      Result.success(EspJpnEntryDetail(word: word, entries: const []));
}

final class _ConjugationReader implements ConjugationReader {
  @override
  Future<Result<CatalogConjugation?>> getConjugation(
          CatalogWordRef word) async =>
      const Result.success(null);

  @override
  Future<Result<bool>> hasConjugation(CatalogWordRef word) async =>
      const Result.success(false);
}
