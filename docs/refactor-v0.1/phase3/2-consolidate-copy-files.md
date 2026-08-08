# Phase 3-2: copy.dartを正規実装へ統合する

- 状態: 未着手
- 優先度: 中 / 重複
- 依存タスク: [`../local_first/8-cut-over-and-remove-legacy-sync.md`](../local_first/8-cut-over-and-remove-legacy-sync.md)、[`1-remove-unused-abstractions.md`](1-remove-unused-abstractions.md)と並行可能
- 元調査: [`FLUTTER_ARCHITECTURE_REVIEW.md`](../../FLUTTER_ARCHITECTURE_REVIEW.md) 10.1、10.3

## 目的

`copy.dart`やURL encoded importで参照される複製実装を解消し、各責務に正規ファイルを一つだけ持たせる。

## 現在の問題

追跡対象に次の複製ファイルがある。

- `sync_my_word_interactor copy.dart`
- `search_fragment copy.dart`
- `card_view copy.dart`

特にMyWord同期は`lib/features/my_word/di/usecase_di.dart`から`%20copy.dart`としてimportされ、copy側が実働実装になっている。Local-first 6・8で新handlerへ置換するため、この旧同期copyは正規実装へ統合せず、production参照を外して削除する。

## 対象範囲

- 名前に`copy`、`old`、`backup`、連番を含むDartファイル
- 元ファイルとの差分
- DI/import/export/test参照
- 正規実装の選定と削除

## 実装方針

1. 各copyと元候補のdiffを取り、片側だけのbug fixを一覧化する。
2. 実際にDIから利用される実装を特定する。
3. 旧MyWord同期copyはLocal-first 8でproduction参照が0であることを確認し、新SyncEngineへ統合せず削除する。
4. Search/UIなど残るcopyはcharacterization testを両候補へ適用する。
5. 残る必要な挙動を正規名ファイルへ統合する。
6. importを正規名へ更新し、参照が0になったcopyを削除する。
7. editorや生成処理がcopyを再作成しないことを確認する。

## 必須テスト

- Local-first MyWord handlerの成功、failure、conflict、server cursor test
- Search画面とcard表示のwidget/golden testがある場合は実行
- `rg -n "copy\.dart|%20copy" lib test`が0
- analyzeでduplicate/unused importがない

## 完了条件

- [ ] 実働コードが正規名ファイルからimportされる
- [ ] trackedされた`copy.dart`が0
- [ ] copyだけに存在した必要な修正が失われていない
- [ ] 同期とUIのtestが通る

## LLMへの引き継ぎ事項

名前だけを見てcopy側を削除しない。現在はcopy側がDIから使われる例があるため、Local-first 8で新handlerへの切替と参照0を確認してから削除する。旧同期copyを正規名へrenameして延命しない。
