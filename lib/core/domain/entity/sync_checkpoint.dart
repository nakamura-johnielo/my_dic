enum SyncDataset {
  myWords('my_words'),
  myWordStatus('my_word_status'),
  espJpnWordStatus('esp_jpn_word_status');

  const SyncDataset(this.stableId);

  final String stableId;
}

class SyncCheckpointKey {
  SyncCheckpointKey({
    required String accountId,
    required this.dataset,
  }) : accountId = _validateAccountId(accountId);

  final String accountId;
  final SyncDataset dataset;

  static String _validateAccountId(String value) {
    if (value.isEmpty) {
      throw ArgumentError.value(value, 'accountId', 'must not be empty');
    }
    return value;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncCheckpointKey &&
          accountId == other.accountId &&
          dataset == other.dataset;

  @override
  int get hashCode => Object.hash(accountId, dataset);
}

class SyncCheckpoint {
  SyncCheckpoint({
    required this.key,
    required DateTime lastSuccessfulAt,
    this.remoteCursor,
  }) : lastSuccessfulAt = lastSuccessfulAt.toUtc();

  final SyncCheckpointKey key;
  final DateTime lastSuccessfulAt;
  final String? remoteCursor;
}
