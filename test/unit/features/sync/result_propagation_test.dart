import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_dic/core/presentation/state/command_state.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word_status/update_my_word_status/update_my_word_status_interactor.dart';
import 'package:my_dic/features/my_word/internal/domain/i_repository/i_my_word_status_repository.dart';
import 'package:my_dic/features/my_word/internal/domain/model/my_word_status/update_my_word_status_repository_input_data.dart';
import 'package:my_dic/features/my_word/internal/presentation/view_model/my_word_status_command.dart';

import 'package:my_dic/core/session/session_scope_key.dart';

class _MockMyWordStatusRepository extends Mock
    implements IMyWordStatusRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(UpdateMyWordStatusRepositoryInputData(
      'fallback',
      null,
      null,
      null,
      DateTime.utc(2026),
      null,
    ));
  });

  test('status repository failure reaches the command as a failed state',
      () async {
    const accountId = 'account-a';
    final statusRepository = _MockMyWordStatusRepository();
    final error = DatabaseError(message: 'status write failed');
    when(() => statusRepository.updateStatus(any()))
        .thenAnswer((_) async => Result.failure(error));
    final interactor = UpdateMyWordStatusInteractor(statusRepository);
    final command = MyWordStatusCommand(
      'word-1',
      interactor,
      const SessionScopeKey(accountScope: accountId, epoch: 1),
    );

    command.toggleBookmark(false);
    await Future<void>.delayed(Duration.zero);

    expect(command.state.command, isA<CommandFailed>());
    verify(() => statusRepository.updateStatus(any())).called(1);
  });
}
