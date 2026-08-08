import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/app/presentation/dictionary_status_view_models.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/shared/enums/word/part_of_speech.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/ranking/application/query/ranking_list_item.dart';
import 'package:my_dic/features/ranking/application/query/ranking_page.dart';
import 'package:my_dic/features/ranking/application/query/ranking_query.dart';
import 'package:my_dic/features/ranking/application/usecase/load_rankings/i_load_rankings_use_case.dart';
import 'package:my_dic/features/ranking/application/usecase/load_rankings/load_rankings_input_data.dart';
import 'package:my_dic/features/ranking/di/usecase_di.dart';
import 'package:my_dic/features/ranking/di/view_model_di.dart';
import 'package:my_dic/features/ranking/data/data_source/local/ranking_dao.dart';
import 'package:my_dic/features/ranking/data/query/drift_ranking_query_repository.dart';
import 'package:my_dic/features/ranking/presentation/view/ranking_fragment.dart';
import 'package:my_dic/features/esp_jpn_word_status/application/update_status_usecase.dart';
import 'package:my_dic/features/esp_jpn_word_status/di/di.dart';

import '../../../../../helpers/fake_ranking_usecases.dart';

void main() {
  testWidgets(
      'requests pages in order, stops at the final page, and resets to page 0 after a filter change',
      (tester) async {
    final loadUseCase =
        _ScriptedLoadRankingsUseCase((input) => Result.success(RankingPage(
              items: _itemsForPage(input.page),
              hasNext: input.page == 0,
            )));
    final container = ProviderContainer(overrides: [
      loadRankingsUseCaseProvider.overrideWithValue(loadUseCase),
      updateRankingFilterUseCaseProvider
          .overrideWithValue(FakeUpdateRankingFilterUseCase()),
      espJpnWordStatusViewModelProvider(1).overrideWith(
        (ref) => _statusViewModel,
      ),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: RankingFragment()),
      ),
    );
    await tester.pumpAndSettle();

    expect(loadUseCase.inputs.map((input) => input.page), [0]);

    await _scrollToNextPage(tester);

    expect(loadUseCase.inputs.map((input) => input.page), [0, 1]);
    expect(container.read(rankingViewModelProvider).items, hasLength(200));

    await _scrollToNextPage(tester);

    expect(loadUseCase.inputs.map((input) => input.page), [0, 1]);

    container
        .read(rankingViewModelProvider.notifier)
        .addFilter(PartOfSpeech.noun);
    await tester.pumpAndSettle();

    expect(loadUseCase.inputs.map((input) => input.page), [0, 1, 0]);
    expect(loadUseCase.inputs.last.partOfSpeechFilters[PartOfSpeech.noun], 1);
  });

  testWidgets(
      'retries the failed pagination request without advancing the page',
      (tester) async {
    var pageOneAttempts = 0;
    final loadUseCase = _ScriptedLoadRankingsUseCase((input) {
      if (input.page == 0) {
        return Result.success(
            RankingPage(items: _itemsForPage(0), hasNext: true));
      }
      pageOneAttempts++;
      if (pageOneAttempts == 1) {
        return Result.failure(DatabaseError(message: 'Failed to load page 1'));
      }
      return Result.success(
          RankingPage(items: _itemsForPage(1), hasNext: false));
    });
    final container = ProviderContainer(overrides: [
      loadRankingsUseCaseProvider.overrideWithValue(loadUseCase),
      updateRankingFilterUseCaseProvider
          .overrideWithValue(FakeUpdateRankingFilterUseCase()),
      espJpnWordStatusViewModelProvider(1).overrideWith(
        (ref) => _statusViewModel,
      ),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: RankingFragment()),
    ));
    await tester.pumpAndSettle();

    await _scrollToNextPage(tester);
    expect(loadUseCase.inputs.map((input) => input.page), [0, 1]);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(loadUseCase.inputs.map((input) => input.page), [0, 1, 1]);
    expect(container.read(rankingViewModelProvider).items, hasLength(200));
  });

  testWidgets(
      'skips an invalid row after rank 188 and continues to the final page without Retry',
      (tester) async {
    final database = DatabaseProvider.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await _seedRankingRowsWithInvalidEntryAfter188(database);

    final loadUseCase = _RepositoryBackedLoadRankingsUseCase(
      DriftRankingQueryRepository(RankingDao(database)),
    );
    final container = ProviderContainer(overrides: [
      loadRankingsUseCaseProvider.overrideWithValue(loadUseCase),
      updateRankingFilterUseCaseProvider
          .overrideWithValue(FakeUpdateRankingFilterUseCase()),
      espJpnWordStatusViewModelProvider(1).overrideWith(
        (ref) => _statusViewModel,
      ),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: RankingFragment()),
    ));
    await tester.pumpAndSettle();

    expect(loadUseCase.requestedPages, [0]);
    expect(find.text('Retry'), findsNothing);

    await _scrollToNextPage(tester);

    // Remaining at the load threshold lets the list immediately consume the
    // short final page after page 1.
    expect(loadUseCase.requestedPages, [0, 1, 2]);
    expect(container.read(rankingViewModelProvider).items, hasLength(205));
    expect(find.text('188'), findsWidgets);
    expect(find.text('Retry'), findsNothing);
    expect(find.text('word_192'), findsNWidgets(2));

    await _scrollToNextPage(tester);

    expect(loadUseCase.requestedPages, [0, 1, 2]);
    expect(find.text('Retry'), findsNothing);
  });
}

