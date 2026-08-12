import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/quiz/port/candidate_source.dart';
import 'package:my_dic/features/quiz/port/model/quiz_candidate.dart';
import 'package:my_dic/features/quiz/port/model/quiz_candidate_issue.dart';
import 'package:my_dic/features/quiz/port/model/quiz_candidate_page.dart';
import 'package:my_dic/features/quiz/port/model/quiz_candidate_query.dart';

void main() {
  const word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 7);
  const candidate = QuizCandidate(
    word: word,
    headword: 'hablar',
    meaningText: 'to speak',
    rankingNo: 3,
    starCount: 4,
  );

  test('query accepts only non-negative pages and positive sizes', () {
    const query = QuizCandidateQuery(text: ' hablar ', page: 0, size: 30);

    expect(query.text, ' hablar ');
    expect(
      () => QuizCandidateQuery(text: 'hablar', page: -1, size: 30),
      throwsAssertionError,
    );
    expect(
      () => QuizCandidateQuery(text: 'hablar', page: 0, size: 0),
      throwsAssertionError,
    );
  });

  test('candidate retains its typed Catalog identity and value semantics', () {
    expect(candidate.word, word);
    expect(
      candidate,
      const QuizCandidate(
        word: CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 7),
        headword: 'hablar',
        meaningText: 'to speak',
        rankingNo: 3,
        starCount: 4,
      ),
    );
  });

  test('page defensively copies candidate and issue collections', () {
    final candidates = [candidate];
    final issues = [
      QuizCandidateIssue(
        source: 'meaning',
        error: DatabaseError(message: 'Meaning lookup failed.'),
      ),
    ];
    final page = QuizCandidatePage(
      candidates: candidates,
      hasNext: true,
      issues: issues,
    );

    candidates.clear();
    issues.clear();

    expect(page.candidates, [candidate]);
    expect(page.issues, hasLength(1));
    expect(() => page.candidates.clear(), throwsUnsupportedError);
    expect(() => page.issues.clear(), throwsUnsupportedError);
  });

  test('source returns typed Result failures', () async {
    final source = _FailingSource();
    final result = await source.search(
      const QuizCandidateQuery(text: 'hablar', page: 0, size: 30),
    );

    expect(result, isA<Failure<QuizCandidatePage>>());
    expect(result.errorOrNull, isA<DatabaseError>());
  });

  test('Quiz candidate contract is independent of Search and UI frameworks',
      () {
    final source = Directory('lib/features/quiz/port')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .map((file) => file.readAsStringSync())
        .join('\n');

    for (final forbidden in [
      'features/search',
      'package:flutter/',
      'flutter_riverpod',
      'package:drift/',
    ]) {
      expect(source, isNot(contains(forbidden)), reason: forbidden);
    }
  });
}

final class _FailingSource implements QuizCandidateSource {
  @override
  Future<Result<QuizCandidatePage>> search(QuizCandidateQuery query) async =>
      Result.failure(
          DatabaseError(message: 'Unable to search quiz candidates.'));
}
