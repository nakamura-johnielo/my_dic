import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/app/routing/contracts/quiz_game_route.dart';
import 'package:my_dic/core/application/usecase/fetch_conjugation/fetch_conjugation_input_data.dart';
import 'package:my_dic/core/application/usecase/fetch_conjugation/i_fetch_conjugation_use_case.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacions.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/quiz/application/fetch_english_conj/i_fetch_english_conj_usecase.dart';
import 'package:my_dic/features/quiz/consts/card_state.dart';
import 'package:my_dic/features/quiz/di/provider_di.dart';
import 'package:my_dic/features/quiz/di/view_model_di.dart';
import 'package:my_dic/features/quiz/presentation/view/quiz_game_fragment.dart';
import 'package:my_dic/features/quiz/presentation/view_model/quiz_game_viewmodel.dart';

class _FakeFetchEspConjugationUseCase implements IFetchEspConjugationUseCase {
  @override
  Future<Result<EspConjugacions?>> execute(
    FetchConjugationInputData input,
  ) async =>
      const Result.success(null);
}

class _FakeFetchEnglishConjUseCase implements IFetchEnglishConjUseCase {
  @override
  Future<Result<Map<String, String>>> execute(int wordId) async =>
      const Result.success({});
}

void main() {
  testWidgets('initializes the quiz when the fragment is entered',
      (tester) async {
    final viewModel = QuizGameViewModel(
      _FakeFetchEspConjugationUseCase(),
      _FakeFetchEnglishConjUseCase(),
    );
    final container = ProviderContainer(overrides: [
      quizGameViewModelProvider.overrideWith((ref) => viewModel),
      conjEnglishProvider.overrideWith((ref) async => const {}),
      beConjProvider.overrideWith((ref) async => const {}),
      englishConjByWordIdProvider(1).overrideWith((ref) async => const {}),
      quizConjugacionsProvider(1).overrideWith((ref) async => null),
    ]);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: QuizGameFragment(
            route: QuizGameRoute(wordId: 1, word: 'hablar'),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(viewModel.state.currentIndex, 0);
    expect(viewModel.state.hasCurrentQuestion, isTrue);
    expect(viewModel.state.quizCardState, QuizCardState.question);
  });
}
