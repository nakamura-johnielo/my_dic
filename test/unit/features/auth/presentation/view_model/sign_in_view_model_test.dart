import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/presentation/state/ui_effect.dart';
import 'package:my_dic/features/auth/internal/presentation/view_model/sign_in_view_model.dart';
import 'package:my_dic/features/auth/port/auth.dart';

void main() {
  test('reset password succeeds and the notice is consumed once', () async {
    final useCase = _ResetPasswordUseCase();
    final viewModel = SignInViewModel(useCase);

    await viewModel.resetEmailPassword('person@example.com');

    expect(useCase.email, 'person@example.com');
    expect(viewModel.state.command.isSucceeded, isTrue);
    final effect = viewModel.pendingEffect!;
    expect((effect.effect as UiNoticeEffect).message,
        'Password reset email sent.');

    viewModel.consumeEffect('stale');
    expect(viewModel.pendingEffect, same(effect));
    viewModel.consumeEffect(effect.id);
    expect(viewModel.pendingEffect, isNull);
  });

  test('reset password exposes a typed failure notice', () async {
    final viewModel = SignInViewModel(
      _ResetPasswordUseCase(
        result: Result.failure(ValidationError(message: 'Invalid email')),
      ),
    );

    await viewModel.resetEmailPassword('invalid');

    expect(viewModel.state.command.isFailed, isTrue);
    expect(viewModel.state.command.errorOrNull, isA<ValidationError>());
    expect(viewModel.pendingEffect?.effect, isA<UiNoticeEffect>());
  });

  test('reset password ignores a second submit while the first is pending',
      () async {
    final useCase = _ResetPasswordUseCase(deferred: true);
    final viewModel = SignInViewModel(useCase);

    final first = viewModel.resetEmailPassword('person@example.com');
    await Future<void>.delayed(Duration.zero);
    await viewModel.resetEmailPassword('other@example.com');
    expect(useCase.callCount, 1);

    useCase.complete();
    await first;
    expect(viewModel.state.command.isSucceeded, isTrue);
  });
}

class _ResetPasswordUseCase implements AuthCommandPort {
  _ResetPasswordUseCase({Result<void>? result, this.deferred = false})
      : _result = result ?? const Result.success(null);

  final Result<void> _result;
  final bool deferred;
  final _completer = Completer<Result<void>>();
  int callCount = 0;
  String? email;

  @override
  Future<Result<void>> resetPassword(ResetPasswordCommand command) {
    callCount++;
    email = command.email;
    return deferred ? _completer.future : Future.value(_result);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  void complete() => _completer.complete(_result);
}
