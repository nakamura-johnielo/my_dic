import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';

void main() {
  group('CatalogId', () {
    test('exposes the stable wire values', () {
      expect(
        CatalogId.values.map((catalogId) => catalogId.wireValue),
        ['esp-jpn-main', 'jpn-esp-main'],
      );
    });

    test('parses supported wire values and round-trips them', () {
      for (final catalogId in CatalogId.values) {
        expect(CatalogId.tryParse(catalogId.wireValue), catalogId);
      }
    });

    test('rejects unsupported wire values and enum names', () {
      expect(CatalogId.tryParse('unsupported-catalog'), isNull);
      expect(CatalogId.tryParse(CatalogId.espJpnMain.name), isNull);
    });
  });

  group('CatalogWordRef', () {
    test('has value equality and matching hashes for the same identity', () {
      const first = CatalogWordRef(
        catalogId: CatalogId.espJpnMain,
        wordId: 42,
      );
      const second = CatalogWordRef(
        catalogId: CatalogId.espJpnMain,
        wordId: 42,
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('does not equate a different catalog or word ID', () {
      const reference = CatalogWordRef(
        catalogId: CatalogId.espJpnMain,
        wordId: 42,
      );

      expect(
        reference,
        isNot(
          const CatalogWordRef(
            catalogId: CatalogId.jpnEspMain,
            wordId: 42,
          ),
        ),
      );
      expect(
        reference,
        isNot(
          const CatalogWordRef(
            catalogId: CatalogId.espJpnMain,
            wordId: 43,
          ),
        ),
      );
    });

    test('has a diagnostic string representation', () {
      expect(
        const CatalogWordRef(
          catalogId: CatalogId.espJpnMain,
          wordId: 42,
        ).toString(),
        'CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 42)',
      );
    });

    test('rejects non-positive word IDs in debug builds', () {
      expect(
        () => CatalogWordRef(
          catalogId: CatalogId.espJpnMain,
          wordId: 0,
        ),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => CatalogWordRef(
          catalogId: CatalogId.espJpnMain,
          wordId: -1,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('can be used as a Set and Map key', () {
      const first = CatalogWordRef(
        catalogId: CatalogId.espJpnMain,
        wordId: 42,
      );
      const equal = CatalogWordRef(
        catalogId: CatalogId.espJpnMain,
        wordId: 42,
      );

      final references = <CatalogWordRef>{};
      references
        ..add(first)
        ..add(equal);

      expect(references, hasLength(1));
      expect({first: 'entry'}[equal], 'entry');
    });
  });
}
