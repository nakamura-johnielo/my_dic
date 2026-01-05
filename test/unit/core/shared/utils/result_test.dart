/// Test for Result utility class
/// Priority: ★★★★★ (Foundation for all other tests)
/// 
/// Tests the Result monad pattern implementation which is critical
/// for the Clean Architecture error handling approach.

import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';

void main() {
  group('Result utility class', () {
    group('Success', () {
      test('isSuccess_returnsTrue_whenResultIsSuccess', () {
        // Arrange
        const result = Result<int>.success(42);

        // Act & Assert
        expect(result.isSuccess, true);
        expect(result.isFailure, false);
      });

      test('dataOrNull_returnsData_whenResultIsSuccess', () {
        // Arrange
        const result = Result<String>.success('test data');

        // Act
        final data = result.dataOrNull;

        // Assert
        expect(data, 'test data');
      });

      test('errorOrNull_returnsNull_whenResultIsSuccess', () {
        // Arrange
        const result = Result<int>.success(100);

        // Act
        final error = result.errorOrNull;

        // Assert
        expect(error, isNull);
      });
    });

    group('Failure', () {
      test('isFailure_returnsTrue_whenResultIsFailure', () {
        // Arrange
        final result = Result<int>.failure(
          ValidationError(message: 'test error'),
        );

        // Act & Assert
        expect(result.isFailure, true);
        expect(result.isSuccess, false);
      });

      test('errorOrNull_returnsError_whenResultIsFailure', () {
        // Arrange
        final error = ValidationError(message: 'validation failed');
        final result = Result<String>.failure(error);

        // Act
        final resultError = result.errorOrNull;

        // Assert
        expect(resultError, error);
        expect(resultError?.message, 'validation failed');
      });

      test('dataOrNull_returnsNull_whenResultIsFailure', () {
        // Arrange
        final result = Result<int>.failure(
          NotFoundError(message: 'not found'),
        );

        // Act
        final data = result.dataOrNull;

        // Assert
        expect(data, isNull);
      });
    });

    group('map', () {
      test('map_transformsData_whenResultIsSuccess', () {
        // Arrange
        const result = Result<int>.success(10);

        // Act
        final mapped = result.map((data) => data * 2);

        // Assert
        expect(mapped.isSuccess, true);
        expect(mapped.dataOrNull, 20);
      });

      test('map_returnsFailure_whenResultIsFailure', () {
        // Arrange
        final error = ValidationError(message: 'error');
        final result = Result<int>.failure(error);

        // Act
        final mapped = result.map((data) => data * 2);

        // Assert
        expect(mapped.isFailure, true);
        expect(mapped.errorOrNull, error);
      });

      test('map_catchesException_andReturnsBusinessRuleError', () {
        // Arrange
        const result = Result<int>.success(10);

        // Act
        final mapped = result.map((data) {
          throw Exception('transform failed');
        });

        // Assert
        expect(mapped.isFailure, true);
        expect(mapped.errorOrNull, isA<BusinessRuleError>());
        expect(
          mapped.errorOrNull?.message,
          contains('Transform failed'),
        );
      });
    });

    group('flatMap', () {
      test('flatMap_transformsToNewResult_whenResultIsSuccess', () async {
        // Arrange
        const result = Result<int>.success(5);

        // Act
        final flatMapped = await result.flatMap((data) async {
          return Result<String>.success('Value: $data');
        });

        // Assert
        expect(flatMapped.isSuccess, true);
        expect(flatMapped.dataOrNull, 'Value: 5');
      });

      test('flatMap_returnsFailure_whenResultIsFailure', () async {
        // Arrange
        final error = NotFoundError(message: 'not found');
        final result = Result<int>.failure(error);

        // Act
        final flatMapped = await result.flatMap((data) async {
          return Result<String>.success('Value: $data');
        });

        // Assert
        expect(flatMapped.isFailure, true);
        expect(flatMapped.errorOrNull, error);
      });

      test('flatMap_catchesException_andReturnsBusinessRuleError', () async {
        // Arrange
        const result = Result<int>.success(10);

        // Act
        final flatMapped = await result.flatMap((data) async {
          throw Exception('async transform failed');
        });

        // Assert
        expect(flatMapped.isFailure, true);
        expect(flatMapped.errorOrNull, isA<BusinessRuleError>());
        expect(
          flatMapped.errorOrNull?.message,
          contains('Transform failed'),
        );
      });
    });

    group('when', () {
      test('when_executesSuccessBranch_whenResultIsSuccess', () {
        // Arrange
        const result = Result<int>.success(42);

        // Act
        final output = result.when(
          success: (data) => 'Success: $data',
          failure: (error) => 'Failure: ${error.message}',
        );

        // Assert
        expect(output, 'Success: 42');
      });

      test('when_executesFailureBranch_whenResultIsFailure', () {
        // Arrange
        final result = Result<int>.failure(
          ValidationError(message: 'validation error'),
        );

        // Act
        final output = result.when(
          success: (data) => 'Success: $data',
          failure: (error) => 'Failure: ${error.message}',
        );

        // Assert
        expect(output, 'Failure: validation error');
      });
    });
  });
}
