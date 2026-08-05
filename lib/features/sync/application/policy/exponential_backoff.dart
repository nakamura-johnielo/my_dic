import 'dart:math';
import 'package:my_dic/features/sync/application/policy/retry_policy.dart';

/// リトライする時間間隔を指数関数的&ランダム揺れに増加させるポリシー
class ExponentialBackoff implements RetryPolicy {
  ExponentialBackoff(
      {this.base = const Duration(seconds: 1),
      this.maximum = const Duration(minutes: 5),
      Random? random})
      : _random = random ?? Random();
  final Duration base;
  final Duration maximum;
  final Random _random;
  @override
  Duration delayForAttempt(int attempt) {
    final capped = min(attempt.clamp(0, 20), 20);
    final millis =
        min(base.inMilliseconds * (1 << capped), maximum.inMilliseconds);
    return Duration(
        milliseconds: (millis * (0.5 + _random.nextDouble())).round());
  }
}
