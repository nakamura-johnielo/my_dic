import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/quiz/internal/presentation/view_model/quiz_search_view_model.dart';
import 'package:my_dic/features/quiz/port/candidate_source.dart';
import 'package:my_dic/features/quiz/port/model/quiz_candidate.dart';
import 'package:my_dic/features/quiz/port/model/quiz_candidate_issue.dart';
import 'package:my_dic/features/quiz/port/model/quiz_candidate_page.dart';
import 'package:my_dic/features/quiz/port/model/quiz_candidate_query.dart';

void main() {
  group('QuizSearchViewModel Gate B', () {
    late _DeferredSource source;
    late QuizSearchViewModel subject;

    setUp(() {
      source = _DeferredSource();
      subject = QuizSearchViewModel(source);
    });
    tearDown(() {
      if (subject.mounted) subject.dispose();
    });

    test(
        'a new query is loading immediately and an old response cannot publish',
        () async {
      subject.updateQuery('Q0');
      final q0 = subject.loadSearchResults(30, 0);
      subject.updateQuery(' Q1 ');

      expect(subject.state.query, 'Q1');
      expect(subject.state.results, isA<QueryLoading>());
      expect(subject.state.results.dataOrNull, isNull);

      source.completeNext(_page(['old'], hasNext: false));
      expect(await q0, isFalse);
      expect(subject.state.query, 'Q1');
      expect(subject.state.results.dataOrNull, isNull);
    });

    test(
        'replaces page zero, appends page one, and de-duplicates Catalog words',
        () async {
      subject.updateQuery('hablar');
      final first = subject.loadSearchResults(30, 0);
      source.completeNext(_page(['hablar', 'hablo'], hasNext: true));
      expect(await first, isTrue);

      final second = subject.loadSearchResults(30, 1);
      source.completeNext(
          _page(['hablo', 'hablamos'], hasNext: false, firstId: 2));
      expect(await second, isFalse);

      expect(subject.state.results.dataOrNull!.items.map((it) => it.headword),
          ['hablar', 'hablo', 'hablamos']);
      expect(source.queries.map((query) => query.page), [0, 1]);
    });

    test(
        'retries the failed page with a new attempt and only one active request',
        () async {
      subject.updateQuery('hablar');
      final page0 = subject.loadSearchResults(30, 0);
      source.completeNext(_page(['hablar'], hasNext: true));
      await page0;

      final failed = subject.loadSearchResults(30, 1);
      expect(await subject.loadSearchResults(30, 1), isFalse);
      source.completeNextError();
      expect(await failed, isFalse);
      expect(subject.state.results, isA<QueryFailure>());

      final retry = subject.retryFailed();
      source.completeNext(_page(['hablamos'], hasNext: false, firstId: 2));
      expect(await retry, isFalse);
      expect(source.queries.map((query) => query.page), [0, 1, 1]);
      expect(subject.state.results.dataOrNull!.items.map((it) => it.headword),
          ['hablar', 'hablamos']);
    });

    test('publishes warning-bearing empty results', () async {
      subject.updateQuery('none');
      final request = subject.loadSearchResults(30, 0);
      source.completeNext(QuizCandidatePage(
        candidates: const [],
        hasNext: false,
        issues: [
          QuizCandidateIssue(
            source: 'ranking',
            error: DatabaseError(message: 'ranking unavailable'),
          ),
        ],
      ));
      await request;
      expect(subject.state.results, isA<QueryEmpty>());
      expect(subject.state.results.warnings.single.source, 'ranking');
    });

    test('does not publish when disposed during completion', () async {
      subject.updateQuery('hablar');
      final request = subject.loadSearchResults(30, 0);
      subject.dispose();
      source.completeNext(_page(['hablar'], hasNext: false));
      expect(await request, isFalse);
    });
  });
}

QuizCandidatePage _page(List<String> names,
        {required bool hasNext, int firstId = 1}) =>
    QuizCandidatePage(
      candidates: [
        for (var index = 0; index < names.length; index++)
          _candidate(names[index], firstId + index),
      ],
      hasNext: hasNext,
      issues: const [],
    );

QuizCandidate _candidate(String text, int id) => QuizCandidate(
      word: CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: id),
      headword: text,
      meaningText: text,
      rankingNo: null,
      starCount: null,
    );

final class _DeferredSource implements QuizCandidateSource {
  final queries = <QuizCandidateQuery>[];
  final _pending = <Completer<Result<QuizCandidatePage>>>[];

  @override
  Future<Result<QuizCandidatePage>> search(QuizCandidateQuery query) {
    queries.add(query);
    final response = Completer<Result<QuizCandidatePage>>();
    _pending.add(response);
    return response.future;
  }

  void completeNext(QuizCandidatePage page) =>
      _pending.removeAt(0).complete(Result.success(page));
  void completeNextError() => _pending.removeAt(0).complete(
        Result.failure(DatabaseError(message: 'temporary failure')),
      );
}
