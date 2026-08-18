import 'dart:convert';

import 'package:my_dic/core/shared/utils/json.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/quiz/internal/application/game/quiz_game_asset_reader.dart';
import 'package:my_dic/features/quiz/port/error/quiz_game_infrastructure_error.dart';
import 'package:my_dic/features/quiz/port/model/quiz_conjugation.dart';

/// Reads and maps the two bundled English prompt assets used by the game.
final class QuizGameAssets implements QuizGameAssetReader {
  QuizGameAssets({Future<Map<String, dynamic>> Function(String)? readJson})
      : _readJson = readJson ?? readJsonFile;

  QuizGameAssets.loadingText(Future<String> Function(String) loadText)
      : _readJson = ((path) async {
          final decoded = jsonDecode(await loadText(path));
          if (decoded is! Map<String, dynamic>) {
            throw const _AssetDataCorruption('asset must be a JSON object');
          }
          return decoded;
        });

  static const englishGuideAssetPath =
      'assets/data/es_conjugacion_en_translation.json';
  static const beConjugationAssetPath = 'assets/data/be_conjugacion.json';

  static const _guideKeys = <QuizMoodTense, String>{
    QuizMoodTense.participlePresent: 'MoodTense.participlePresent',
    QuizMoodTense.participlePast: 'MoodTense.participlePast',
    QuizMoodTense.indicativePresent: 'MoodTense.indicativePresent',
    QuizMoodTense.indicativePreterite: 'MoodTense.indicativePreterite',
    QuizMoodTense.indicativeImperfect: 'MoodTense.indicativeImperfect',
    QuizMoodTense.indicativeFuture: 'MoodTense.indicativeFuture',
    QuizMoodTense.indicativeConditional: 'MoodTense.indicativeConditional',
    QuizMoodTense.imperative: 'MoodTense.imperative',
    QuizMoodTense.subjunctivePresent: 'MoodTense.subjunctivePresent',
    QuizMoodTense.subjunctivePast: 'MoodTense.subjunctivePast',
  };
  static const _beTenseKeys = <QuizEnglishMoodTense, String>{
    QuizEnglishMoodTense.participlePresent:
        'EnglishMoodTense.participlePresent',
    QuizEnglishMoodTense.participlePast: 'EnglishMoodTense.participlePast',
    QuizEnglishMoodTense.indicativePresent:
        'EnglishMoodTense.indicativePresent',
    QuizEnglishMoodTense.indicativePast: 'EnglishMoodTense.indicativePast',
  };
  static const _subjectKeys = <QuizEnglishSubject, String>{
    QuizEnglishSubject.i: 'EnglishSubject.I',
    QuizEnglishSubject.you: 'EnglishSubject.you',
    QuizEnglishSubject.he: 'EnglishSubject.he',
    QuizEnglishSubject.we: 'EnglishSubject.we',
    QuizEnglishSubject.they: 'EnglishSubject.they',
  };

  final Future<Map<String, dynamic>> Function(String) _readJson;

  @override
  Future<Result<QuizEnglishPromptGuide>> readEnglishPromptGuide() =>
      _readAsset(englishGuideAssetPath, _parseEnglishGuide);

  @override
  Future<Result<QuizBeConjugation>> readBeConjugation() =>
      _readAsset(beConjugationAssetPath, _parseBeConjugation);

  Future<Result<T>> _readAsset<T>(
    String assetPath,
    T Function(Map<String, dynamic>) parse,
  ) async {
    try {
      return Result.success(parse(await _readJson(assetPath)));
    } on _AssetDataCorruption catch (error, stackTrace) {
      return Result.failure(QuizGameDataCorruptionError(
        assetPath: assetPath,
        reason: error.message,
        originalError: error,
        stackTrace: stackTrace,
      ));
    } on Object catch (error, stackTrace) {
      return Result.failure(QuizGameAssetError(
        assetPath: assetPath,
        originalError: error,
        stackTrace: stackTrace,
      ));
    }
  }

  QuizEnglishPromptGuide _parseEnglishGuide(Map<String, dynamic> raw) {
    _requireExactKeys(raw, _guideKeys.values.toSet());
    return QuizEnglishPromptGuide({
      for (final entry in _guideKeys.entries)
        entry.key: _stringValue(raw[entry.value], entry.value),
    });
  }

  QuizBeConjugation _parseBeConjugation(Map<String, dynamic> raw) {
    _requireExactKeys(raw, _beTenseKeys.values.toSet());
    return QuizBeConjugation({
      for (final tense in _beTenseKeys.entries)
        tense.key: _parseBeForms(raw[tense.value], tense.value),
    });
  }

  Map<QuizEnglishSubject, String> _parseBeForms(
    Object? value,
    String tenseKey,
  ) {
    if (value is! Map<String, dynamic>) {
      throw _AssetDataCorruption('$tenseKey must be a JSON object');
    }
    _requireExactKeys(value, _subjectKeys.values.toSet());
    return {
      for (final subject in _subjectKeys.entries)
        subject.key:
            _stringValue(value[subject.value], '$tenseKey.${subject.value}'),
    };
  }

  void _requireExactKeys(Map<String, dynamic> raw, Set<String> expected) {
    final unknown = raw.keys.where((key) => !expected.contains(key));
    if (unknown.isNotEmpty) {
      throw _AssetDataCorruption('unknown key ${unknown.first}');
    }
    final missing = expected.where((key) => !raw.containsKey(key));
    if (missing.isNotEmpty) {
      throw _AssetDataCorruption('missing key ${missing.first}');
    }
  }

  String _stringValue(Object? value, String key) {
    if (value is! String) {
      throw _AssetDataCorruption('$key must be a string');
    }
    return value;
  }
}

final class _AssetDataCorruption implements Exception {
  const _AssetDataCorruption(this.message);
  final String message;
}
