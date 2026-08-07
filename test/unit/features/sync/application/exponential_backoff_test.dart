import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/sync/application/policy/exponential_backoff.dart';

class _FixedRandom implements Random {
  const _FixedRandom(this.value);

  final double value;

  @override
  bool nextBool() => value >= 0.5;

  @override
  double nextDouble() => value;

  @override
  int nextInt(int max) => (value * max).floor().clamp(0, max - 1);
}

void main() {
  test('uses the actual attempt number for exponential growth', () {
    final backoff = ExponentialBackoff(random: const _FixedRandom(0.5));

    expect(backoff.delayForAttempt(0), const Duration(seconds: 1));
    expect(backoff.delayForAttempt(1), const Duration(seconds: 2));
    expect(backoff.delayForAttempt(2), const Duration(seconds: 4));
  });

  test('jitter remains between half and one-and-a-half of capped delay', () {
    final low = ExponentialBackoff(random: const _FixedRandom(0));
    final high = ExponentialBackoff(random: const _FixedRandom(0.999999));

    expect(low.delayForAttempt(3), const Duration(seconds: 4));
    expect(
      high.delayForAttempt(3).inMilliseconds,
      inInclusiveRange(11999, 12000),
    );
  });

  test('caps the base delay before applying jitter', () {
    final backoff = ExponentialBackoff(
      base: const Duration(seconds: 1),
      maximum: const Duration(seconds: 5),
      random: const _FixedRandom(0.5),
    );

    expect(backoff.delayForAttempt(20), const Duration(seconds: 5));
  });
}
