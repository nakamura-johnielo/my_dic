# Phase 0-5: Word statusの部分更新契約を固定する

- 状態: 完了
- 優先度: P1 / データ整合性
- 依存タスク: [`3-scope-sync-checkpoints.md`](3-scope-sync-checkpoints.md)、[`4-fix-result-propagation.md`](4-fix-result-propagation.md)
- 関連タスク: [`../local_first/5-migrate-word-status.md`](../local_first/5-migrate-word-status.md)、[`../phase1/6-unify-word-status.md`](../phase1/6-unify-word-status.md)
- 元調査: [`FLUTTER_ARCHITECTURE_REVIEW.md`](../../FLUTTER_ARCHITECTURE_REVIEW.md) P1-3

## 目的

isLearned、isBookmarked、hasNoteの部分更新で未指定値を壊さず、西和・和西の両方向が同じstatus更新contractを持つようにする。SyncQueue、remote retry、production handler登録はLocal-first 5で実施する。

## 現在の問題

Esp-JpnとJpn-Espの更新UseCaseは、ローカルでは未指定値をnullとして扱う一方、remote entity作成時にfalseへ初期化する。既存値の復元も一部fieldだけなので、hasNoteなどをfalseへ上書きし得る。

主な対象:

- `lib/features/esp_jpn_word_status/domain/usecase/update_status/update_status_interactor.dart`
- `lib/features/jpn_esp_word_status/domain/usecase/update_jpn_esp_status/update_jpn_esp_status_interactor.dart`
- 両directionのRepository inputとlocal DAO

remote失敗をsuccessとして隠す経路とJpn-Esp同期未登録も存在するが、remote配送経路を部分修正せず、Local-firstトラックで新SyncEngineへ置換する。

## 対象範囲

- status commandとRepository inputの意味統一
- local rowの部分更新
- boolとDBの`0 / 1 / null`の変換境界
- Esp-Jpn/Jpn-Esp共通contract test
- 現行failure伝播のcharacterization test

## 対象外

- dirty/outbox、retry、checkpoint再設計
- 新SyncEngineやdataset handlerのproduction登録
- Firebase remote patch実装の延命
- 2つのstatus featureの統合

これらは[`../local_first/5-migrate-word-status.md`](../local_first/5-migrate-word-status.md)とPhase 1-6で扱う。

## 実装方針

1. commandを「変更しない」と「falseへ変更する」を区別できる業務型で表現する。
2. DBの`0 / 1 / null`はinfrastructure境界だけで変換する。
3. 現在の完全なlocal statusへcommandを適用し、未指定fieldを保持する。
4. Repository/DAO failureを成功やNotFoundとして扱わない。
5. Esp-Jpn/Jpn-Espへ同じlocal command contract testを適用する。
6. remote送信結果は現状挙動をcharacterization testで記録し、新同期への切替前提を明記する。

## 必須テスト

- bookmarkだけ変更してhasNoteとlearnedが保持される
- learnedだけ変更して他fieldが保持される
- hasNoteだけ変更して他fieldが保持される
- false指定と未指定が区別される
- local Database failureをsuccessとして返さない
- Esp-JpnとJpn-Espが同じlocal update contractを通る

## 完了条件

- [x] 未指定fieldをfalseまたはnullへ上書きしない
- [x] domain/application契約にDBの0/1表現がない
- [x] local failureが呼出し元まで伝播する
- [x] 両辞書方向が同じlocal contract testを通る
- [x] remote retryとoutboxがLocal-first 5へ明示的に移管されている

## LLMへの引き継ぎ事項

このタスクでは旧remote同期を拡張しない。statusの値保持とfailure契約だけを固定し、productionの非同期配送はLocal-first 5でDrift outboxへ切り替える。
