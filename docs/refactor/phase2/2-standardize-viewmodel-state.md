# Phase 2-2: ViewModel stateを統一する

- 状態: 完了（2026-08-07）
- 優先度: 中 / UI整合性
- 依存タスク: Phase 0のResult伝播修正、Phase 2-1
- 関連タスク: [`3-remove-build-time-io.md`](3-remove-build-time-io.md)
- 元調査: [`FLUTTER_ARCHITECTURE_REVIEW.md`](../../FLUTTER_ARCHITECTURE_REVIEW.md) 5、9.1、9.2

## 目的

各画面がloading、data、empty、failure、必要な一時effectを明確に区別し、失敗を空データや成功表示へ変換しないようにする。

## 現在の問題

- featureごとにStateNotifier、nullable data、複数bool、独自status enumの組合せが異なる
- Searchは補助データ取得失敗を空mapへ変換し、情報なしと障害を区別できない
- Repository failureを握りつぶすUseCaseによりUIが成功を表示する
- navigation、Snackbar、callbackがdomain/applicationへ漏れる

## 推奨状態モデル

単純な画面は次のsealed stateまたは同等の`AsyncValue`で表す。

```text
Initial
Loading(previousData?)
Data(value, warnings?)
Empty
Failure(error, previousData?)
```

保存commandはquery stateと分け、`idle / submitting / succeeded / failed`を持たせる。Snackbarやnavigationは再描画stateではなく、一回性effectとして扱う。

## 実装方針

1. featureごとの現在stateとUI分岐を一覧化する。
2. 全画面へ巨大な共通classを強制せず、共通の状態語彙と意味を統一する。
3. `null`が未load、empty、failureのどれを意味するかをなくす。
4. best-effort補助データはwarningを保持し、主要データ成功と完全成功を区別する。
5. error codeからユーザー文言への変換をpresentationへ置く。
6. command完了後のnavigation/Snackbarはone-shot effectとして発行する。
7. previous dataを維持するrefreshと初回loadを区別する。

## 必須テスト

- initial load成功、empty、failure
- refresh failure時にprevious dataを保持する仕様
- 補助データfailureがwarningとして残る
- 保存failure時にsuccess effectを発行しない
- 同じeffectをrebuildで二重処理しない

## 完了内容（2026-08-07）

- 共通presentation語彙として`QueryState`、`CommandState`、one-shot effect、`AppError`から表示文言へのmapperを導入した。
- Search/Quiz Searchはquery stateへ移行し、補助データ取得失敗をwarningとして保持する。Ranking/MyWord listもlist/query stateでloading、data、empty、failureとprevious dataを表現する。
- WordPage、Quiz Game、word status/MyWord statusのread stateはloading/errorを明示し、失敗を`null`、dummy data、または`false` statusへ変換しない。
- MyWord、word status、Auth、Profileの更新操作はcommand stateとone-shot effectを使用し、validation/repository failureで成功effectを発行しない。
- 主要ViewModelのstate transition、warning、command/effectを検証した。2026-08-07に`flutter analyze`は問題なし、`flutter test`は275件すべて成功した。

## 完了条件

- [x] loading、data、empty、failureを区別できる
- [x] `null`や空listがfailureの代用になっていない
- [x] command failureで成功UIを表示しない
- [x] error message変換がpresentationにある
- [x] state transition testが主要ViewModelにある

## 後続フェーズへ残す範囲

- Phase 2-3の`build()`中I/O除去、初回loadのUI外への移設、provider責務整理はこのフェーズに含めない。
- Phase 2-4のCoordinator/`Ref`/`AppNavigatorService`の除去、Phase 2-5のquery projection・domain entity所有権の変更、Phase 2-6の`SyncReport` UIは未実施である。
- word-statusのdomain/repository/data契約統合、Local-first 8の旧sync API削除、Riverpod Notifier APIへの全面移行、Freezed導入、rename/copy整理、DB schema・同期protocol・route contract・検索ページサイズ等の変更は後続作業である。

## LLMへの引き継ぎ事項

共通base classの導入自体を目的にしない。画面固有stateは残してよいが、同じ語が同じ意味を持ち、失敗が失われないことを優先する。
