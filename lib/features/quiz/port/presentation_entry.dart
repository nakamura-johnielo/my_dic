/// The sole public Quiz-game presentation entry.
///
/// Its implementation obtains feature state only through focused Quiz reader
/// contracts; all concrete UI and provider wiring remain feature-internal.
library;

export 'package:my_dic/features/quiz/internal/game/presentation/view/quiz_game_fragment.dart';
export 'package:my_dic/features/quiz/internal/presentation/view/quiz_search_fragment.dart'
    show QuizSearchFragment;
