import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/quiz/internal/game/presentation/ui_model/quiz_game_state.dart';
import 'package:my_dic/features/quiz/internal/game/presentation/view_model/quiz_game_viewmodel.dart';

final quizGameViewModelProvider =
    StateNotifierProvider<QuizGameViewModel, QuizGameState>(
        (ref) => QuizGameViewModel());
