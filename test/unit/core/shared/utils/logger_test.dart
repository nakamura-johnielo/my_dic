import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/utils/logger.dart';

void main() {
  group('AppLogger.event', () {
    test('redacts secret and personal identifier fields recursively', () {
      final output = AppLogger.formatEventForTesting(
        'auth.test',
        context: {
          'refreshToken': 'refresh-secret',
          'headers': {
            'Authorization': 'Bearer access-secret',
            'contentType': 'application/json',
          },
          'attempts': [
            {'password': 'password-secret'},
            {'emailAddress': 'person@example.com'},
            {'account_id': 'account-secret'},
          ],
        },
      );

      expect(output, isNot(contains('refresh-secret')));
      expect(output, isNot(contains('access-secret')));
      expect(output, isNot(contains('password-secret')));
      expect(output, isNot(contains('person@example.com')));
      expect(output, isNot(contains('account-secret')));

      final payload = jsonDecode(output) as Map<String, dynamic>;
      final context = payload['context'] as Map<String, dynamic>;
      expect(context['refreshToken'], AppLogger.redacted);
      expect(
        (context['headers'] as Map<String, dynamic>)['Authorization'],
        AppLogger.redacted,
      );
      expect(
        (context['headers'] as Map<String, dynamic>)['contentType'],
        'application/json',
      );
    });

    test('keeps safe diagnostic context', () {
      final output = AppLogger.formatEventForTesting(
        'auth.sign_in.failed',
        context: {'errorCode': 'network-request-failed', 'retryable': true},
      );

      expect(output, contains('network-request-failed'));
      expect(output, contains('retryable'));
    });
  });
}
