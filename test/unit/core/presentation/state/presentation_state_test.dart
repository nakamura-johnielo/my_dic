import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/core/presentation/state/command_state.dart';
import 'package:my_dic/core/presentation/state/query_state.dart';
import 'package:my_dic/core/presentation/state/ui_effect.dart';
import 'package:my_dic/core/shared/errors/unexpected_error.dart';

void main() {
  const error = UnexpectedError(message: 'diagnostic');

  group('QueryState', () {
    test('distinguishes initial loading from refresh loading', () {
      const initial = QueryState<String>.initial();
      const firstLoad = QueryState<String>.loading();
      const refresh = QueryState<String>.loading(previousData: 'cached');

      expect(initial.isInitial, isTrue);
      expect(firstLoad.isInitialLoading, isTrue);
      expect(firstLoad.hasData, isFalse);
      expect(refresh.isRefreshing, isTrue);
      expect(refresh.dataOrNull, 'cached');
    });

    test('retains previous data after a refresh failure', () {
      const state = QueryState<String>.failure(error, previousData: 'cached');

      expect(state.isFailure, isTrue);
      expect(state.hasPreviousData, isTrue);
      expect(state.dataOrNull, 'cached');
    });

    test('retains warnings for data and empty results', () {
      const warning = QueryWarning(source: 'ranking', error: error);
      final data = QueryState<String>.data('value', warnings: [warning]);
      final empty = QueryState<String>.empty(warnings: [warning]);

      expect(data.hasWarnings, isTrue);
      expect(empty.warnings.single.source, 'ranking');
      expect(() => data.warnings.add(warning), throwsUnsupportedError);
    });
  });

  group('CommandState', () {
    test('exposes every command phase and preserves typed failures', () {
      const idle = CommandState.idle();
      const submitting = CommandState.submitting('save');
      const succeeded = CommandState.succeeded('save');
      const failed = CommandState.failed('save', error);

      expect(idle.isIdle, isTrue);
      expect(submitting.isSubmitting, isTrue);
      expect(succeeded.isSucceeded, isTrue);
      expect(failed.isFailed, isTrue);
      expect(failed.errorOrNull, same(error));
    });
  });

  group('UiEffect envelope', () {
    test('guards consumption by the matching effect ID', () {
      const pending = UiEffectEnvelope<UiEffect>(
        id: 'effect-2',
        effect: UiReloadEffect(),
      );

      expect(
          shouldConsumeEffect(pendingEffect: pending, id: 'effect-1'), isFalse);
      expect(
          shouldConsumeEffect(pendingEffect: pending, id: 'effect-2'), isTrue);
    });
  });
}
