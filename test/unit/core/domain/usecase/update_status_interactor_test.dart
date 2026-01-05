/// Test for UpdateStatusInteractor UseCase
/// Priority: ★★★★★ (Critical business logic with local/remote sync)
/// 
/// Tests demonstrate:
/// - Complex business logic with dual local+remote updates
/// - Offline mode handling (anonymous/logout users)
/// - Partial failure scenarios (local succeeds, remote fails)
/// - Fake repository for testing sync logic

import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/update_status/update_status_input_data.dart';
import 'package:my_dic/features/esp_jpn_word_status/domain/usecase/update_status/update_status_interactor.dart';
import 'package:my_dic/core/shared/enums/feature_tag.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';

import '../../../../helpers/fake_word_status_repository.dart';

void main() {
  group('UpdateStatusInteractor', () {
    group('Logged-in User Scenario', () {
      test('execute_updatesLocalAndRemote_whenUserIsLoggedIn', () async {
        // Arrange
        final repository = FakeWordStatusRepository.success();
        final useCase = UpdateStatusInteractor(repository);
        final input = UpdateStatusInputData(
          'user-123',
          100,
          {FeatureTag.isBookmarked, FeatureTag.isLearned},
        );

        // Act
        final result = await useCase.execute(input);

        // Assert
        expect(result.isSuccess, true);

        // Verify local update was called
        expect(repository.localUpdateCallCount, 1);
        expect(repository.lastLocalWordStatus?.wordId, 100);
        expect(repository.lastLocalWordStatus?.isBookmarked, true);
        expect(repository.lastLocalWordStatus?.isLearned, true);
        expect(repository.lastLocalWordStatus?.hasNote, false);

        // Verify remote update was also called for logged-in user
        expect(repository.remoteUpdateCallCount, 1);
        expect(repository.lastRemoteWordStatus?.wordId, 100);
        expect(repository.lastRemoteWordStatus?.isBookmarked, true);
        expect(repository.lastUserId, 'user-123');
      });

      test('execute_setsCorrectFeatureFlags_basedOnInputStatus', () async {
        // Arrange
        final repository = FakeWordStatusRepository.success();
        final useCase = UpdateStatusInteractor(repository);
        final input = UpdateStatusInputData(
          'user-456',
          200,
          {FeatureTag.hasNote}, // Only hasNote
        );

        // Act
        await useCase.execute(input);

        // Assert
        expect(repository.lastLocalWordStatus?.hasNote, true);
        expect(repository.lastLocalWordStatus?.isBookmarked, false);
        expect(repository.lastLocalWordStatus?.isLearned, false);
      });

      test('execute_setsAllFlagsToFalse_whenStatusIsEmpty', () async {
        // Arrange
        final repository = FakeWordStatusRepository.success();
        final useCase = UpdateStatusInteractor(repository);
        final input = UpdateStatusInputData(
          'user-789',
          300,
          {}, // Empty status
        );

        // Act
        await useCase.execute(input);

        // Assert
        expect(repository.lastLocalWordStatus?.isBookmarked, false);
        expect(repository.lastLocalWordStatus?.isLearned, false);
        expect(repository.lastLocalWordStatus?.hasNote, false);
      });
    });

    group('Anonymous/Logout User Scenario', () {
      test('execute_updatesLocalOnly_whenUserIsAnonymous', () async {
        // Arrange
        final repository = FakeWordStatusRepository.success();
        final useCase = UpdateStatusInteractor(repository);
        final input = UpdateStatusInputData(
          'anonymous', // Anonymous user
          400,
          {FeatureTag.isBookmarked},
        );

        // Act
        final result = await useCase.execute(input);

        // Assert
        expect(result.isSuccess, true);

        // Verify local update was called
        expect(repository.localUpdateCallCount, 1);

        // Verify remote update was NOT called
        expect(repository.remoteUpdateCallCount, 0);
      });

      test('execute_updatesLocalOnly_whenUserIsLogout', () async {
        // Arrange
        final repository = FakeWordStatusRepository.success();
        final useCase = UpdateStatusInteractor(repository);
        final input = UpdateStatusInputData(
          'logout', // Logout user
          500,
          {FeatureTag.isLearned},
        );

        // Act
        final result = await useCase.execute(input);

        // Assert
        expect(result.isSuccess, true);

        // Verify local update was called
        expect(repository.localUpdateCallCount, 1);

        // Verify remote update was NOT called
        expect(repository.remoteUpdateCallCount, 0);
      });
    });

    group('Failure Scenarios', () {
      test('execute_returnsFailure_whenLocalUpdateFails', () async {
        // Arrange
        final repository = FakeWordStatusRepository.localFailure();
        final useCase = UpdateStatusInteractor(repository);
        final input = UpdateStatusInputData(
          'user-123',
          600,
          {FeatureTag.isBookmarked},
        );

        // Act
        final result = await useCase.execute(input);

        // Assert
        expect(result.isFailure, true);
        expect(result.errorOrNull, isA<DatabaseError>());
        expect(
          result.errorOrNull?.message,
          'ローカルDB更新に失敗しました',
        );

        // Verify local was attempted
        expect(repository.localUpdateCallCount, 1);

        // Verify remote was NOT attempted (because local failed)
        expect(repository.remoteUpdateCallCount, 0);
      });

      test('execute_returnsSuccess_whenRemoteUpdateFails_butLocalSucceeds', () async {
        // Arrange
        final repository = FakeWordStatusRepository.remoteFailure();
        final useCase = UpdateStatusInteractor(repository);
        final input = UpdateStatusInputData(
          'user-123',
          700,
          {FeatureTag.isLearned},
        );

        // Act
        final result = await useCase.execute(input);

        // Assert
        // Should still return success because local update succeeded
        // (remote failure is logged but not returned as error)
        expect(result.isSuccess, true);

        // Verify both updates were attempted
        expect(repository.localUpdateCallCount, 1);
        expect(repository.remoteUpdateCallCount, 1);
      });
    });

    group('Timestamp Handling', () {
      test('execute_setsEditAtTimestamp_forWordStatus', () async {
        // Arrange
        final repository = FakeWordStatusRepository.success();
        final useCase = UpdateStatusInteractor(repository);
        final input = UpdateStatusInputData(
          'user-123',
          800,
          {FeatureTag.isBookmarked},
        );
        final beforeExecution = DateTime.now().toUtc();

        // Act
        await useCase.execute(input);

        // Assert
        final afterExecution = DateTime.now().toUtc();
        final editAt = repository.lastLocalWordStatus?.editAt;

        expect(editAt, isNotNull);
        expect(
          editAt!.isAfter(beforeExecution.subtract(const Duration(seconds: 1))),
          true,
        );
        expect(
          editAt.isBefore(afterExecution.add(const Duration(seconds: 1))),
          true,
        );
      });
    });
  });
}
