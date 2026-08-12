import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/quiz/internal/infrastructure/assets/quiz_game_assets.dart';
import 'package:my_dic/features/quiz/port/error/quiz_game_infrastructure_error.dart';

void main() {
  test('reads the established asset paths and preserves their wire keys',
      () async {
    final requested = <String>[];
    final assets = QuizGameAssets(readJson: (path) async {
      requested.add(path);
      return path == QuizGameAssets.englishGuideAssetPath ? _guide : _be;
    });

    final guide = await assets.readEnglishPromptGuide();
    final be = await assets.readBeConjugation();

    expect(requested, [
      'assets/data/es_conjugacion_en_translation.json',
      'assets/data/be_conjugacion.json',
    ]);
    expect(guide.dataOrNull?['MoodTense.indicativePresent'], '@ #');
    expect(
        be.dataOrNull?['EnglishMoodTense.indicativePresent']
            ?['EnglishSubject.I'],
        'am');
  });

  test('maps an asset read exception to a Quiz-owned asset error', () async {
    final assets = QuizGameAssets(readJson: (_) => throw StateError('missing'));

    final result = await assets.readEnglishPromptGuide();

    expect(result.errorOrNull, isA<QuizGameAssetError>());
  });

  test('maps invalid asset shape and wire keys to typed corruption', () async {
    final assets = QuizGameAssets(
        readJson: (_) async => {
              ..._be,
              'EnglishMoodTense.unknown': <String, dynamic>{},
            });

    final result = await assets.readBeConjugation();

    expect(result.errorOrNull, isA<QuizGameDataCorruptionError>());
  });

  test('maps non-string values to typed corruption', () async {
    final assets = QuizGameAssets(
        readJson: (_) async => {
              ..._guide,
              'MoodTense.imperative': 1,
            });

    final result = await assets.readEnglishPromptGuide();

    expect(result.errorOrNull, isA<QuizGameDataCorruptionError>());
  });
}

final _guide = <String, dynamic>{
  'MoodTense.participlePresent': '# :V-ing',
  'MoodTense.participlePast': '# :V-ed',
  'MoodTense.indicativePresent': '@ #',
  'MoodTense.indicativePreterite': '@ # yesterday',
  'MoodTense.indicativeImperfect': '@ used to #',
  'MoodTense.indicativeFuture': '@ will #',
  'MoodTense.indicativeConditional': '@ would #',
  'MoodTense.imperative': '#!',
  'MoodTense.subjunctivePresent': 'that @ #',
  'MoodTense.subjunctivePast': 'if @ #',
};

final _be = <String, dynamic>{
  for (final tense in const [
    'EnglishMoodTense.participlePresent',
    'EnglishMoodTense.participlePast',
    'EnglishMoodTense.indicativePresent',
    'EnglishMoodTense.indicativePast',
  ])
    tense: <String, dynamic>{
      'EnglishSubject.I': 'am',
      'EnglishSubject.you': 'are',
      'EnglishSubject.he': 'is',
      'EnglishSubject.we': 'are',
      'EnglishSubject.they': 'are',
    },
};
