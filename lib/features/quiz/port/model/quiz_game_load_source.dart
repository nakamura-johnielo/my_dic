/// The independently loaded input that was unavailable while loading a game.
///
/// This is deliberately a source label, not an error classification. Gate B
/// owns the user-visible semantics and recovery policy for these failures.
enum QuizGameLoadSource {
  catalogConjugation,
  englishConjugation,
  englishGuide,
  beConjugation,
}
