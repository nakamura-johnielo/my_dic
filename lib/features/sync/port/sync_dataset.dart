/// This is the db table name.
/// Stable identifiers used in persistence and remote protocol. Never rely on
/// enum indexes: adding a dataset must not reinterpret existing rows.
enum SyncDataset {
  espJpnWordStatus('esp_jpn_word_status'),
  jpnEspWordStatus('jpn_esp_word_status'),
  myWords('my_words'),
  myWordStatus('my_word_status'),
  userProfile('user_profile');

  const SyncDataset(this.stableId);
  final String stableId;

  static SyncDataset fromStableId(String value) =>
      SyncDataset.values.firstWhere(
        (dataset) => dataset.stableId == value,
        orElse: () =>
            throw ArgumentError.value(value, 'value', 'unknown dataset'),
      );
}
