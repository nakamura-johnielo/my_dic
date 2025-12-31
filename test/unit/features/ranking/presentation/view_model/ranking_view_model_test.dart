import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/core/shared/enums/word/part_of_speech.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/ranking/di/view_model_di.dart';
import 'package:my_dic/features/ranking/domain/entity/ranking.dart';
import 'package:my_dic/features/ranking/presentation/view_model/new_ranking_view_model.dart';
import 'package:my_dic/features/ranking/di/usecase_di.dart';

import '../../../../../helpers/fake_ranking_usecases.dart';

void main() {
  group('RankingViewModel', () {
    late ProviderContainer container;
    late FakeLoadRankingsUseCase fakeLoadRankingsUseCase;

    setUp(() {
      fakeLoadRankingsUseCase = FakeLoadRankingsUseCase(
        result: Result.success(_createTestRankings()),
      );

      container = ProviderContainer(
        overrides: [
          loadRankingsUseCaseProvider.overrideWithValue(fakeLoadRankingsUseCase),
          locateRankingPagenationUseCaseProvider
              .overrideWithValue(FakeLocateRankingPagenationUseCase()),
          updateRankingFilterUseCaseProvider
              .overrideWithValue(FakeUpdateRankingFilterUseCase()),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Filter state management', () {
      test('addFilter updates partOfSpeech filter value to 1', () {
        // Arrange
        final viewModel = container.read(rankingViewModelProvider.notifier);

        // Act
        viewModel.addFilter(PartOfSpeech.noun);

        // Assert
        final state = container.read(rankingViewModelProvider);
        expect(state.partOfSpeechFilters[PartOfSpeech.noun], 1);
      });

      test('addExcludeFilter updates partOfSpeech filter value to -1', () {
        // Arrange
        final viewModel = container.read(rankingViewModelProvider.notifier);

        // Act
        viewModel.addExcludeFilter(PartOfSpeech.verb);

        // Assert
        final state = container.read(rankingViewModelProvider);
        expect(state.partOfSpeechFilters[PartOfSpeech.verb], -1);
      });

      test('removeFilter updates partOfSpeech filter value to 0', () {
        // Arrange
        final viewModel = container.read(rankingViewModelProvider.notifier);
        viewModel.addFilter(PartOfSpeech.adjective);

        // Act
        viewModel.removeFilter(PartOfSpeech.adjective);

        // Assert
        final state = container.read(rankingViewModelProvider);
        expect(state.partOfSpeechFilters[PartOfSpeech.adjective], 0);
      });

      test('addFilter updates featureTag filter value to 1', () {
        // Arrange
        final viewModel = container.read(rankingViewModelProvider.notifier);

        // Act
        viewModel.addFilter(FeatureTag.isLearned);

        // Assert
        final state = container.read(rankingViewModelProvider);
        expect(state.featureTagFilters[FeatureTag.isLearned], 1);
      });

      test('addExcludeFilter updates featureTag filter value to -1', () {
        // Arrange
        final viewModel = container.read(rankingViewModelProvider.notifier);

        // Act
        viewModel.addExcludeFilter(FeatureTag.hasNote);

        // Assert
        final state = container.read(rankingViewModelProvider);
        expect(state.featureTagFilters[FeatureTag.hasNote], -1);
      });

      test('removeFilter updates featureTag filter value to 0', () {
        // Arrange
        final viewModel = container.read(rankingViewModelProvider.notifier);
        viewModel.addFilter(FeatureTag.isBookmarked);

        // Act
        viewModel.removeFilter(FeatureTag.isBookmarked);

        // Assert
        final state = container.read(rankingViewModelProvider);
        expect(state.featureTagFilters[FeatureTag.isBookmarked], 0);
      });

      test('filter changes reset currentPageRange to [-1, -1]', () {
        // Arrange
        final viewModel = container.read(rankingViewModelProvider.notifier);
        viewModel.setPageRange([0, 2]);

        // Act
        viewModel.addFilter(PartOfSpeech.noun);

        // Assert
        final state = container.read(rankingViewModelProvider);
        expect(state.currentPageRange, [-1, -1]);
      });

      test('filter changes clear items list', () async {
        // Arrange
        final viewModel = container.read(rankingViewModelProvider.notifier);
        await viewModel.loadNextPage(0);
        expect(container.read(rankingViewModelProvider).items, isNotEmpty);

        // Act
        viewModel.addFilter(PartOfSpeech.verb);

        // Assert
        final state = container.read(rankingViewModelProvider);
        expect(state.items, isEmpty);
      });

      test('handles multiple filter updates', () {
        // Arrange
        final viewModel = container.read(rankingViewModelProvider.notifier);

        // Act
        viewModel.addFilter(PartOfSpeech.noun);
        viewModel.addExcludeFilter(PartOfSpeech.verb);
        viewModel.addFilter(FeatureTag.isLearned);

        // Assert
        final state = container.read(rankingViewModelProvider);
        expect(state.partOfSpeechFilters[PartOfSpeech.noun], 1);
        expect(state.partOfSpeechFilters[PartOfSpeech.verb], -1);
        expect(state.featureTagFilters[FeatureTag.isLearned], 1);
      });
    });

    group('Pagination state management', () {
      test('loadNextPage appends items to state', () async {
        // Arrange
        final viewModel = container.read(rankingViewModelProvider.notifier);

        // Act
        await viewModel.loadNextPage(0);

        // Assert
        final state = container.read(rankingViewModelProvider);
        expect(state.items.length, 3);
        expect(state.items[0].rankedWord, 'ser');
      });

      test('loadNextPage updates currentPageRange', () async {
        // Arrange
        final viewModel = container.read(rankingViewModelProvider.notifier);

        // Act
        await viewModel.loadNextPage(0);

        // Assert
        final state = container.read(rankingViewModelProvider);
        expect(state.currentPageRange, [-1, 0]);
      });

      test('loadNextPage with multiple pages accumulates items', () async {
        // Arrange
        final viewModel = container.read(rankingViewModelProvider.notifier);
        fakeLoadRankingsUseCase
            .setResult(Result.success(_createTestRankings(prefix: 'page1_')));

        // Act
        await viewModel.loadNextPage(0);
        fakeLoadRankingsUseCase
            .setResult(Result.success(_createTestRankings(prefix: 'page2_')));
        await viewModel.loadNextPage(1);

        // Assert
        final state = container.read(rankingViewModelProvider);
        expect(state.items.length, 6);
        expect(state.items[0].rankedWord, 'page1_ser');
        expect(state.items[3].rankedWord, 'page2_ser');
      });

      test('setPageRange updates currentPageRange', () {
        // Arrange
        final viewModel = container.read(rankingViewModelProvider.notifier);

        // Act
        viewModel.setPageRange([0, 2]);

        // Assert
        final state = container.read(rankingViewModelProvider);
        expect(state.currentPageRange, [0, 2]);
      });

      test('setNextPage updates only max value of currentPageRange', () {
        // Arrange
        final viewModel = container.read(rankingViewModelProvider.notifier);
        viewModel.setPageRange([0, 1]);

        // Act
        viewModel.setNextPage(3);

        // Assert
        final state = container.read(rankingViewModelProvider);
        expect(state.currentPageRange, [0, 3]);
      });
    });

    group('Error handling', () {
      test('loadNextPage returns false on failure', () async {
        // Arrange
        fakeLoadRankingsUseCase.setResult(
          Result.failure(DatabaseError(message: 'Failed to load')),
        );
        final viewModel = container.read(rankingViewModelProvider.notifier);

        // Act
        final result = await viewModel.loadNextPage(0);

        // Assert
        expect(result, false);
      });

      test('loadNextPage preserves state on failure', () async {
        // Arrange
        final viewModel = container.read(rankingViewModelProvider.notifier);
        viewModel.setPageRange([0, 1]);
        fakeLoadRankingsUseCase.setResult(
          Result.failure(DatabaseError(message: 'Failed to load')),
        );

        // Act
        await viewModel.loadNextPage(2);

        // Assert
        final state = container.read(rankingViewModelProvider);
        expect(state.currentPageRange, [0, 1]);
        expect(state.items, isEmpty);
      });
    });

    group('Reset operations', () {
      test('resetAndReload clears state to initial values', () async {
        // Arrange
        final viewModel = container.read(rankingViewModelProvider.notifier);
        await viewModel.loadNextPage(0);
        viewModel.addFilter(PartOfSpeech.noun);

        // Act
        viewModel.resetAndReload();

        // Assert
        final state = container.read(rankingViewModelProvider);
        expect(state.items, isEmpty);
        expect(state.currentPageRange, [-1, -1]);
        expect(state.partOfSpeechFilters, isEmpty);
        expect(state.featureTagFilters, isEmpty);
      });
    });

    group('Direct filter setters', () {
      test('setFeatureTagFilter updates specific tag', () {
        // Arrange
        final viewModel = container.read(rankingViewModelProvider.notifier);

        // Act
        viewModel.setFeatureTagFilter(FeatureTag.isLearned, 1);

        // Assert
        final state = container.read(rankingViewModelProvider);
        expect(state.featureTagFilters[FeatureTag.isLearned], 1);
      });

      test('setPartOfSpeechFilter updates specific part of speech', () {
        // Arrange
        final viewModel = container.read(rankingViewModelProvider.notifier);

        // Act
        viewModel.setPartOfSpeechFilter(PartOfSpeech.verb, -1);

        // Assert
        final state = container.read(rankingViewModelProvider);
        expect(state.partOfSpeechFilters[PartOfSpeech.verb], -1);
      });

      test('locatePage updates pagenationFilter and resets page', () {
        // Arrange
        final viewModel = container.read(rankingViewModelProvider.notifier);
        viewModel.setPageRange([0, 2]);

        // Act
        viewModel.locatePage(5);

        // Assert
        final state = container.read(rankingViewModelProvider);
        expect(state.pagenationFilter, 5);
        expect(state.currentPageRange, [-1, -1]);
        expect(state.items, isEmpty);
      });
    });
  });
}

List<Ranking> _createTestRankings({String prefix = ''}) {
  return [
    Ranking(
      rank: 1,
      rankedWord: '${prefix}ser',
      lemma: '${prefix}ser',
      wordId: 1,
      hasConj: true,
      isLearned: false,
      isBookmarked: false,
      hasNote: false,
    ),
    Ranking(
      rank: 2,
      rankedWord: '${prefix}estar',
      lemma: '${prefix}estar',
      wordId: 2,
      hasConj: true,
      isLearned: true,
      isBookmarked: false,
      hasNote: false,
    ),
    Ranking(
      rank: 3,
      rankedWord: '${prefix}casa',
      lemma: '${prefix}casa',
      wordId: 3,
      hasConj: false,
      isLearned: false,
      isBookmarked: true,
      hasNote: true,
    ),
  ];
}
