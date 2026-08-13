import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/quiz/internal/presentation/view/quiz_search_fragment.dart';
import 'package:my_dic/features/quiz/port/presentation_dependencies.dart';
import 'package:my_dic/features/quiz/port/error/quiz_candidate_issue.dart';
import 'package:my_dic/features/quiz/port/query/quiz_candidate_query.dart';
import 'package:my_dic/features/quiz/port/reader/quiz_candidate_reader_port.dart';
import 'package:my_dic/features/quiz/port/result/quiz_candidate_page.dart';

void main() {
  testWidgets(
      'query change removes old candidates while the new page is loading',
      (tester) async {
    final source = _Source();
    await tester.pumpWidget(_app(source));

    await tester.enterText(find.byType(TextField), 'hablar');
    await tester.pump();
    source.completeNext(_page('hablar'));
    await tester.pumpAndSettle();
    expect(find.text('hablar'), findsWidgets);

    await tester.enterText(find.byType(TextField), 'comer');
    await tester.pump();
    expect(find.text('hablar'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('primary failure exposes a retry action', (tester) async {
    final source = _Source();
    await tester.pumpWidget(_app(source));

    await tester.enterText(find.byType(TextField), 'hablar');
    await tester.pump();
    source.failNext();
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(source.pending, hasLength(1));
  });

  testWidgets('renders non-fatal candidate warnings with data', (tester) async {
    final source = _Source();
    await tester.pumpWidget(_app(source));

    await tester.enterText(find.byType(TextField), 'hablar');
    await tester.pump();
    source.completeNext(QuizCandidatePage(
      candidates: _page('hablar').candidates,
      hasNext: false,
      issues: [
        QuizCandidateIssue(
          source: QuizCandidateIssueSource.ranking,
          error: DatabaseError(message: 'ranking unavailable'),
        ),
      ],
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('quiz-search-warnings')), findsOneWidget);
  });
}

Widget _app(_Source source) => ProviderScope(
      overrides: [
        quizCandidateReaderDependencyProvider.overrideWithValue(source)
      ],
      child: MaterialApp(home: QuizSearchFragment(onOpenQuiz: (_, __) {})),
    );

QuizCandidatePage _page(String word, {bool hasNext = false}) =>
    QuizCandidatePage(
      candidates: [
        QuizCandidate(
          word:
              const CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 1),
          headword: word,
          meaningText: word,
          rankingNo: null,
          starCount: null,
        ),
      ],
      hasNext: hasNext,
      issues: const [],
    );

final class _Source implements QuizCandidateQueryPort {
  final pending = <Completer<Result<QuizCandidatePage>>>[];
  @override
  Future<Result<QuizCandidatePage>> search(QuizCandidateQuery query) {
    final result = Completer<Result<QuizCandidatePage>>();
    pending.add(result);
    return result.future;
  }

  void completeNext(QuizCandidatePage page) =>
      pending.removeAt(0).complete(Result.success(page));
  void failNext() => pending.removeAt(0).complete(
        Result.failure(DatabaseError(message: 'temporary failure')),
      );
}
