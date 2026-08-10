import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:my_dic/features/catalog/port/presentation_dependencies.dart';
import 'package:my_dic/features/word_detail/port/presentation_entry.dart';
import 'package:my_dic/features/word_detail/port/presentation_input.dart';
import 'package:my_dic/features/word_status/port/presentation_entry.dart';

const _word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 7);

void main() {
  testWidgets(
      'Gate B: primary data survives conjugation failure without quiz UI',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        catalogReaderDependencyProvider.overrideWithValue(_Catalog()),
        conjugationReaderDependencyProvider.overrideWithValue(_Conjugation()),
      ],
      child: MaterialApp(
        home: WordDetailFragment(
          input: const WordDetailPresentationInput(word: _word),
          onOpenQuiz: (_, __) {},
        ),
      ),
    ));
    await tester.pump();
    await tester.pump();

    expect(find.text('hablar'), findsWidgets);
    expect(find.byType(DictionaryStatusButtonsEntry), findsOneWidget);
    expect(find.text('Conjugacion'), findsNothing);
    expect(find.byType(FloatingActionButton), findsNothing);
  });
}

final class _Catalog implements CatalogReader {
  @override
  Future<Result<CatalogEntryDetail>> getEntryDetail(
          CatalogWordRef word) async =>
      Result.success(EspJpnEntryDetail(
        word: _word,
        entries: [EspJpnEntry(dictionaryId: 1, word: 'hablar')],
      ));
}

final class _Conjugation implements ConjugationReader {
  @override
  Future<Result<CatalogConjugation?>> getConjugation(
          CatalogWordRef word) async =>
      Result.failure(BusinessRuleError(message: 'conjugation unavailable'));

  @override
  Future<Result<bool>> hasConjugation(CatalogWordRef word) async =>
      const Result.success(false);
}