Future<void> _scrollToNextPage(WidgetTester tester) async {
  await tester.fling(
    find.byType(ListView),
    const Offset(0, -50000),
    100000,
  );
  await tester.pumpAndSettle();
}

List<RankingListItem> _itemsForPage(int page) => List.generate(
      100,
      (index) {
        final id = page * 100 + index + 1;
        return RankingListItem(
          rank: id,
          rankedWord: 'word_$id',
          lemma: 'word_$id',
          wordId: 1,
          hasConjugation: false,
        );
      },
    );

class _ScriptedLoadRankingsUseCase implements ILoadRankingsUseCase {
  _ScriptedLoadRankingsUseCase(this._resultFor);

  final Result<RankingPage> Function(LoadRankingsInputData input) _resultFor;
  final inputs = <LoadRankingsInputData>[];

  @override
  Future<Result<RankingPage>> execute(LoadRankingsInputData input) async {
    inputs.add(input);
    return _resultFor(input);
  }
}

class _RepositoryBackedLoadRankingsUseCase implements ILoadRankingsUseCase {
  _RepositoryBackedLoadRankingsUseCase(this._repository);

  final DriftRankingQueryRepository _repository;
  final requestedPages = <int>[];

  @override
  Future<Result<RankingPage>> execute(LoadRankingsInputData input) {
    requestedPages.add(input.page);
    return _repository.fetchPage(RankingQuery(
      page: input.page,
      size: input.size,
      accountId: 'widget-test-account',
      includedPartOfSpeech: {
        for (final entry in input.partOfSpeechFilters.entries)
          if (entry.value == 1) entry.key,
      },
      excludedPartOfSpeech: {
        for (final entry in input.partOfSpeechFilters.entries)
          if (entry.value == -1) entry.key,
      },
      includedFeatureTags: {
        for (final entry in input.featureTagFilters.entries)
          if (entry.value == 1) entry.key,
      },
      excludedFeatureTags: {
        for (final entry in input.featureTagFilters.entries)
          if (entry.value == -1) entry.key,
      },
    ));
  }
}

Future<void> _seedRankingRowsWithInvalidEntryAfter188(
  DatabaseProvider database,
) async {
  await database.customStatement('''
    INSERT INTO words (word_id, word) VALUES (1, 'uno')
  ''');

  final rows = <String>[];
  for (var id = 1; id <= 200; id++) {
    final rank = id <= 188 ? id : 188;
    rows.add("($id, $rank, 'word_$id', 'word_$id', 1)");
  }
  rows.add("(201, 189, 'invalid', 'invalid', NULL)");
  for (var rank = 192; rank <= 196; rank++) {
    final id = rank + 10;
    rows.add("($id, $rank, 'word_$rank', 'word_$rank', 1)");
  }

  await database.customStatement('''
    INSERT INTO rankings
      (ranking_id, ranking_no, word, word_origin, word_id)
    VALUES ${rows.join(', ')}
  ''');
}

final _statusViewModel = EspJpnWordStatusViewModel(
  WordStatusState(status: QueryState.empty()),
  EspJpnWordStatusCommand(1, _NoopUpdateStatusUseCase()),
);

class _NoopUpdateStatusUseCase implements IUpdateStatusUseCase {
  @override
  Future<Result<void>> execute(UpdateStatusInputData input) async =>
      const Result.success(null);
}
