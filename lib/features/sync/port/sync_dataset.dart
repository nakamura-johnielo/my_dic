/// これは DB テーブル名です。
/// 永続化とリモートプロトコルで使用する安定した識別子です。データセット追加によって既存行を
/// 異なる意味に解釈してはならないため、列挙値のインデックスには決して依存しません。
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
