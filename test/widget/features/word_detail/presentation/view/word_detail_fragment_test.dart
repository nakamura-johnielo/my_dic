import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/app/bootstrap/session_composition.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/word_detail/internal/di/view_model_di.dart';
import 'package:my_dic/features/word_detail/internal/presentation/ui_model/word_detail_load_key.dart';
import 'package:my_dic/features/word_detail/internal/presentation/view_model/word_detail_view_model.dart';
import 'package:my_dic/features/word_detail/port/presentation_entry.dart';
import 'package:my_dic/features/word_detail/port/presentation_input.dart';
import 'package:my_dic/features/word_detail/port/query.dart';
import 'package:my_dic/features/word_status/port/presentation_entry.dart';
import 'package:my_dic/features/word_status/presentation/status_button.dart';

void main() {
  const word = CatalogWordRef(
    catalogId: CatalogId.espJpnMain,
    wordId: 1,
  );
  const key = WordDetailLoadKey(word);
  const sessionScope = SessionScopeKey(accountScope: 'test-account', epoch: 1);

  testWidgets('updates multi-tab content when the word detail query completes',
      (tester) async {
    final loader = _DeferredLoader();
    final viewModel = WordDetailViewModel(loader);
    final loading = viewModel.initialize(key);

    final container = ProviderContainer(overrides: [
      wordDetailViewModelProvider(key).overrideWith((ref) => viewModel),
      sessionScopeKeyProvider.overrideWithValue(sessionScope),
      dictionaryStatusButtonsViewModelProvider(
        const WordStatusEntryKey(scope: sessionScope, word: word),
      ).overrideWith((ref) => const _NoopWordStatusViewModel()),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: WordDetailFragment(
            input: WordDetailPresentationInput(word: word),
            onOpenQuiz: (_, __) {},
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    loader.complete(Result.success(WordDetailQueryResult(
      viewData: EspJpnWordDetailViewData(
          word: word,
          entries: [
            EspJpnEntry(
              dictionaryId: 1,
              word: 'hablar',
              headword: 'hablar',
              content: '<p>hablar</p>',
            ),
          ],
          conjugation: _conjugation(word)),
    )));
    await loading;
    await tester.pump();

    expect(find.text('hablar'), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Conjugacion'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}

CatalogConjugation _conjugation(CatalogWordRef word) => CatalogConjugation(
      word: word,
      conjugations: {
        CatalogMoodTense.indicativePresent: CatalogTenseConjugation(
          forms: const {CatalogSubject.yo: 'hablo'},
        ),
      },
      participles:
          const CatalogParticiples(present: 'hablando', past: 'hablado'),
    );

class _DeferredLoader implements ILoadWordDetailQuery {
  final _result = Completer<Result<WordDetailQueryResult>>();

  void complete(Result<WordDetailQueryResult> result) =>
      _result.complete(result);

  @override
  Future<Result<WordDetailQueryResult>> execute(WordDetailQuery query) =>
      _result.future;
}

class _NoopWordStatusViewModel implements WordStatusViewModel {
  const _NoopWordStatusViewModel();

  @override
  bool get hasNote => false;

  @override
  bool get isBookmarked => false;

  @override
  bool get isLearned => false;

  @override
  bool get isLoading => false;

  @override
  String? get readError => null;

  @override
  Future<void> toggleBookmark() async {}

  @override
  Future<void> toggleHasNote() async {}

  @override
  Future<void> toggleLearned() async {}
}
