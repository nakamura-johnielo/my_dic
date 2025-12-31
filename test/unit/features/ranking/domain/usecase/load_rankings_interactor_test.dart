import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/core/shared/enums/word/part_of_speech.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/ranking/domain/usecase/load_rankings/load_rankings_input_data.dart';
import 'package:my_dic/features/ranking/domain/usecase/load_rankings/load_rankings_interactor.dart';

import '../../../../../helpers/fake_esp_ranking_repository.dart';

void main() {
  group('LoadRankingsInteractor', () {
    late FakeEspRankingRepository repository;
    late LoadRankingsInteractor interactor;

    setUp(() {
      repository = FakeEspRankingRepository.success();
      interactor = LoadRankingsInteractor(repository);
    });

    group('Map to Set conversion logic', () {
      test('converts value 1 to include filter set', () async {
        // Arrange
        final input = LoadRankingsInputData(
          {PartOfSpeech.noun: 1, PartOfSpeech.verb: 1},
          {},
          [-1, -1],
          10,
          true,
          0,
        );

        // Act
        await interactor.execute(input);

        // Assert
        expect(repository.filteredCallCount, 1);
        expect(repository.lastFilteredInput!.partOfSpeechFilters,
            {PartOfSpeech.noun, PartOfSpeech.verb});
        expect(repository.lastFilteredInput!.partOfSpeechExcludeFilters, isEmpty);
      });

      test('converts value -1 to exclude filter set', () async {
        // Arrange
        final input = LoadRankingsInputData(
          {PartOfSpeech.adjective: -1, PartOfSpeech.adverb: -1},
          {},
          [-1, -1],
          10,
          true,
          0,
        );

        // Act
        await interactor.execute(input);

        // Assert
        expect(repository.lastFilteredInput!.partOfSpeechFilters, isEmpty);
        expect(repository.lastFilteredInput!.partOfSpeechExcludeFilters,
            {PartOfSpeech.adjective, PartOfSpeech.adverb});
      });

      test('ignores value 0 in filter conversion', () async {
        // Arrange
        final input = LoadRankingsInputData(
          {PartOfSpeech.noun: 1, PartOfSpeech.verb: 0, PartOfSpeech.adjective: -1},
          {},
          [-1, -1],
          10,
          true,
          0,
        );

        // Act
        await interactor.execute(input);

        // Assert
        expect(repository.lastFilteredInput!.partOfSpeechFilters, {PartOfSpeech.noun});
        expect(repository.lastFilteredInput!.partOfSpeechExcludeFilters, {PartOfSpeech.adjective});
      });

      test('converts feature tag filters with value 1 to include set', () async {
        // Arrange
        final input = LoadRankingsInputData(
          {},
          {FeatureTag.isLearned: 1, FeatureTag.hasNote: 1},
          [-1, -1],
          10,
          true,
          0,
        );

        // Act
        await interactor.execute(input);

        // Assert
        expect(repository.lastFilteredInput!.featureTagFilters,
            {FeatureTag.isLearned, FeatureTag.hasNote});
        expect(repository.lastFilteredInput!.featureTagExcludeFilters, isEmpty);
      });

      test('converts feature tag filters with value -1 to exclude set', () async {
        // Arrange
        final input = LoadRankingsInputData(
          {},
          {FeatureTag.isBookmarked: -1},
          [-1, -1],
          10,
          true,
          0,
        );

        // Act
        await interactor.execute(input);

        // Assert
        expect(repository.lastFilteredInput!.featureTagFilters, isEmpty);
        expect(repository.lastFilteredInput!.featureTagExcludeFilters,
            {FeatureTag.isBookmarked});
      });

      test('handles combined part of speech and feature tag filters', () async {
        // Arrange
        final input = LoadRankingsInputData(
          {PartOfSpeech.noun: 1, PartOfSpeech.verb: -1},
          {FeatureTag.isLearned: 1, FeatureTag.hasNote: -1},
          [-1, -1],
          10,
          true,
          0,
        );

        // Act
        await interactor.execute(input);

        // Assert
        expect(repository.lastFilteredInput!.partOfSpeechFilters, {PartOfSpeech.noun});
        expect(repository.lastFilteredInput!.partOfSpeechExcludeFilters, {PartOfSpeech.verb});
        expect(repository.lastFilteredInput!.featureTagFilters, {FeatureTag.isLearned});
        expect(repository.lastFilteredInput!.featureTagExcludeFilters, {FeatureTag.hasNote});
      });

      test('handles empty filter maps', () async {
        // Arrange
        final input = LoadRankingsInputData(
          {},
          {},
          [-1, -1],
          10,
          true,
          0,
        );

        // Act
        await interactor.execute(input);

        // Assert
        expect(repository.lastFilteredInput!.partOfSpeechFilters, isEmpty);
        expect(repository.lastFilteredInput!.partOfSpeechExcludeFilters, isEmpty);
        expect(repository.lastFilteredInput!.featureTagFilters, isEmpty);
        expect(repository.lastFilteredInput!.featureTagExcludeFilters, isEmpty);
      });
    });

    group('Pagination logic', () {
      test('calculates requiredNextPage for isNext=true with currentPage [-1,-1]', () async {
        // Arrange
        final input = LoadRankingsInputData(
          {},
          {},
          [-1, -1],
          10,
          true,
          0,
        );

        // Act
        await interactor.execute(input);

        // Assert
        // requiredPages[1] += 1 => -1 + 1 = 0
        // requiredNextPage = requiredPages[1] + offset = 0 + 0 = 0
        expect(repository.lastFilteredInput!.requiredPage, 0);
      });

      test('calculates requiredNextPage with offset', () async {
        // Arrange
        final input = LoadRankingsInputData(
          {},
          {},
          [0, 2],
          10,
          true,
          1,
        );

        // Act
        await interactor.execute(input);

        // Assert
        // requiredPages[1] += 1 => 2 + 1 = 3
        // requiredNextPage = requiredPages[1] + offset = 3 + 1 = 4
        expect(repository.lastFilteredInput!.requiredPage, 4);
      });

      test('passes correct size to repository', () async {
        // Arrange
        final input = LoadRankingsInputData(
          {},
          {},
          [-1, -1],
          20,
          true,
          0,
        );

        // Act
        await interactor.execute(input);

        // Assert
        expect(repository.lastFilteredInput!.size, 20);
      });

      test('handles isNext=false scenario', () async {
        // Arrange
        final input = LoadRankingsInputData(
          {},
          {},
          [1, 3],
          10,
          false,
          0,
        );

        // Act
        await interactor.execute(input);

        // Assert
        // isNext=false uses requiredPages[0] instead of requiredNextPage
        expect(repository.lastFilteredInput!.requiredPage, 1);
      });
    });

    group('Success scenarios', () {
      test('returns success result from repository', () async {
        // Arrange
        final input = LoadRankingsInputData(
          {},
          {},
          [-1, -1],
          10,
          true,
          0,
        );

        // Act
        final result = await interactor.execute(input);

        // Assert
        expect(result.isSuccess, true);
        result.when(
          success: (rankings) {
            expect(rankings.length, 3);
            expect(rankings[0].rankedWord, 'ser');
          },
          failure: (_) => fail('Should not fail'),
        );
      });

      test('returns ranking list with expected properties', () async {
        // Arrange
        final input = LoadRankingsInputData(
          {PartOfSpeech.verb: 1},
          {FeatureTag.isLearned: -1},
          [-1, -1],
          10,
          true,
          0,
        );

        // Act
        final result = await interactor.execute(input);

        // Assert
        result.when(
          success: (rankings) {
            expect(rankings[0].rank, 1);
            expect(rankings[0].wordId, 1);
            expect(rankings[0].hasConj, true);
            expect(rankings[1].isLearned, true);
            expect(rankings[2].isBookmarked, true);
            expect(rankings[2].hasNote, true);
          },
          failure: (_) => fail('Should not fail'),
        );
      });
    });

    group('Error handling', () {
      test('returns database error when repository fails', () async {
        // Arrange
        repository = FakeEspRankingRepository.databaseError();
        interactor = LoadRankingsInteractor(repository);
        final input = LoadRankingsInputData(
          {},
          {},
          [-1, -1],
          10,
          true,
          0,
        );

        // Act
        final result = await interactor.execute(input);

        // Assert
        expect(result.isFailure, true);
        result.when(
          success: (_) => fail('Should not succeed'),
          failure: (error) {
            expect(error, isA<DatabaseError>());
            expect((error as DatabaseError).message, 'Database connection failed');
          },
        );
      });
    });

    group('Multiple filter combinations', () {
      test('handles all part of speech types with mixed include and exclude', () async {
        // Arrange
        final input = LoadRankingsInputData(
          {
            PartOfSpeech.noun: 1,
            PartOfSpeech.verb: 1,
            PartOfSpeech.adjective: -1,
            PartOfSpeech.adverb: -1,
            PartOfSpeech.preposition: 0,
          },
          {},
          [-1, -1],
          10,
          true,
          0,
        );

        // Act
        await interactor.execute(input);

        // Assert
        expect(repository.lastFilteredInput!.partOfSpeechFilters,
            {PartOfSpeech.noun, PartOfSpeech.verb});
        expect(repository.lastFilteredInput!.partOfSpeechExcludeFilters,
            {PartOfSpeech.adjective, PartOfSpeech.adverb});
      });

      test('handles all feature tags with mixed include and exclude', () async {
        // Arrange
        final input = LoadRankingsInputData(
          {},
          {
            FeatureTag.isLearned: 1,
            FeatureTag.hasNote: -1,
            FeatureTag.isBookmarked: 1,
            FeatureTag.myWord: 0,
          },
          [-1, -1],
          10,
          true,
          0,
        );

        // Act
        await interactor.execute(input);

        // Assert
        expect(repository.lastFilteredInput!.featureTagFilters,
            {FeatureTag.isLearned, FeatureTag.isBookmarked});
        expect(repository.lastFilteredInput!.featureTagExcludeFilters,
            {FeatureTag.hasNote});
      });

      test('handles exclude-only filters', () async {
        // Arrange
        final input = LoadRankingsInputData(
          {PartOfSpeech.noun: -1, PartOfSpeech.verb: -1},
          {FeatureTag.isLearned: -1},
          [-1, -1],
          10,
          true,
          0,
        );

        // Act
        await interactor.execute(input);

        // Assert
        expect(repository.lastFilteredInput!.partOfSpeechFilters, isEmpty);
        expect(repository.lastFilteredInput!.partOfSpeechExcludeFilters,
            {PartOfSpeech.noun, PartOfSpeech.verb});
        expect(repository.lastFilteredInput!.featureTagFilters, isEmpty);
        expect(repository.lastFilteredInput!.featureTagExcludeFilters,
            {FeatureTag.isLearned});
      });
    });
  });
}
