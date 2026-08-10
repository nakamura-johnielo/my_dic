import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/session/session_scope_key.dart';
import 'package:my_dic/core/session/session_scope_provider.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word/create/register_my_word/i_register_my_word_use_case.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word/create/register_my_word/register_my_word_input_data.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word/load_my_word/i_load_my_word_use_case.dart';
import 'package:my_dic/features/my_word/internal/application/usecase/my_word/load_my_word/load_my_word_input_data.dart';
import 'package:my_dic/features/my_word/internal/domain/entity/my_word.dart';
import 'package:my_dic/features/my_word/internal/di/usecase_di.dart';
import 'package:my_dic/features/my_word/internal/presentation/view/my_word_fragment.dart';

void main() {
  testWidgets('mounted ready scope owns automatic zero page load',
      (tester) async {
    final loader = _LoadWords();
    const scope = SessionScopeKey(accountScope: 'guest', epoch: 1);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        sessionScopeKeyProvider.overrideWithValue(scope),
        loadMyWordUseCaseProvider.overrideWithValue(loader),
        registerMyWordUseCaseProvider.overrideWithValue(_RegisterWords()),
      ],
      child: const MaterialApp(home: MyWordFragment()),
    ));
    await tester.pump();

    expect(loader.pages, [0]);
    expect(find.text('No saved words yet.'), findsOneWidget);
  });

  testWidgets('intermediate session detaches without making a repository call',
      (tester) async {
    final loader = _LoadWords();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        sessionScopeKeyProvider.overrideWithValue(null),
        loadMyWordUseCaseProvider.overrideWithValue(loader),
        registerMyWordUseCaseProvider.overrideWithValue(_RegisterWords()),
      ],
      child: const MaterialApp(home: MyWordFragment()),
    ));
    await tester.pump();

    expect(loader.pages, isEmpty);
  });
}

class _LoadWords implements ILoadMyWordUseCase {
  final pages = <int>[];
  @override
  Future<Result<List<String>>> executeIds(LoadMyWordInputData input) async {
    pages.add(input.requiredPage);
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
