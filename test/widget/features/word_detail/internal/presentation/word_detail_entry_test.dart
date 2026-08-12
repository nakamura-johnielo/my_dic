import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/application/query/query_issue.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/word_detail/internal/di/view_model_di.dart';
import 'package:my_dic/features/word_detail/internal/presentation/ui_model/word_detail_load_key.dart';
import 'package:my_dic/features/word_detail/internal/presentation/view_model/word_detail_view_model.dart';
import 'package:my_dic/features/word_detail/port/presentation_entry.dart';
import 'package:my_dic/features/word_detail/port/presentation_input.dart';
import 'package:my_dic/features/word_detail/port/query.dart';
import 'package:my_dic/features/word_status/port/presentation_entry.dart';

const _word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 1);
const _key = WordDetailLoadKey(_word);

void main() {
  testWidgets('loading renders no status entry', (tester) async {
    final loader = _DeferredLoader();
    final viewModel = WordDetailViewModel(loader);
    viewModel.initialize(_key);

    await _pump(tester, viewModel);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(DictionaryStatusButtonsEntry), findsNothing);
  });

  testWidgets('renders the WordDetail state and capability matrix',
      (tester) async {
    final cases = [
      _RenderCase(
        name: 'Esp ready with conjugation',
        result: _espResult(conjugation: _conjugation),
        hasStatus: true,
        hasQuizCapability: true,
      ),
      _RenderCase(
        name: 'Esp primary data with conjugation warning',
        result: _espResult(issue: _conjugationIssue),
        hasStatus: true,
        hasQuizCapability: false,
      ),
      _RenderCase(
        name: 'Esp normal no-conjugation',
        result: _espResult(),
        hasStatus: true,
        hasQuizCapability: false,
      ),
      _RenderCase(
        name: 'Jpn ready',
        result: WordDetailQueryResult(
          viewData: JpnEspWordDetailViewData(
            word: const CatalogWordRef(
              catalogId: CatalogId.jpnEspMain,
              wordId: 2,
            ),
            entries: [JpnEspEntry(dictionaryId: 1, wordId: 2, word: '話す')],
          ),
        ),
        word: const CatalogWordRef(
          catalogId: CatalogId.jpnEspMain,
          wordId: 2,
        ),
        hasStatus: true,
        hasQuizCapability: false,
      ),
      _RenderCase(
        name: 'Esp empty with warning',
        result: WordDetailQueryResult(
          viewData: EspJpnWordDetailViewData(word: _word, entries: const []),
          issue: _conjugationIssue,
        ),
        hasStatus: false,
        hasQuizCapability: false,
        isEmpty: true,
      ),
      _RenderCase(
        name: 'Jpn empty with warning',
        result: WordDetailQueryResult(
          viewData: JpnEspWordDetailViewData(
            word: const CatalogWordRef(
              catalogId: CatalogId.jpnEspMain,
              wordId: 3,
            ),
            entries: const [],
          ),
          issue: _conjugationIssue,
        ),
        word: const CatalogWordRef(
          catalogId: CatalogId.jpnEspMain,
          wordId: 3,
        ),
        hasStatus: false,
        hasQuizCapability: false,
        isEmpty: true,
      ),
    ];

    for (final item in cases) {
      final key = WordDetailLoadKey(item.word);
      final viewModel =
          WordDetailViewModel(_Loader(Result.success(item.result)));
      await viewModel.initialize(key);
      await _pump(tester, viewModel, word: item.word);

      expect(find.byType(DictionaryStatusButtonsEntry),
          item.hasStatus ? findsOneWidget : findsNothing,
          reason: item.name);
      expect(find.text('Conjugacion'),
          item.hasQuizCapability ? findsOneWidget : findsNothing,
          reason: item.name);
      expect(find.byType(FloatingActionButton),
          item.hasQuizCapability ? findsOneWidget : findsNothing,
          reason: item.name);
      if (item.isEmpty) {
        expect(find.text('No data available'), findsOneWidget,
            reason: item.name);
      }
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('failure renders no status entry', (tester) async {
    final viewModel = WordDetailViewModel(_Loader(
      Result.failure(BusinessRuleError(message: 'dictionary failed')),
    ));
    await viewModel.initialize(_key);

    await _pump(tester, viewModel);

    expect(find.byType(DictionaryStatusButtonsEntry), findsNothing);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('valid Esp primary data mounts status but no quiz capability',
      (tester) async {
    final viewModel = WordDetailViewModel(_Loader(Result.success(
      WordDetailQueryResult(
        viewData: EspJpnWordDetailViewData(
          word: _word,
          entries: [EspJpnEntry(dictionaryId: 1, word: 'hablar')],
        ),
      ),
    )));
    await viewModel.initialize(_key);

    await _pump(tester, viewModel);

    expect(find.byType(DictionaryStatusButtonsEntry), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
  });
}

Future<void> _pumpFor(
  WidgetTester tester,
  WordDetailViewModel viewModel,
  CatalogWordRef word,
) =>
    tester.pumpWidget(ProviderScope(
      overrides: [
        wordDetailViewModelProvider(WordDetailLoadKey(word))
            .overrideWith((ref) => viewModel),
      ],
      child: MaterialApp(
        home: WordDetailFragment(
          input: WordDetailPresentationInput(word: word),
          onOpenQuiz: (_, __) {},
        ),
      ),
    ));

Future<void> _pump(
  WidgetTester tester,
  WordDetailViewModel viewModel, {
  CatalogWordRef word = _word,
}) =>
    _pumpFor(tester, viewModel, word);

WordDetailQueryResult _espResult({
  CatalogConjugation? conjugation,
  QueryIssue? issue,
}) =>
    WordDetailQueryResult(
      viewData: EspJpnWordDetailViewData(
        word: _word,
        entries: [EspJpnEntry(dictionaryId: 1, word: 'hablar')],
        conjugation: conjugation,
      ),
      issue: issue,
    );

final _conjugation = CatalogConjugation(
  word: _word,
  conjugations: const {},
  participles: const CatalogParticiples(present: 'hablando', past: 'hablado'),
);
final _conjugationIssue = QueryIssue(
  source: 'conjugation',
  error: BusinessRuleError(message: 'conjugation unavailable'),
);

final class _RenderCase {
  const _RenderCase({
    required this.name,
    required this.result,
    this.word = _word,
    required this.hasStatus,
    required this.hasQuizCapability,
    this.isEmpty = false,
  });

  final String name;
  final WordDetailQueryResult result;
  final CatalogWordRef word;
  final bool hasStatus;
  final bool hasQuizCapability;
  final bool isEmpty;
}

final class _Loader implements ILoadWordDetailQuery {
  const _Loader(this.result);
  final Result<WordDetailQueryResult> result;
  @override
  Future<Result<WordDetailQueryResult>> execute(WordDetailQuery query) async =>
      result;
}

final class _DeferredLoader implements ILoadWordDetailQuery {
  final _result = Completer<Result<WordDetailQueryResult>>();

  @override
  Future<Result<WordDetailQueryResult>> execute(WordDetailQuery query) =>
      _result.future;
}
