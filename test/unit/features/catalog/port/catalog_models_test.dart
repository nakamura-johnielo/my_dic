import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/model/catalog_conjugation.dart';
import 'package:my_dic/features/catalog/port/model/catalog_entry_detail.dart';
import 'package:my_dic/features/catalog/port/model/esp_jpn_entry.dart';
import 'package:my_dic/features/catalog/port/model/jpn_esp_entry.dart';

void main() {
  const word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 7);

  group('Catalog entry detail models', () {
    test('preserve complete immutable EspJpn entry content', () {
      final examples = [
        const EspJpnExample(exampleId: 2, japanese: '話す', espanol: 'hablar'),
      ];
      final idioms = [
        const EspJpnIdiom(
          idiomId: 3,
          idiom: 'hablar claro',
          description: 'speak plainly',
        ),
      ];
      final supplements = [
        const CatalogSupplement(supplementId: 4, supplement: 'grammar'),
      ];
      final entry = EspJpnEntry(
        dictionaryId: 1,
        word: 'hablar',
        headword: 'hablar',
        content: '<p>to speak</p>',
        origin: 'Latin',
        examples: examples,
        idioms: idioms,
        supplements: supplements,
      );
      final detail = EspJpnEntryDetail(word: word, entries: [entry]);

      examples.clear();
      idioms.clear();
      supplements.clear();

      expect(detail.word, word);
      expect(detail.entries.single, entry);
      expect(entry.examples, hasLength(1));
      expect(entry.idioms, hasLength(1));
      expect(entry.supplements, hasLength(1));
      expect(() => detail.entries.add(entry), throwsUnsupportedError);
      expect(
        () => entry.examples.add(
          const EspJpnExample(exampleId: 5, japanese: '言う', espanol: 'decir'),
        ),
        throwsUnsupportedError,
      );
    });

    test('preserve complete immutable JpnEsp entry content', () {
      final examples = [
        const JpnEspExample(
          exampleId: 2,
          japanese: '話す',
          espanol: 'hablar',
          espanolHtml: '<b>hablar</b>',
        ),
      ];
      final entry = JpnEspEntry(
        dictionaryId: 1,
        wordId: 7,
        word: '話す',
        headword: 'はなす',
        content: '<p>hablar</p>',
        examples: examples,
      );
      final detail = JpnEspEntryDetail(
        word: const CatalogWordRef(
          catalogId: CatalogId.jpnEspMain,
          wordId: 7,
        ),
        entries: [entry],
      );

      examples.clear();

      expect(detail.entries.single.wordId, 7);
      expect(
          detail.entries.single.examples.single.espanolHtml, '<b>hablar</b>');
      expect(() => entry.examples.clear(), throwsUnsupportedError);
    });

    test('use value equality rather than collection identity', () {
      final first = EspJpnEntryDetail(
        word: word,
        entries: [EspJpnEntry(dictionaryId: 1, word: 'hablar')],
      );
      final second = EspJpnEntryDetail(
        word: word,
        entries: [EspJpnEntry(dictionaryId: 1, word: 'hablar')],
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });
  });

  group('Catalog conjugation models', () {
    test('defensively copies maps and exposes value semantics', () {
      final forms = {CatalogSubject.yo: 'hablo'};
      final conjugations = {
        CatalogMoodTense.indicativePresent:
            CatalogTenseConjugation(forms: forms),
      };
      final value = CatalogConjugation(
        word: word,
        conjugations: conjugations,
        participles:
            const CatalogParticiples(present: 'hablando', past: 'hablado'),
      );

      forms[CatalogSubject.tu] = 'hablas';
      conjugations.clear();

      expect(value.conjugations, hasLength(1));
      expect(
        value.conjugations[CatalogMoodTense.indicativePresent]![
            CatalogSubject.yo],
        'hablo',
      );
      expect(
        value.conjugations[CatalogMoodTense.indicativePresent]![
            CatalogSubject.tu],
        isNull,
      );
      expect(() => value.conjugations.clear(), throwsUnsupportedError);
      expect(
        () => value.conjugations[CatalogMoodTense.imperative] =
            CatalogTenseConjugation(forms: const {}),
        throwsUnsupportedError,
      );
    });
  });
}
