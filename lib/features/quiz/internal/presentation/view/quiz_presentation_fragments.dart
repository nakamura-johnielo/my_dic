/// Internal bridge for Quiz's controlled presentation entry.
///
/// Quiz keeps game and search implementation in separate subfeatures while the
/// public entry imports only this canonical presentation-view seam.
library;

export '../game/view/quiz_game_fragment.dart' show QuizGameFragment;
export '../search/view/quiz_search_fragment.dart' show QuizSearchFragment;
