import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/quiz/port/presentation_dependencies.dart';
import 'package:my_dic/features/quiz/internal/presentation/ui_model/quiz_search_model.dart';
import 'package:my_dic/features/quiz/internal/presentation/view_model/quiz_search_view_model.dart';

final quizSearchViewModelProvider =
    StateNotifierProvider<QuizSearchViewModel, QuizSearchState>((ref) =>
        QuizSearchViewModel(ref.read(quizCandidateSourceDependencyProvider)));
