import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/quiz/application/candidate_search/quiz_candidate.dart';
import 'package:my_dic/features/quiz/application/candidate_search/quiz_candidate_issue.dart';
import 'package:my_dic/features/quiz/application/candidate_search/quiz_candidate_page.dart';
import 'package:my_dic/features/quiz/application/candidate_search/quiz_candidate_query.dart';
import 'package:my_dic/features/quiz/application/candidate_search/quiz_candidate_source.dart';
import 'package:my_dic/features/quiz/presentation/view_model/quiz_search_view_model.dart';

void main() {
  group('QuizSearchViewModel', () {
    late _QuizCandidateSourceFake source;
    late QuizSearchViewModel viewModel;

    setUp(() {
      source = _QuizCandidateSourceFake();
      viewModel = QuizSearchViewModel(source);
      viewModel.updateQuery(' hablar ');
    });

    tearDown(() => viewModel.dispose());

    test('uses the Quiz candidate contract and merges later pages', () async {
      source.responses.addAll([
        Result.success(_page('hablar', hasNext: true)),
        Result.success(_page('hablamos', hasNext: false)),
      ]);

      expect(await viewModel.loadSearchResults(30, 0), isTrue);
      expect(await viewModel.loadSearchResults(30, 1), isFalse);

      expect(source.queries.map((query) => query.text), ['hablar', 'hablar']);
      expect(source.queries.map((query) => query.page), [0, 1]);
      expect(source.queries.map((query) => query.size), [30, 30]);
      expect(
        viewModel.state.results.dataOrNull?.items
            .map((candidate) => candidate.headword),
        ['hablar', 'hablamos'],
      );
    });

    test('keeps previous data for a failed page and supports retry', () async {
      source.responses.addAll([
        Result.success(_page('hablar', hasNext: true)),
        Result.failure(DatabaseError(message: 'temporary failure')),
        Result.success(_page('hablamos', hasNext: false)),
      ]);

      await viewModel.loadSearchResults(30, 0);
      expect(await viewModel.loadSearchResults(30, 1), isFalse);
      expect(viewModel.state.results, isA<QueryFailure>());
      expect(
        viewModel.state.results.dataOrNull?.items.single.headword,
        'hablar',
      );

      await viewModel.loadSearchResults(30, 1);
      expect(
        viewModel.state.results.dataOrNull?.items
            .map((candidate) => candidate.headword),
        ['hablar', 'hablamos'],
      );
    });

    test('drops a stale response after the query changes', () async {
      final pending = Completer<Result<QuizCandidatePage>>();
      source.pendingResponses.add(pending);

      final loading = viewModel.loadSearchResults(30, 0);
      viewModel.updateQuery('comer');
      pending.complete(Result.success(_page('hablar', hasNext: false)));

      expect(await loading, isFalse);
      expect(viewModel.state.query, 'comer');
      expect(viewModel.state.results, isA<QueryLoading>());
    });

    test('maps candidate issues to display warnings', () async {
      final warning = DatabaseError(message: 'ranking unavailable');
      source.responses.add(Result.success(QuizCandidatePage(
        candidates: [_candidate('hablar')],
        hasNext: false,
        issues: [QuizCandidateIssue(source: 'ranking', error: warning)],
      )));

      await viewModel.loadSearchResults(30, 0);

      expect(viewModel.state.results.warnings, hasLength(1));
      expect(viewModel.state.results.warnings.single.source, 'ranking');
      expect(viewModel.state.results.warnings.single.error, warning);
    });
  });
}

QuizCandidatePage _page(String headword, {required bool hasNext}) =>
    QuizCandidatePage(
      candidates: [_candidate(headword)],
      hasNext: hasNext,
      issues: const [],
    );

QuizCandidate _candidate(String headword) => QuizCandidate(
      word: const CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 7),
      headword: headword,
      meaningText: 'to speak',
      rankingNo: 3,
      starCount: 2,
    );

final class _QuizCandidateSourceFake implements QuizCandidateSource {
  final queries = <QuizCandidateQuery>[];
  final responses = <Result<QuizCandidatePage>>[];
  final pendingResponses = <Completer<Result<QuizCandidatePage>>>[];

  @override
  Future<Result<QuizCandidatePage>> search(QuizCandidateQuery query) {
    queries.add(query);
    if (pendingResponses.isNotEmpty) return pendingResponses.removeAt(0).future;
    return Future.value(responses.removeAt(0));
  }
}
