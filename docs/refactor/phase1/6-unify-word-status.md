# Phase 1-6: 西和・和西のword status featureを統合する

- 状態: 未着手
- 優先度: 中〜高 / 重複・循環
- 依存タスク: [`../local_first/5-migrate-word-status.md`](../local_first/5-migrate-word-status.md)、[`2-enforce-import-boundaries.md`](2-enforce-import-boundaries.md)
- 関連タスク: [`../phase0/5-fix-status-update-contract.md`](../phase0/5-fix-status-update-contract.md)、[`../phase2/1-move-usecases-to-application.md`](../phase2/1-move-usecases-to-application.md)
- 元調査: [`FLUTTER_ARCHITECTURE_REVIEW.md`](../../FLUTTER_ARCHITECTURE_REVIEW.md) 7.2、10.3

## 目的

`esp_jpn_word_status`と`jpn_esp_word_status`に重複するentity、更新、同期、UI、DIを一つのfeatureへ統合し、辞書方向の違いだけを型で表現する。

## 現在の問題

- 2 featureが似たstatus entity、更新UseCase、Repository、同期処理を持つ
- Jpn-Esp DIがEsp-JpnのUI classをimportし、そのUIがJpn-Esp DIをimportする循環がある
- remote失敗、hasNote更新、同期登録などの修正が片側だけに入る
- 250〜330行規模の同期UseCaseが複製されている

## 前提

Phase 0-5で両方向のデータ整合性とcontract testを先に揃える。挙動が異なる状態で共通化すると、正しい差異とbugを区別できない。

## 目標モデル例

```text
features/word_status/
├── domain/
│   ├── word_status.dart
│   └── dictionary_direction.dart
├── application/
│   ├── update_word_status.dart
│   └── word_status_repository.dart
├── infrastructure/
│   ├── esp_jpn_status_adapter.dart
│   ├── jpn_esp_status_adapter.dart
│   └── sync/
│       ├── esp_jpn_status_sync_handler.dart
│       └── jpn_esp_status_sync_handler.dart
└── presentation/
```

`DictionaryDirection`またはdictionary IDで差異を表し、bool分岐を各layerへ散在させない。

## 実装方針

1. 両featureの型、field、Repository操作、同期ルール、UI差分を比較表にする。
2. 共通domain entityとcommandを定義する。
3. DB/Firebase table差異はinfrastructure adapterへ閉じ込める。
4. 共通application command/queryへcontract testを適用する。SyncEngine orchestrationは`features/sync`に維持する。
5. UIはdirectionを入力として受け、DI providerを相互importしない。
6. 移行期間は旧providerを新providerへ委譲し、呼出し側を段階的に更新する。
7. 参照が0になった旧featureを削除する。

## 必須テスト

- 両directionでload/update/watch/syncが同じcontractを満たす
- directionを跨いでstatusが混在しない
- hasNote、bookmark、learnedの部分更新が保持される
- remote failureとretryが両directionで同じ結果になる
- UI componentが相手方向のDIをimportしない
- feature統合後も2つのdataset ID、remote collection、cursorが混在しない

## 完了条件

- [ ] word statusのdomain/application実装が一系統
- [ ] direction差異が明示型またはadapterに限定される
- [ ] 2 feature間の循環importが0
- [ ] 両方向が同じcontract testを通る
- [ ] 旧provider・旧featureへの参照が0
- [ ] SyncEngine共通責務がword status featureへ重複実装されていない

## LLMへの引き継ぎ事項

共通化率を目的にしない。DB tableやremote collectionが本当に異なる部分はadapterとして残す。業務規則と同期保証の重複を除くことが目的である。
