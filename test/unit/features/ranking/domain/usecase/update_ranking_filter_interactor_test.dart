import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/features/catalog/port/model/catalog_part_of_speech.dart';
import 'package:my_dic/features/ranking/port/model/update_ranking_filter_input_data.dart';
import 'package:my_dic/features/ranking/internal/application/usecase/update_ranking_filter/update_ranking_filter_interactor.dart';

void main() {
  group('UpdateRankingFilterInteractor', () {
    late UpdateRankingFilterInteractor interactor;

    setUp(() {
      interactor = UpdateRankingFilterInteractor();
    });

    group('Filter value passthrough', () {
      test('returns filter value 1 for include', () {
        // Arrange
        final input = UpdateRankingFilterInputData(CatalogPartOfSpeech.noun, 1);

        // Act
        final output = interactor.execute(input);

        // Assert
        expect(output.value, 1);
        expect(output.data, CatalogPartOfSpeech.noun);
      });

      test('returns filter value -1 for exclude', () {
        // Arrange
        final input =
            UpdateRankingFilterInputData(CatalogPartOfSpeech.verb, -1);

        // Act
        final output = interactor.execute(input);

        // Assert
        expect(output.value, -1);
        expect(output.data, CatalogPartOfSpeech.verb);
      });

      test('returns filter value 0 for none', () {
        // Arrange
        final input =
            UpdateRankingFilterInputData(CatalogPartOfSpeech.adjective, 0);

        // Act
        final output = interactor.execute(input);

        // Assert
        expect(output.value, 0);
        expect(output.data, CatalogPartOfSpeech.adjective);
      });
    });

    group('CatalogPartOfSpeech handling', () {
      test('handles noun with include filter', () {
        // Arrange
        final input = UpdateRankingFilterInputData(CatalogPartOfSpeech.noun, 1);

        // Act
        final output = interactor.execute(input);

        // Assert
        expect(output.data, CatalogPartOfSpeech.noun);
        expect(output.value, 1);
      });

      test('handles verb with exclude filter', () {
        // Arrange
        final input =
            UpdateRankingFilterInputData(CatalogPartOfSpeech.verb, -1);

        // Act
        final output = interactor.execute(input);

        // Assert
        expect(output.data, CatalogPartOfSpeech.verb);
        expect(output.value, -1);
      });

      test('handles adjective with none filter', () {
        // Arrange
        final input =
            UpdateRankingFilterInputData(CatalogPartOfSpeech.adjective, 0);

        // Act
        final output = interactor.execute(input);

        // Assert
        expect(output.data, CatalogPartOfSpeech.adjective);
        expect(output.value, 0);
      });

      test('handles multiple part of speech types', () {
        // Arrange
        final posTypes = [
          CatalogPartOfSpeech.noun,
          CatalogPartOfSpeech.verb,
          CatalogPartOfSpeech.adjective,
          CatalogPartOfSpeech.adverb,
          CatalogPartOfSpeech.preposition,
        ];

        for (final pos in posTypes) {
          final input = UpdateRankingFilterInputData(pos, 1);

          // Act
          final output = interactor.execute(input);

          // Assert
          expect(output.data, pos);
          expect(output.value, 1);
        }
      });
    });

    group('FeatureTag handling', () {
      test('handles isLearned with include filter', () {
        // Arrange
        final input = UpdateRankingFilterInputData(FeatureTag.isLearned, 1);

        // Act
        final output = interactor.execute(input);

        // Assert
        expect(output.data, FeatureTag.isLearned);
        expect(output.value, 1);
      });

      test('handles hasNote with exclude filter', () {
        // Arrange
        final input = UpdateRankingFilterInputData(FeatureTag.hasNote, -1);

        // Act
        final output = interactor.execute(input);

        // Assert
        expect(output.data, FeatureTag.hasNote);
        expect(output.value, -1);
      });

      test('handles isBookmarked with none filter', () {
        // Arrange
        final input = UpdateRankingFilterInputData(FeatureTag.isBookmarked, 0);

        // Act
        final output = interactor.execute(input);

        // Assert
        expect(output.data, FeatureTag.isBookmarked);
        expect(output.value, 0);
      });

      test('handles multiple feature tags', () {
        // Arrange
        final tags = [
          FeatureTag.isLearned,
          FeatureTag.hasNote,
          FeatureTag.isBookmarked,
          FeatureTag.myWord,
        ];

        for (final tag in tags) {
          final input = UpdateRankingFilterInputData(tag, -1);

          // Act
          final output = interactor.execute(input);

          // Assert
          expect(output.data, tag);
          expect(output.value, -1);
        }
      });
    });

    group('Output data structure', () {
      test('preserves input data in output', () {
        // Arrange
        final input = UpdateRankingFilterInputData(CatalogPartOfSpeech.noun, 1);

        // Act
        final output = interactor.execute(input);

        // Assert
        expect(output.data, input.data);
        expect(output.value, input.filterType);
      });

      test('creates correct output structure for different filter types', () {
        // Arrange
        final testCases = <(Object, int)>[
          (CatalogPartOfSpeech.noun, 1),
          (CatalogPartOfSpeech.verb, -1),
          (FeatureTag.isLearned, 0),
          (FeatureTag.hasNote, 1),
        ];

        for (final (data, filterType) in testCases) {
          final input = UpdateRankingFilterInputData(data, filterType);

          // Act
          final output = interactor.execute(input);

          // Assert
          expect(output.data, data);
          expect(output.value, filterType);
        }
      });
    });
  });
}
