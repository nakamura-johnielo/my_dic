import 'package:flutter/foundation.dart';
import 'dart:core' as core show print;
import 'dart:core';
import 'dart:convert';

class AppLogger {
  static final JsonEncoder _prettyEncoder = const JsonEncoder.withIndent('  ');

  static void print(dynamic message) {
    if (!kDebugMode) return;

    final String output = _format(message);
    // ignore: avoid_print
    core.print(output);
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
      // If it can be JSON-encoded, print it nicely
      final encoded = jsonEncode(value);
      return _prettyEncoder.convert(jsonDecode(encoded));
    } catch (_) {
      return value.toString();
    }
  }
}
