/// Test for LoadMyWordInteractor UseCase
/// Priority: ★★★★★ (Critical pagination business logic)
/// 
/// Tests demonstrate:
/// - Pagination logic validation
/// - Input validation for page numbers and size
/// - Offset calculation correctness
/// - Fake repository usage

import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/features/my_word/domain/entity/my_word.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/load_my_word/load_my_word_input_data.dart';
import 'package:my_dic/features/my_word/domain/usecase/my_word/load_my_word/load_my_word_interactor.dart';

import '../../../../../helpers/fake_my_word_repository.dart';

void main() {
  group('LoadMyWordInteractor', () {
    group('Input Validation', () {
      test('execute_returnsValidationError_whenPageNumberIsNegative', () async {
        // Arrange
        final repository = FakeMyWordRepository.success();
        final useCase = LoadMyWordInteractor(repository);
        final input = LoadMyWordInputData(10, -1); // Negative page

        // Act
        final result = await useCase.execute(input);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<ValidationError>());
        expect(
          result.errorOrNull?.message,
          'ページ番号は0以上である必要があります',
        );

        // Verify repository was not called
        expect(repository.getFilteredCallCount, 0);
      });

      test('execute_returnsValidationError_whenPageSizeIsZero', () async {
        // Arrange
        final repository = FakeMyWordRepository.success();
        final useCase = LoadMyWordInteractor(repository);
        final input = LoadMyWordInputData(0, 0); // Size = 0

        // Act
        final result = await useCase.execute(input);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<ValidationError>());
        expect(
          result.errorOrNull?.message,
          'ページサイズは1以上である必要があります',
        );

        // Verify repository was not called
        expect(repository.getFilteredCallCount, 0);
      });

      test('execute_returnsValidationError_whenPageSizeIsNegative', () async {
        // Arrange
        final repository = FakeMyWordRepository.success();
        final useCase = LoadMyWordInteractor(repository);
        final input = LoadMyWordInputData(-5, 0); // Negative size

        // Act
        final result = await useCase.execute(input);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<ValidationError>());
      });
    });

    group('Success Scenarios', () {
      test('execute_returnsWords_whenInputIsValid', () async {
        // Arrange
        const testWords = [
          MyWord(wordId: 1, word: 'casa', contents: '家'),
          MyWord(wordId: 2, word: 'libro', contents: '本'),
        ];
        final repository = FakeMyWordRepository.success(words: testWords);
        final useCase = LoadMyWordInteractor(repository);
        final input = LoadMyWordInputData(10, 0); // Page 0, size 10

        // Act
        final result = await useCase.execute(input);

        // Assert
        expect(result.isSuccess, true);
        expect(result.dataOrNull, isNotNull);
        expect(result.dataOrNull!.length, 2);
        expect(result.dataOrNull![0].word, 'casa');
        expect(result.dataOrNull![1].word, 'libro');
      });

      test('execute_returnsEmptyList_whenNoWordsExist', () async {
        // Arrange
        final repository = FakeMyWordRepository.empty();
        final useCase = LoadMyWordInteractor(repository);
        final input = LoadMyWordInputData(20, 0);

        // Act
        final result = await useCase.execute(input);

        // Assert
        expect(result.isSuccess, true);
        expect(result.dataOrNull, isNotNull);
        expect(result.dataOrNull!.isEmpty, true);
      });
    });

    group('Pagination Logic', () {
      test('execute_calculatesCorrectOffset_forFirstPage', () async {
        // Arrange
        final repository = FakeMyWordRepository.success();
        final useCase = LoadMyWordInteractor(repository);
        final input = LoadMyWordInputData(10, 0); // Page 0, size 10

        // Act
        await useCase.execute(input);

        // Assert
        expect(repository.lastSize, 10);
        expect(repository.lastOffset, 0); // 0 * 10 = 0
      });

      test('execute_calculatesCorrectOffset_forSecondPage', () async {
        // Arrange
        final repository = FakeMyWordRepository.success();
        final useCase = LoadMyWordInteractor(repository);
        final input = LoadMyWordInputData(10, 1); // Page 1, size 10

        // Act
        await useCase.execute(input);

        // Assert
        expect(repository.lastOffset, 10); // 1 * 10 = 10
      });

      test('execute_calculatesCorrectOffset_forThirdPageWithDifferentSize', () async {
        // Arrange
        final repository = FakeMyWordRepository.success();
        final useCase = LoadMyWordInteractor(repository);
        final input = LoadMyWordInputData(20, 2); // Page 2, size 20

        // Act
        await useCase.execute(input);

        // Assert
        expect(repository.lastSize, 20);
        expect(repository.lastOffset, 40); // 2 * 20 = 40
      });

      test('execute_passesCorrectLimit_toRepository', () async {
        // Arrange
        final repository = FakeMyWordRepository.success();
        final useCase = LoadMyWordInteractor(repository);
        final input = LoadMyWordInputData(50, 3); // Size 50

        // Act
        await useCase.execute(input);

        // Assert
        expect(repository.lastSize, 50);
        expect(repository.lastOffset, 150); // 3 * 50 = 150
      });
    });

    group('Failure Scenarios', () {
      test('execute_returnsDatabaseError_whenRepositoryFails', () async {
        // Arrange
        final repository = FakeMyWordRepository.databaseError();
        final useCase = LoadMyWordInteractor(repository);
        final input = LoadMyWordInputData(10, 0);

        // Act
        final result = await useCase.execute(input);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<DatabaseError>());
        expect(result.errorOrNull?.message, 'データベースエラー');
      });
    });

    group('Edge Cases', () {
      test('execute_allowsPageNumberZero', () async {
        // Arrange
        final repository = FakeMyWordRepository.success();
        final useCase = LoadMyWordInteractor(repository);
        final input = LoadMyWordInputData(10, 0);

        // Act
        final result = await useCase.execute(input);

        // Assert
        expect(result.isSuccess, true);
      });

      test('execute_allowsLargePageNumbers', () async {
        // Arrange
        final repository = FakeMyWordRepository.success();
        final useCase = LoadMyWordInteractor(repository);
        final input = LoadMyWordInputData(10, 1000);

        // Act
        final result = await useCase.execute(input);

        // Assert
        expect(result.isSuccess, true);
        expect(repository.lastOffset, 10000); // 1000 * 10
      });

      test('execute_allowsPageSizeOfOne', () async {
        // Arrange
        final repository = FakeMyWordRepository.success();
        final useCase = LoadMyWordInteractor(repository);
        final input = LoadMyWordInputData(1, 5);

        // Act
        final result = await useCase.execute(input);

        // Assert
        expect(result.isSuccess, true);
        expect(repository.lastSize, 1);
        expect(repository.lastOffset, 5); // 5 * 1
      });
    });
  });
}
