/// Input for a paged Quiz candidate search.
final class QuizCandidateQuery {
  const QuizCandidateQuery({
    required this.text,
    required this.page,
    required this.size,
  })  : assert(page >= 0),
        assert(size > 0);

  final String text;
  final int page;
  final int size;
}
