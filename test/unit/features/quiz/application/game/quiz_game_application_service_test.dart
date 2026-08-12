import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/features/quiz/internal/application/game/quiz_game_application_service.dart';
import 'package:my_dic/features/quiz/internal/application/game/quiz_game_asset_reader.dart';
import 'package:my_dic/features/quiz/internal/application/game/quiz_game_english_reader.dart';
import 'package:my_dic/features/quiz/port/quiz.dart';

const _word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 9);

void main() {
  test('checks primary then optional conjugation before any enrichment',
      () async {
    final calls = <String>[];
    final reader = _English(calls);
    final assets = _Assets(calls);
    final result = await QuizGameApplicationService(
      catalogGateway: _Gateway(calls),
      englishReader: reader,
      assetReader: assets,
    ).load(const QuizGameQuery(_word));

    expect(result, isA<Success<QuizGameLoadOutcome>>());
    expect(calls, ['primary', 'conjugation', 'guide', 'be', 'english']);
    final game =
        ((result as Success<QuizGameLoadOutcome>).data as QuizGameReady).game;
    expect(
        game.conjugation.form(QuizMoodTense.indicativePresent, QuizSubject.yo),
        'hablo');
    expect(game.englishConjugation.form(QuizEnglishMoodTense.indicativePresent),
        'speak');
    expect(
        game.promptGuide.templateFor(QuizMoodTense.indicativePresent), '@ #');
    expect(
        game.beConjugation
            .form(QuizEnglishMoodTense.indicativePresent, QuizEnglishSubject.i),
        'am');
  });

  test('returns no-data outcomes without starting later reads', () async {
    final calls = <String>[];
    final result = await QuizGameApplicationService(
      catalogGateway: _Gateway(calls, primary: const Result.success(null)),
      englishReader: _English(calls),
      assetReader: _Assets(calls),
    ).load(const QuizGameQuery(_word));

    expect((result as Success<QuizGameLoadOutcome>).data,
        isA<QuizGamePrimaryNotFound>());
    expect(calls, ['primary']);
  });

  test('normalizes a dependency failure to its typed source', () async {
    final calls = <String>[];
    final result = await QuizGameApplicationService(
      catalogGateway: _Gateway(calls),
      englishReader: _English(calls,
          result: Result.failure(BusinessRuleError(message: 'database down'))),
      assetReader: _Assets(calls),
    ).load(const QuizGameQuery(_word));

    final error = (result as Failure<QuizGameLoadOutcome>).error;
    expect(error, isA<QuizGameLoadError>());
    expect((error as QuizGameLoadError).source,
        QuizGameLoadSource.englishConjugation);
    expect(calls, ['primary', 'conjugation', 'guide', 'be', 'english']);
  });

  test('returns no conjugation before asset or database reads', () async {
    final calls = <String>[];
    final result = await QuizGameApplicationService(
      catalogGateway: _Gateway(calls, conjugation: const Result.success(null)),
      englishReader: _English(calls),
      assetReader: _Assets(calls),
    ).load(const QuizGameQuery(_word));

    expect((result as Success<QuizGameLoadOutcome>).data,
        isA<QuizGameNoConjugation>());
    expect(calls, ['primary', 'conjugation']);
  });
}

final class _Gateway implements QuizGameCatalogGateway {
  _Gateway(this.calls,
      {Result<QuizCatalogPrimaryWord?>? primary,
      Result<QuizCatalogConjugation?>? conjugation})
      : primary = primary ?? const Result.success(_primary),
        conjugation = conjugation ?? Result.success(_conjugation);
  final List<String> calls;
  final Result<QuizCatalogPrimaryWord?> primary;
  final Result<QuizCatalogConjugation?> conjugation;
  @override
  Future<Result<QuizCatalogConjugation?>> readConjugation(
    CatalogWordRef word,
  ) async {
    calls.add('conjugation');
    return conjugation;
  }

  @override
  Future<Result<QuizCatalogPrimaryWord?>> readPrimaryWord(
      CatalogWordRef word) async {
    calls.add('primary');
    return primary;
  }
}

final class _English implements QuizGameEnglishReader {
  _English(this.calls, {Result<Map<String, String>>? result})
      : _result = result ??
            const Result.success(
                {'EnglishMoodTense.indicativePresent': 'speak'});
  final List<String> calls;
  final Result<Map<String, String>> _result;
  @override
  Future<Result<Map<String, String>>> readEnglishConjugation(int wordId) async {
    calls.add('english');
    return _result;
  }
}

final class _Assets implements QuizGameAssetReader {
  _Assets(this.calls);
  final List<String> calls;
  @override
  Future<Result<Map<String, Map<String, String>>>> readBeConjugation() async {
    calls.add('be');
    return const Result.success({
      'EnglishMoodTense.indicativePresent': {'EnglishSubject.I': 'am'}
    });
  }

  @override
  Future<Result<Map<String, String>>> readEnglishPromptGuide() async {
    calls.add('guide');
    return const Result.success({'MoodTense.indicativePresent': '@ #'});
  }
}

const _primary = QuizCatalogPrimaryWord(word: _word, headword: 'hablar');
final _conjugation = QuizCatalogConjugation(forms: const {
  QuizMoodTense.indicativePresent: {QuizSubject.yo: 'hablo'}
}, word: _word);
