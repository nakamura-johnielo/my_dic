import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/mapper/my_word_infrastructure_error_mapper.dart';

void main() {
  group('MyWordInfrastructureErrorMapper', () {
    test('wraps raw database failures without exposing their type', () {
      final raw = StateError('sqlite is unavailable');
      final error = MyWordInfrastructureErrorMapper.database(
        raw,
        StackTrace.current,
        message: 'Failed to load my words.',
      );

      expect(error, isA<DatabaseError>());
      expect(error.message, 'Failed to load my words.');
      expect(error.originalError, same(raw));
    });

    test('wraps raw Firebase failures without exposing their type', () {
      final raw = StateError('Firestore is unavailable');
      final error = MyWordInfrastructureErrorMapper.firebase(
        raw,
        StackTrace.current,
        message: 'Failed to load my words from Firebase.',
      );

      expect(error, isA<FirebaseError>());
      expect(error.message, 'Failed to load my words from Firebase.');
      expect(error.originalError, same(raw));
    });

    test('preserves an existing typed error', () {
      final existing = DatabaseError(message: 'Already mapped.');

      final mapped = MyWordInfrastructureErrorMapper.database(
        existing,
        StackTrace.current,
        message: 'Ignored.',
      );

      expect(mapped, same(existing));
    });
  });
}
