import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_dic/core/presentation/state/command_state.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/internal/presentation/view_model/my_word_status_command.dart';
import 'package:my_dic/features/my_word/port/my_word.dart';

final class _MockMyWordStatusCommands extends Mock
    implements MyWordStatusCommandPort {}

void main() {
  setUpAll(() {
    registerFallbackValue(const UpdateMyWordStatusCommand(
      myWordId: 'fallback',
      accountScope: 'fallback',
    ));
  });

  test('status command failure reaches the presentation command state',
      () async {
    const accountId = 'account-a';
    final commands = _MockMyWordStatusCommands();
    final error = DatabaseError(message: 'status write failed');
    when(() => commands.updateStatus(any()))
        .thenAnswer((_) async => Result.failure(error));
    final command = MyWordStatusCommand(
      'word-1',
      commands,
      const SessionScopeKey(accountScope: accountId, epoch: 1),
    );

    command.toggleBookmark(false);
    await Future<void>.delayed(Duration.zero);

    expect(command.state.command, isA<CommandFailed>());
    verify(() => commands.updateStatus(any())).called(1);
  });
}
