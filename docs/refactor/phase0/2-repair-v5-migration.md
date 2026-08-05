# Phase 0-2: DB v5 migrationのデータ消失を修正する

- 状態: 完了
- 優先度: P0 / データ保全
- 依存タスク: なし
- 次の推奨タスク: [`3-scope-sync-checkpoints.md`](3-scope-sync-checkpoints.md)
- 元調査: [`FLUTTER_ARCHITECTURE_REVIEW.md`](../../FLUTTER_ARCHITECTURE_REVIEW.md) P0-2

## 目的

旧schemaからv5以降へupgradeした際、MyWordとMyWord statusの関連を失わず、全データを現行schemaへ移行する。

## 現在の問題

`lib/core/infrastructure/database/drift/database_provider.dart`のv5 migrationでは`idMap`が空のままである。

- 旧MyWordを新tableへ挿入するが、旧IDと新IDの対応を`idMap`へ保存していない
- status移行時に`idMap[oldId]`が常に`null`となり、status行をskipする
- その後、旧status tableをdropするため、statusが全件失われる
- より前のupgrade分岐には`return`があり、開始versionによって後続migrationへ到達しない可能性がある

## 対象範囲

- `lib/core/infrastructure/database/drift/database_provider.dart`
- schema version 1〜現行versionのupgrade経路
- MyWord、MyWord statusと関連index/constraint
- 旧DB fixtureを使ったmigration test

## 対象外

- DB schemaの大規模な再設計
- DAOやRepositoryの配置変更
- 本番DBを直接操作する手順。必要なら別途runbookを作る

## 実装方針

1. 各旧schema versionのtable定義と主キー・外部キーを確定する。
2. migration開始前に旧tableをfixtureとして再現する。
3. MyWord移行時に旧IDと新IDを必ず対応付ける。可能なら旧IDを維持し、無理ならinsert結果から新IDを得る。
4. status移行件数と対応不能件数を検証してから旧tableをdropする。
5. `return`で後続versionの処理をskipしない、段階的な`if (from < n)`形式へ整理する。
6. migrationをtransaction内で実行し、途中失敗時に旧データが残ることを確認する。
7. duplicate、孤立status、null値が存在する場合の方針を明示する。

## 必須テスト

- v4 fixtureに複数MyWordとstatusを作り、現行versionへupgradeする
- upgrade後のMyWord件数、status件数、各statusの参照先と値を比較する
- statusなしMyWord、複数status、削除済み参照など境界ケースを含める
- v1、v2、v3、v4それぞれから現行versionへupgradeする
- migration途中の例外でtransactionがrollbackされることを確認する

## 完了条件

- [x] v5 migrationで旧IDと新IDの対応が保持される
- [x] statusがskipされたまま旧tableをdropする経路がない
- [x] すべての旧schema versionから現行versionへのtestが通る
- [x] 件数だけでなく関連と値もtestで比較している
- [x] migration失敗時に破損した中間状態をcommitしない

## LLMへの引き継ぎ事項

実装前に必ず現行Drift APIと生成table名を確認する。推測だけでSQLを書かず、旧schema fixtureを先に作る。migration修正と通常CRUDのリファクタを同じ変更に混ぜない。
