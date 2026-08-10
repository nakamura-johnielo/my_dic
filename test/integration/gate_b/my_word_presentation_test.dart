import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word/create/register_my_word/i_register_my_word_use_case.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word/create/register_my_word/register_my_word_input_data.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word/load_my_word/i_load_my_word_use_case.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word/load_my_word/load_my_word_input_data.dart';
import 'package:my_dic/features/my_word/internal/domain/entity/my_word.dart';
import 'package:my_dic/features/my_word/internal/di/usecase_di.dart';
import 'package:my_dic/features/my_word/internal/di/view_model_di.dart';

void main() {
  test('a new session epoch gets a re-keyed VM and fresh zero page', () async {
    final loader = _LoadWords();
    final container = ProviderContainer(overrides: [
      loadMyWordUseCaseProvider.overrideWithValue(loader),
      registerMyWordUseCaseProvider.overrideWithValue(_RegisterWords()),
    ]);
    addTearDown(container.dispose);
    const first = SessionScopeKey(accountScope: 'guest', epoch: 1);
    const second = SessionScopeKey(accountScope: 'guest', epoch: 2);
    final a = container.read(myWordFragmentViewModelProvider(first).notifier);
    final b = container.read(myWordFragmentViewModelProvider(second).notifier);
    expect(identical(a, b), isFalse);
    await a.loadPage(size: 30, page: 0);
    await b.loadPage(size: 30, page: 0);
    expect(loader.accounts, ['guest', 'guest']);
    expect(loader.pages, [0, 0]);
  });
}

class _LoadWords implements ILoadMyWordUseCase {
  final pages = <int>[];
  final accounts = <String>[];
  @override
  Future<Result<List<String>>> executeIds(LoadMyWordInputData input) async {
    pages.add(input.requiredPage);
    accounts.add(input.accountScope);
    return const Result.success([]);
  }

  @override
  Future<Result<List<MyWord>>> execute(LoadMyWordInputData input) =>
      throw UnimplementedError();
}

class _RegisterWords implements IRegisterMyWordUseCase {
  @override
  Future<Result<String>> execute(RegisterMyWordInputData input) async =>
      const Result.success('id');
}
