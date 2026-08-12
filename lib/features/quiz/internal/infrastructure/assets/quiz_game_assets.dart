import 'package:my_dic/core/shared/utils/json.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/quiz/internal/application/game/quiz_game_asset_reader.dart';
import 'package:my_dic/features/quiz/port/error/quiz_game_infrastructure_error.dart';

/// Reads the two bundled English prompt assets used by the legacy game.
///
/// Wire keys remain here: callers only receive the raw maps expected by the
/// application-layer mapper.
final class QuizGameAssets implements QuizGameAssetReader {
  QuizGameAssets({Future<Map<String, dynamic>> Function(String)? readJson})
      : _readJson = readJson ?? readJsonFile;

  static const englishGuideAssetPath =
      'assets/data/es_conjugacion_en_translation.json';
  static const beConjugationAssetPath = 'assets/data/be_conjugacion.json';

  final Future<Map<String, dynamic>> Function(String) _readJson;

  /// Legacy entry point retained until the compatibility graph is removed.
  Future<Map<String, String>> loadEnglishGuide() async {
    final result = await readEnglishPromptGuide();
    return result.dataOrNull ?? (throw result.errorOrNull!);
  }

  /// Legacy entry point retained until the compatibility graph is removed.
  Future<Map<String, Map<String, String>>> loadBeConjugation() async {
    final result = await readBeConjugation();
    return result.dataOrNull ?? (throw result.errorOrNull!);
  }

  @override
  Future<Result<Map<String, String>>> readEnglishPromptGuide() =>
      _readAsset(englishGuideAssetPath, _parseEnglishGuide);

  @override
  Future<Result<Map<String, Map<String, String>>>> readBeConjugation() =>
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

  Map<String, String> _parseEnglishGuide(Map<String, dynamic> raw) {
    const keys = {
      'MoodTense.participlePresent',
      'MoodTense.participlePast',
      'MoodTense.indicativePresent',
      'MoodTense.indicativePreterite',
      'MoodTense.indicativeImperfect',
      'MoodTense.indicativeFuture',
      'MoodTense.indicativeConditional',
      'MoodTense.imperative',
      'MoodTense.subjunctivePresent',
      'MoodTense.subjunctivePast',
    };
    _requireExactKeys(raw, keys);
    return {
      for (final entry in raw.entries)
        entry.key: _stringValue(entry.value, entry.key),
    };
  }

  Map<String, Map<String, String>> _parseBeConjugation(
      Map<String, dynamic> raw) {
    const tenseKeys = {
      'EnglishMoodTense.participlePresent',
      'EnglishMoodTense.participlePast',
      'EnglishMoodTense.indicativePresent',
      'EnglishMoodTense.indicativePast',
    };
    const subjectKeys = {
      'EnglishSubject.I',
      'EnglishSubject.you',
      'EnglishSubject.he',
      'EnglishSubject.we',
      'EnglishSubject.they',
    };
    _requireExactKeys(raw, tenseKeys);
    return {
      for (final entry in raw.entries)
        entry.key: _parseBeForms(entry.value, entry.key, subjectKeys),
    };
  }

  Map<String, String> _parseBeForms(
    Object? value,
    String tenseKey,
    Set<String> subjectKeys,
  ) {
    if (value is! Map<String, dynamic>) {
      throw _AssetDataCorruption('$tenseKey must be a JSON object');
    }
    _requireExactKeys(value, subjectKeys);
    return {
      for (final entry in value.entries)
        entry.key: _stringValue(entry.value, '$tenseKey.${entry.key}'),
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
