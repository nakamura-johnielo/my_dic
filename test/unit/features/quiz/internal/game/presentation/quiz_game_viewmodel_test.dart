import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/quiz/internal/consts/card_state.dart';
import 'package:my_dic/features/quiz/internal/game/presentation/view_model/quiz_game_viewmodel.dart';

void main() {
  QuizGameViewModel createViewModel() => QuizGameViewModel();

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
