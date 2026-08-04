# Phase 0-5: Word statusの部分更新と再送を修正する

- 状態: 未着手
- 優先度: P1 / データ整合性
- 依存タスク: [`3-scope-sync-checkpoints.md`](3-scope-sync-checkpoints.md)、[`4-fix-result-propagation.md`](4-fix-result-propagation.md)
- 関連タスク: [`../phase1/6-unify-word-status.md`](../phase1/6-unify-word-status.md)
- 元調査: [`FLUTTER_ARCHITECTURE_REVIEW.md`](../../FLUTTER_ARCHITECTURE_REVIEW.md) P1-3

## 目的

isLearned、isBookmarked、hasNoteの部分更新で未指定値を壊さず、remote失敗後も再送でき、西和・和西の両方向が同じ同期保証を持つようにする。

## 現在の問題

Esp-JpnとJpn-Espの更新UseCaseは、ローカルでは未指定値をnullとして扱う一方、remote entity作成時にfalseへ初期化する。既存値の復元も一部fieldだけなので、hasNoteなどをfalseへ上書きし得る。

主な対象:

- `lib/features/esp_jpn_word_status/domain/usecase/update_status/update_status_interactor.dart`
- `lib/features/jpn_esp_word_status/domain/usecase/update_jpn_esp_status/update_jpn_esp_status_interactor.dart`
- `lib/features/sync/di.dart`

remote失敗をsuccessとして返す経路があり、Jpn-Esp同期UseCaseは中央`SyncService`へ登録されていない。

## 対象範囲

- status commandとRepository input
- local/remoteのpatchまたはfull entity更新
- dirty/outboxとretry
- Esp-Jpn/Jpn-Espの同期登録
- conflict resolutionとtest

## 実装方針

1. commandを業務型で表現する。DBの`0 / 1 / null`はdata層だけで変換する。
2. 更新方式を次のどちらかへ統一する。
   - 現在の完全なstatusを読み、変更適用後のfull entityをremoteへ保存する
   - remote adapterも未指定を保持できる明示的なpatch DTOを使う
3. local commit後にremote失敗した場合、dirty/outbox recordを永続化する。
4. retry成功時だけdirtyを消す。
5. Jpn-Esp同期を`syncServiceProvider`へ登録する。
6. conflict resolutionの基準を更新時刻、field単位、端末優先などから明示的に選ぶ。
7. Phase 1-6のfeature統合前に両実装へ同じcontract testを適用する。

## 必須テスト

- bookmarkだけ変更してhasNoteとlearnedが保持される
- learnedだけ変更して他fieldが保持される
- remote failure後にdirty/outboxが残る
- retry成功後にdirtyが消える
- Esp-JpnとJpn-EspがどちらもSyncServiceから呼ばれる
- local/remote同時更新時に規定のconflict resolutionとなる
- accountを跨いでdirty recordを送信しない

## 完了条件

- [ ] 未指定fieldをfalseへ上書きしない
- [ ] domain/application契約にDBの0/1表現がない
- [ ] remote失敗をsuccessとして隠さない
- [ ] 永続的な再送経路がある
- [ ] 両辞書方向が同じ同期contract testを通る
- [ ] Jpn-Esp同期が中央サービスへ登録されている

## LLMへの引き継ぎ事項

Phase 1-6でfeatureを統合する前に、まずデータ整合性を直してtestを共通化する。統合と挙動変更を同じPRにすると、どちらが回帰原因か判別しにくい。
