import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
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
    final reader = _CatalogQueryPort(Result.success(
      EspJpnEntryDetail(word: espWord, entries: [entry]),
    ));
    final conjugationQueryPort =
        _ConjugationQueryPort(Result.success(conjugation));

    final result = await _query(reader, conjugationQueryPort).execute(
      const WordDetailQuery(word: espWord),
    );
    final data = result.dataOrNull!.viewData as EspJpnWordDetailViewData;

    expect(data.word, espWord);
    expect(data.entries.single, same(entry));
    expect(data.conjugation, same(conjugation));
    expect(conjugationQueryPort.requests, [espWord]);
  });

  test('keeps EspJpn detail when conjugation is absent', () async {
    final result = await _query(
      _CatalogQueryPort(
          Result.success(EspJpnEntryDetail(word: espWord, entries: []))),
      _ConjugationQueryPort(Result.success(null)),
    ).execute(const WordDetailQuery(word: espWord));

    final data = result.dataOrNull!.viewData as EspJpnWordDetailViewData;
    expect(data.conjugation, isNull);
    expect(result.dataOrNull!.issue, isNull);
  });

  test('keeps EspJpn detail and records conjugation failure as an issue',
      () async {
    final error = BusinessRuleError(message: 'conjugation failed');
    final result = await _query(
      _CatalogQueryPort(
          Result.success(EspJpnEntryDetail(word: espWord, entries: []))),
      _ConjugationQueryPort(Result.failure(error)),
    ).execute(const WordDetailQuery(word: espWord));

    expect(result.dataOrNull!.viewData, isA<EspJpnWordDetailViewData>());
    expect(result.dataOrNull!.issue?.source, 'conjugation');
    expect(result.dataOrNull!.issue?.error, same(error));
  });

  test('maps JpnEsp detail without invoking the conjugation reader', () async {
    final entry = JpnEspEntry(dictionaryId: 2, wordId: 3, word: '日本語');
    final conjugationQueryPort = _ConjugationQueryPort(Result.success(null));
    final result = await _query(
      _CatalogQueryPort(
          Result.success(JpnEspEntryDetail(word: jpnWord, entries: [entry]))),
      conjugationQueryPort,
    ).execute(const WordDetailQuery(word: jpnWord));

    final data = result.dataOrNull!.viewData as JpnEspWordDetailViewData;
    expect(data.word, jpnWord);
    expect(data.entries.single, same(entry));
    expect(conjugationQueryPort.requests, isEmpty);
  });

  test('propagates primary catalog failure', () async {
    final error = BusinessRuleError(message: 'dictionary failed');
    final result = await _query(
      _CatalogQueryPort(Result.failure(error)),
      _ConjugationQueryPort(Result.success(null)),
    ).execute(const WordDetailQuery(word: espWord));

    expect(result.errorOrNull, same(error));
  });

  test('fails when CatalogQueryPort returns a different word identity',
      () async {
    const otherWord =
        CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 2);
    final result = await _query(
      _CatalogQueryPort(
          Result.success(EspJpnEntryDetail(word: otherWord, entries: []))),
      _ConjugationQueryPort(Result.success(null)),
    ).execute(const WordDetailQuery(word: espWord));

    expect(result.errorOrNull, isA<BusinessRuleError>());
  });

  test(
      'fails when CatalogQueryPort returns a detail variant for another catalog',
      () async {
    final result = await _query(
      _CatalogQueryPort(
          Result.success(EspJpnEntryDetail(word: jpnWord, entries: []))),
      _ConjugationQueryPort(Result.success(null)),
    ).execute(const WordDetailQuery(word: jpnWord));

    expect(result.errorOrNull, isA<BusinessRuleError>());
  });
}

LoadWordDetailQuery _query(
  CatalogQueryPort catalogQueryPort,
  ConjugationQueryPort conjugationQueryPort,
) =>
    LoadWordDetailQuery(catalogQueryPort, conjugationQueryPort);

class _CatalogQueryPort implements CatalogQueryPort {
  _CatalogQueryPort(this.result);
  final Result<CatalogEntryDetail> result;

  @override
  Future<Result<CatalogEntryDetail>> getEntryDetail(
          CatalogWordRef word) async =>
      result;
}

class _ConjugationQueryPort implements ConjugationQueryPort {
  _ConjugationQueryPort(this.result);
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
