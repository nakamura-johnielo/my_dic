import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/application/usecase/fetch_conjugation/fetch_conjugation_input_data.dart';
import 'package:my_dic/core/application/usecase/fetch_conjugation/i_fetch_conjugation_use_case.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacions.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/quiz/application/fetch_english_conj/i_fetch_english_conj_usecase.dart';
import 'package:my_dic/features/quiz/consts/card_state.dart';
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
  QuizGameViewModel createViewModel() => QuizGameViewModel(
        _FakeFetchEspConjugationUseCase(),
        _FakeFetchEnglishConjUseCase(),
      );

  test('initialize selects the first question and resets the card to question',
      () {
    final viewModel = createViewModel();

    viewModel.toggleQuizCardStatus();
    viewModel.initialize();

    expect(viewModel.state.allLength, greaterThan(0));
    expect(viewModel.state.currentIndex, 0);
    expect(viewModel.state.hasCurrentQuestion, isTrue);
    expect(viewModel.state.quizCardState, QuizCardState.question);
  });
}
