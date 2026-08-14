import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/catalog/port/composition.dart';

void main() {
  test('real dictionary asset is readable through focused Catalog ports',
      () async {
    final directory = await Directory.systemTemp.createTemp(
      'my_dic_catalog_asset_',
    );
    addTearDown(() => directory.delete(recursive: true));
    final fixture = await File('assets/mydic.db').copy(
      '${directory.path}${Platform.pathSeparator}mydic.db',
    );
    final database = DatabaseProvider.forTesting(NativeDatabase(fixture));
    addTearDown(database.close);

    final ports = createCatalogComposition(
      dependencies: CatalogDependencies(database: database),
    );
    final espWordId = (await database.customSelect('''
      SELECT w.word_id AS word_id
      FROM words w
      INNER JOIN dictionaries d ON d.word_id = w.word_id
      ORDER BY w.word_id
      LIMIT 1
    ''').getSingle()).read<int>('word_id');
    final jpnWordId = (await database.customSelect('''
      SELECT w.jpn_esp_word_id AS word_id
      FROM jpn_esp_words w
      INNER JOIN jpn_esp_dictionaries d
        ON d.jpn_esp_word_id = w.jpn_esp_word_id
      ORDER BY w.jpn_esp_word_id
      LIMIT 1
    ''').getSingle()).read<int>('word_id');

    final espWord = CatalogWordRef(
      catalogId: CatalogId.espJpnMain,
      wordId: espWordId,
    );
    final jpnWord = CatalogWordRef(
      catalogId: CatalogId.jpnEspMain,
      wordId: jpnWordId,
    );

    expect((await ports.entryDetail.readEntryDetail(espWord)).dataOrNull,
        isA<EspJpnEntryDetail>());
    expect((await ports.entryDetail.readEntryDetail(jpnWord)).dataOrNull,
        isA<JpnEspEntryDetail>());
    expect(
      (await ports.semanticEntryDetail.readSemanticEntryDetail(espWord))
          .dataOrNull,
      isA<CatalogSemanticEspJpnEntryDetail>(),
    );

    final ranked = await ports.rankedEntries.readRankedEntries(
      CatalogRankedEntryFeedQuery(offset: 0, size: 1),
    );
    expect(ranked.dataOrNull?.items, isNotEmpty);
  });
}
