import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'application logs do not reference authentication secrets or identifiers',
      () {
    final libDirectory = Directory('lib');
    expect(libDirectory.existsSync(), isTrue, reason: 'Run from package root.');

    final loggingCallStart = RegExp(
      r'\b(?:AppLogger\.(?:print|event)|debugPrint|developer\.log|(?:_?logger)\.(?:finest|finer|fine|info|warning|severe|shout))\s*\(',
    );
    final forbiddenInLog = RegExp(
      r'refresh.?token|access.?token|id.?token|password|authorization|credential|provider.?data|account.?id|user.?id|device.?id|\buid\b|\.email\b|doc\.data',
      caseSensitive: false,
    );
    final violations = <String>[];

    for (final file in libDirectory
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))) {
      final lines = file.readAsLinesSync();
      for (var index = 0; index < lines.length; index++) {
        if (!loggingCallStart.hasMatch(lines[index])) continue;

        final call = StringBuffer(lines[index]);
        var endIndex = index;
        while (!lines[endIndex].contains(';') &&
            endIndex + 1 < lines.length &&
            endIndex - index < 20) {
          endIndex++;
          call.write('\n${lines[endIndex]}');
        }

        if (forbiddenInLog.hasMatch(call.toString())) {
          violations.add('${file.path}:${index + 1}\n$call');
        }
        index = endIndex;
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Sensitive values must never be passed to logging APIs:\n'
          '${violations.join('\n\n')}',
    );
  });

  test('Firebase refresh tokens are never read by application code', () {
    final refreshTokenAccess = RegExp(r'\.refreshToken\b');
    final violations = <String>[];

    for (final file in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))) {
      final lines = file.readAsLinesSync();
      for (var index = 0; index < lines.length; index++) {
        if (refreshTokenAccess.hasMatch(lines[index])) {
          violations.add('${file.path}:${index + 1}:${lines[index].trim()}');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'The application has no need to read Firebase refresh tokens.',
    );
  });
}
