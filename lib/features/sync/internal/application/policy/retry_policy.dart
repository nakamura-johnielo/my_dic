abstract interface class RetryPolicy {
  Duration delayForAttempt(int attempt);
}
