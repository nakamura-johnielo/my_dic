import 'package:flutter/foundation.dart';
import 'dart:core' as core show print;
import 'dart:core';
import 'dart:convert';

class AppLogger {
  static final JsonEncoder _prettyEncoder = const JsonEncoder.withIndent('  ');
  static const String redacted = '[REDACTED]';

  static final RegExp _secretKeyPattern = RegExp(
    r'(token|password|authorization|credential|secret|cookie)',
  );
  static const Set<String> _personalIdentifierKeys = {
    'email',
    'emailaddress',
    'uid',
    'accountid',
    'userid',
    'deviceid',
  };

  static void print(dynamic message) {
    if (!kDebugMode) return;

    final String output = _format(message);
    // ignore: avoid_print
    core.print(output);
  }

  /// 構造化コンテキストを伴う名前付きイベントを出力します。
  ///
  /// 機密フィールドはキーに基づき再帰的にマスクされます。機密値自体を渡さないことを優先し、
  /// この境界は多層防御です。
  static void event(
    String name, {
    Map<String, Object?> context = const {},
  }) {
    if (!kDebugMode) return;

    // ignore: avoid_print
    core.print(formatEventForTesting(name, context: context));
  }

  @visibleForTesting
  static String formatEventForTesting(
    String name, {
    Map<String, Object?> context = const {},
  }) {
    final payload = <String, Object?>{'event': name};
    if (context.isNotEmpty) {
      payload['context'] = _redact(context);
    }
    return _prettyEncoder.convert(payload);
  }

  static Object? _redact(Object? value) {
    if (value is Map) {
      return value.map<String, Object?>((key, nestedValue) {
        final stringKey = key.toString();
        final normalizedKey =
            stringKey.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
        return MapEntry(
          stringKey,
          _isSensitiveKey(normalizedKey) ? redacted : _redact(nestedValue),
        );
      });
    }
    if (value is Iterable) {
      return value.map(_redact).toList(growable: false);
    }
    return value;
  }

  static bool _isSensitiveKey(String normalizedKey) {
    return _secretKeyPattern.hasMatch(normalizedKey) ||
        _personalIdentifierKeys.contains(normalizedKey);
  }

  static String _format(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return value;

    if (value is Map || value is List) {
      try {
        return _prettyEncoder.convert(value);
      } catch (_) {
        return value.toString();
      }
    }

    try {
      // JSONエンコードできる場合は見やすく出力する
      final encoded = jsonEncode(value);
      return _prettyEncoder.convert(jsonDecode(encoded));
    } catch (_) {
      return value.toString();
    }
  }
}
