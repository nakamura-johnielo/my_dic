import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_reader.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/conjugation_reader.dart';
import 'package:my_dic/features/catalog/port/model/catalog_conjugation.dart';
import 'package:my_dic/features/catalog/port/model/catalog_entry_detail.dart';
import 'package:my_dic/features/catalog/port/model/esp_jpn_entry.dart';
import 'package:my_dic/features/catalog/port/model/jpn_esp_entry.dart';
import 'package:my_dic/features/word_detail/internal/application/query/load_word_detail_query.dart';
import 'package:my_dic/features/word_detail/port/query.dart';

void main() {
  const espWord = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 1);
  const jpnWord = CatalogWordRef(catalogId: CatalogId.jpnEspMain, wordId: 3);

  test('maps EspJpn detail and fetches its optional conjugation', () async {
    final entry = EspJpnEntry(dictionaryId: 1, word: 'hablar');
    final conjugation = CatalogConjugation(
      word: espWord,
      conjugations: const {},
      participles:
          const CatalogParticiples(present: 'hablando', past: 'hablado'),
    );
    final reader = _CatalogReaderPort(Result.success(
      EspJpnEntryDetail(word: espWord, entries: [entry]),
    ));
    final conjugationReaderPort = _ConjugationReaderPort(Result.success(conjugation));

    final result = await _query(reader, conjugationReaderPort).execute(
      const WordDetailQuery(word: espWord),
    );
    final data = result.dataOrNull!.viewData as EspJpnWordDetailViewData;

    expect(data.word, espWord);
    expect(data.entries.single, same(entry));
    expect(data.conjugation, same(conjugation));
    expect(conjugationReaderPort.requests, [espWord]);
  });

  test('keeps EspJpn detail when conjugation is absent', () async {
    final result = await _query(
      _CatalogReaderPort(
          Result.success(EspJpnEntryDetail(word: espWord, entries: []))),
      _ConjugationReaderPort(Result.success(null)),
    ).execute(const WordDetailQuery(word: espWord));

    final data = result.dataOrNull!.viewData as EspJpnWordDetailViewData;
    expect(data.conjugation, isNull);
    expect(result.dataOrNull!.issue, isNull);
  });

  test('keeps EspJpn detail and records conjugation failure as an issue',
      () async {
    final error = BusinessRuleError(message: 'conjugation failed');
    final result = await _query(
      _CatalogReaderPort(
          Result.success(EspJpnEntryDetail(word: espWord, entries: []))),
      _ConjugationReaderPort(Result.failure(error)),
    ).execute(const WordDetailQuery(word: espWord));

    expect(result.dataOrNull!.viewData, isA<EspJpnWordDetailViewData>());
    expect(result.dataOrNull!.issue?.source, 'conjugation');
    expect(result.dataOrNull!.issue?.error, same(error));
  });

  test('maps JpnEsp detail without invoking the conjugation reader', () async {
    final entry = JpnEspEntry(dictionaryId: 2, wordId: 3, word: '日本語');
    final conjugationReaderPort = _ConjugationReaderPort(Result.success(null));
    final result = await _query(
      _CatalogReaderPort(
          Result.success(JpnEspEntryDetail(word: jpnWord, entries: [entry]))),
      conjugationReaderPort,
    ).execute(const WordDetailQuery(word: jpnWord));

    final data = result.dataOrNull!.viewData as JpnEspWordDetailViewData;
    expect(data.word, jpnWord);
    expect(data.entries.single, same(entry));
    expect(conjugationReaderPort.requests, isEmpty);
  });

  test('propagates primary catalog failure', () async {
    final error = BusinessRuleError(message: 'dictionary failed');
    final result = await _query(
      _CatalogReaderPort(Result.failure(error)),
      _ConjugationReaderPort(Result.success(null)),
    ).execute(const WordDetailQuery(word: espWord));

    expect(result.errorOrNull, same(error));
  });

  test('fails when CatalogReaderPort returns a different word identity', () async {
    const otherWord =
        CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 2);
    final result = await _query(
      _CatalogReaderPort(
          Result.success(EspJpnEntryDetail(word: otherWord, entries: []))),
      _ConjugationReaderPort(Result.success(null)),
    ).execute(const WordDetailQuery(word: espWord));

    expect(result.errorOrNull, isA<BusinessRuleError>());
  });

  test('fails when CatalogReaderPort returns a detail variant for another catalog',
      () async {
    final result = await _query(
      _CatalogReaderPort(
          Result.success(EspJpnEntryDetail(word: jpnWord, entries: []))),
      _ConjugationReaderPort(Result.success(null)),
    ).execute(const WordDetailQuery(word: jpnWord));

    expect(result.errorOrNull, isA<BusinessRuleError>());
  });
}

LoadWordDetailQuery _query(
  CatalogReaderPort catalogReaderPort,
  ConjugationReaderPort conjugationReaderPort,
) =>
    LoadWordDetailQuery(catalogReaderPort, conjugationReaderPort);

class _CatalogReaderPort implements CatalogReaderPort {
  _CatalogReaderPort(this.result);
  final Result<CatalogEntryDetail> result;

  @override
  Future<Result<CatalogEntryDetail>> getEntryDetail(
          CatalogWordRef word) async =>
      result;
}

class _ConjugationReaderPort implements ConjugationReaderPort {
  _ConjugationReaderPort(this.result);
  final Result<CatalogConjugation?> result;
  final requests = <CatalogWordRef>[];

  @override
  Future<Result<CatalogConjugation?>> getConjugation(
      CatalogWordRef word) async {
    requests.add(word);
    return result;
  }

  @override
  Future<Result<bool>> hasConjugation(CatalogWordRef word) =>
      throw UnimplementedError();
}
