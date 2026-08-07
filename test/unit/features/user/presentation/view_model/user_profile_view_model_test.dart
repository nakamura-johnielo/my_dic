import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/presentation/state/ui_effect.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/user/application/usecase/user_usecases.dart';
import 'package:my_dic/features/user/domain/entity/user.dart';
import 'package:my_dic/features/user/presentation/view_model/user_profile_view_model.dart';

void main() {
  final profile =
      AppUser(deviceId: 'device', email: 'old@example.com', username: 'Old');

  test('save patches only requested fields on the current profile', () async {
    final useCase = _UpdateUserUseCase();
    final viewModel = UserProfileViewModel(useCase);

    await viewModel.save(profile, username: 'New');

    expect(useCase.user?.username, 'New');
    expect(useCase.user?.deviceId, 'device');
    expect(useCase.user?.email, 'old@example.com');
    expect(viewModel.state.command.isSucceeded, isTrue);
    expect(viewModel.pendingEffect?.effect, isA<UiNoticeEffect>());
  });

  test('save retains the typed failure and reports an effect', () async {
    final viewModel = UserProfileViewModel(
      _UpdateUserUseCase(
        result: Result.failure(BusinessRuleError(message: 'Cannot save')),
      ),
    );

    await viewModel.save(profile, email: 'new@example.com');

    expect(viewModel.state.command.isFailed, isTrue);
    expect(viewModel.state.command.errorOrNull, isA<BusinessRuleError>());
    expect(viewModel.pendingEffect?.effect, isA<UiNoticeEffect>());
  });

  test('save ignores a second submit while an update is pending', () async {
    final useCase = _UpdateUserUseCase(deferred: true);
    final viewModel = UserProfileViewModel(useCase);

    final first = viewModel.save(profile, username: 'First');
    await Future<void>.delayed(Duration.zero);
    await viewModel.save(profile, username: 'Second');
    expect(useCase.callCount, 1);

    useCase.complete();
    await first;
    expect(viewModel.state.command.isSucceeded, isTrue);
  });
}

class _UpdateUserUseCase implements IUpdateUserUseCase {
  _UpdateUserUseCase({Result<void>? result, this.deferred = false})
      : _result = result ?? const Result.success(null);

  final Result<void> _result;
  final bool deferred;
  final _completer = Completer<Result<void>>();
  int callCount = 0;
  AppUser? user;

  @override
  Future<Result<void>> execute(AppUser value) {
    callCount++;
    user = value;
    return deferred ? _completer.future : Future.value(_result);
  }

  void complete() => _completer.complete(_result);
}
