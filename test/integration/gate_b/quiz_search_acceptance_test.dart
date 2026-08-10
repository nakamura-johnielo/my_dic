import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/quiz/port/candidate_source.dart';
import 'package:my_dic/features/quiz/port/model/quiz_candidate.dart';
import 'package:my_dic/features/quiz/port/model/quiz_candidate_page.dart';
import 'package:my_dic/features/quiz/port/model/quiz_candidate_query.dart';
import 'package:my_dic/features/quiz/port/presentation_dependencies.dart';
import 'package:my_dic/features/quiz/port/presentation_entry.dart';

void main() {
  testWidgets('Gate B: catalog bridge page retry and stale query completion',
      (tester) async {
    final bridge = _Bridge();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        quizCandidateSourceDependencyProvider.overrideWithValue(bridge)
      ],
      child: MaterialApp(home: QuizSearchFragment(onOpenQuiz: (_, __) {})),
    ));

    await tester.enterText(find.byType(TextField), 'hablar');
    await tester.pump();
    bridge.completeNext(_page('hablar', startId: 1, count: 60, hasNext: true));
    await tester.pump();

    await tester.drag(find.byType(Scrollable).last, const Offset(0, -6000));
    await tester.pump();
    expect(bridge.pending, hasLength(1));
    bridge.failNext();
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(bridge.pending, hasLength(1));
    bridge
        .completeNext(_page('hablamos', startId: 61, count: 1, hasNext: false));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'comer');
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'vivir');
    await tester.pump();
    bridge.completeNext(_page('comer', startId: 100, count: 1, hasNext: false));
    await tester.pump();
    expect(find.text('comer 0'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}

QuizCandidatePage _page(
  String prefix, {
  required int startId,
  required int count,
  required bool hasNext,
}) =>
    QuizCandidatePage(
      candidates: [
        for (var index = 0; index < count; index++)
          QuizCandidate(
            word: CatalogWordRef(
                catalogId: CatalogId.espJpnMain, wordId: startId + index),
            headword: '$prefix $index',
            meaningText: prefix,
            rankingNo: null,
            starCount: null,
          ),
      ],
      hasNext: hasNext,
      issues: const [],
    );

final class _Bridge implements QuizCandidateSource {
  final pending = <Completer<Result<QuizCandidatePage>>>[];
  @override
  Future<Result<QuizCandidatePage>> search(QuizCandidateQuery query) {
    final response = Completer<Result<QuizCandidatePage>>();
    pending.add(response);
    return response.future;
  }

  void completeNext(QuizCandidatePage value) =>
      pending.removeAt(0).complete(Result.success(value));
  void failNext() => pending.removeAt(0).complete(
        Result.failure(DatabaseError(message: 'page one failed')),
      );
}
