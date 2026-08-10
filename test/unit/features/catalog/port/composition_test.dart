import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog_reader.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/catalog/port/composition.dart';
import 'package:my_dic/features/catalog/port/conjugation_reader.dart';
import 'package:my_dic/features/catalog/port/model/catalog_conjugation.dart';
import 'package:my_dic/features/catalog/port/model/catalog_entry_detail.dart';
import 'package:my_dic/features/catalog/port/raw_quiz_candidate_reader.dart';
import 'package:my_dic/features/catalog/port/raw_search_reader.dart';

void main() {
  test('composition is a pure holder for Catalog public capabilities', () {
    final reader = _CatalogReader();
    final conjugations = _ConjugationReader();
    final rawSearch = _RawSearchReader();
    final rawQuiz = _RawQuizReader();

    final composition = CatalogComposition(
      catalogReader: reader,
      conjugationReader: conjugations,
      rawSearchReader: rawSearch,
      rawQuizCandidateReader: rawQuiz,
    );

    expect(composition.catalogReader, same(reader));
    expect(composition.conjugationReader, same(conjugations));
    expect(composition.rawSearchReader, same(rawSearch));
    expect(composition.rawQuizCandidateReader, same(rawQuiz));
  });
}

final class _RawSearchReader implements CatalogRawSearchReader {
  @override
  Future<Map<CatalogWordRef, String>> getHeadwords(
          Iterable<CatalogWordRef> words) =>
      throw UnimplementedError();
  @override
  Future<Map<CatalogWordRef, String>> getMeanings(
          Iterable<CatalogWordRef> words) =>
      throw UnimplementedError();
  @override
  Future<Map<CatalogWordRef, int>> getRankingMetadata(
          Iterable<CatalogWordRef> words) =>
      throw UnimplementedError();
  @override
  Future<List<CatalogConjugationRawHit>> searchConjugations(
          CatalogRawSearchQuery query) =>
      throw UnimplementedError();
  @override
  Future<List<CatalogPrimaryRawHit>> searchPrimary(
          CatalogRawSearchQuery query) =>
      throw UnimplementedError();
}

final class _RawQuizReader implements CatalogRawQuizCandidateReader {
  @override
  Future<Map<CatalogWordRef, String>> getQuizCandidateHeadwords(
          Iterable<CatalogWordRef> words) =>
      throw UnimplementedError();
  @override
  Future<Map<CatalogWordRef, String>> getQuizCandidateMeanings(
          Iterable<CatalogWordRef> words) =>
      throw UnimplementedError();
  @override
  Future<Map<CatalogWordRef, int>> getQuizCandidateRankingMetadata(
          Iterable<CatalogWordRef> words) =>
      throw UnimplementedError();
  @override
  Future<List<CatalogRawQuizCandidateHit>> searchQuizCandidates(
          CatalogRawQuizCandidateQuery query) =>
      throw UnimplementedError();
}

final class _CatalogReader implements CatalogReader {
  @override
  Future<Result<CatalogEntryDetail>> getEntryDetail(CatalogWordRef word) =>
      throw UnimplementedError();
}

final class _ConjugationReader implements ConjugationReader {
  @override
  Future<Result<CatalogConjugation?>> getConjugation(CatalogWordRef word) =>
      throw UnimplementedError();

  @override
  Future<Result<bool>> hasConjugation(CatalogWordRef word) =>
      throw UnimplementedError();
}
