# Phase 2-2: ViewModel state 標準化 実装プラン

状態: 未着手
作成日: 2026-08-07

## 目的

- 各画面で `initial`、初回 `loading`、`data`、`empty`、`failure`、previous data を保持した refresh/pagination failure を区別する。
- Repository/Application の `Failure` を空 list、空 map、`null`、既定値、成功メッセージへ変換せず、presentation まで型付きで運ぶ。
- query の持続状態と保存・更新 command の状態を分け、Snackbar、dialog close、navigation、再読込要求を one-shot effect として扱う。
- 画面固有の filter、query、quiz progress、status 値は維持しつつ、同じ状態語彙が feature 間で同じ意味になるようにする。

## 実装判断

### Query state

`lib/core/presentation/state/query_state.dart` に、小さな presentation 専用の sealed state を置く。全画面を継承させる base ViewModel は作らず、各 feature state が必要な payload と組み合わせる。

```text
QueryInitial<T>
QueryLoading<T>(previousData?)
QueryData<T>(value, warnings)
QueryEmpty<T>(warnings)
QueryFailure<T>(error, previousData?)
```

- `initial`: load 未開始。空データではない。
- `loading(previousData: null)`: 初回 load。画面全体の loading を表示する。
- `loading(previousData: value)`: refresh/pagination 中。既存データを表示したまま更新表示を加える。
- `data`: 主データ取得成功かつ表示対象あり。補助データの失敗は `warnings` に残せる。
- `empty`: 主データ取得成功かつ表示対象なし。failure ではない。
- `failure(previousData: null)`: 初回 load 失敗。error/retry UI を表示する。
- `failure(previousData: value)`: refresh/pagination 失敗。既存データを維持し、非破壊的なエラー表示と retry を可能にする。

`warnings` は少なくとも失敗した補助データ種別と `AppError` を保持する feature/application 契約にする。ユーザー文言は格納せず、診断用 error と表示用 message を分ける。

### Command state と effect

`lib/core/presentation/state/command_state.dart` と `ui_effect.dart` に次の最小語彙を置く。

```text
CommandIdle
CommandSubmitting(operation)
CommandSucceeded(operation)
CommandFailed(operation, error)

UiEffectEnvelope(id, effect)
```

- 同一 command の二重送信は `submitting` 中に拒否する。
- 成功時だけ navigation、dialog close、再読込、Snackbar 用 effect を発行する。failure は成功 effect を発行しない。
- effect は単調増加 ID を持つ pending event とし、Widget の `ref.listen` が処理後に `consumeEffect(id)` を呼ぶ。処理済み ID と異なる event は消さない。
- command の成否はテスト・ボタン表示用 state、画面遷移や通知は effect として分離する。ViewModel メソッドの戻り値をユーザー文言や callback にしない。

### Error message

`lib/core/presentation/error/app_error_message.dart` に `AppError` の型/code から表示文言への変換を置く。ViewModel state は元の `AppError` を保持し、Widget または presentation mapper だけが表示文言へ変換する。`error.message` の直接表示、例外文字列の連結、application/domain での画面文言生成は増やさない。

## 現行棚卸しと対象スライス

| スライス | 現在の状態・問題 | このフェーズでの到達点 |
| --- | --- | --- |
| Search | `SearchState` が空 list/map、`isLoading`、nullable `errorMessage` を併存。補助 ranking/meaning/star failure は application で空 map へ変換され、活用形 failure はログだけ | query と結果 payload を分離し、初回/追加/refresh を型で表す。主検索 failure と empty を区別し、補助 failure を warning として保持する |
| Quiz Search | Search と同型の複数 field + bool + nullable message。failure 後も空結果と見分けにくい | `QueryState<QuizSearchResults>`、pagination previous data、typed failure を導入する |
| Ranking | item/filter/page と `isLoadingNext/isLoadingPrev` が混在。failure は `false` を返すだけで error が state に残らない | filter/page は画面 state に残し、一覧 load を query state 化。追加 load failure で items/page range を保持し error を残す |
| WordPage | dictionary/conjugation が nullable。failure はログだけで、未load・補助なし・失敗を区別不能 | 辞書を主データ、活用形を optional payload として query state 化。辞書 failure は failure、活用形 failure は warning |
| Quiz Game | quiz progress 自体は同期的な画面固有 state。英語活用形 failure を空 map、活用形 failure を `null` へ変換 | quiz progress は維持し、非同期問題データだけ query state/provider へ分離して failure/empty を保持する |
| MyWord list/item | list は ID の空 list のみ。load failure はログだけ。item の `AsyncValue` は loading/error をダミー文字列へ変換 | list は initial/loading/data/empty/failure + pagination previous data。item は `AsyncValue` を直接描画するか query state へ損失なく写像する |
| MyWord register/update/delete | callback と nullable event state が混在し、success/failure event が残留する | `CommandState` と one-shot effect に統一。成功時のみ dialog close/reload、failure 時は presentation message |
| Word status/MyWord status | `AsyncValue` loading/error を全 false に変換。nullable command event に submitting/error detail がない | read は loading/errorを保つ。toggle ごとの command state と effect を導入し、失敗時に false 表示へ退行させない |
| SignIn/Profile | command ごとの `ButtonStatus`、`Future<String>`、nullable message。Profile save failure と sign-out failure の表現も混在 | 操作別 `CommandState` と typed error/effect に統一。成功メッセージと navigation は effect にする |
| AppSession/Auth lifecycle | 既に sealed/typed state と stream の source of truth がある | 原則維持。画面 command の表示契約だけ合わせ、session lifecycle の再設計は行わない |

## 実装スコープ

### 共通 presentation 契約

- `lib/core/presentation/state/query_state.dart`
- `lib/core/presentation/state/command_state.dart`
- `lib/core/presentation/state/ui_effect.dart`
- `lib/core/presentation/error/app_error_message.dart`
- 上記の pure Dart unit test

### Search / Quiz Search

- `lib/features/search/application/usecase/search_word/search_word_interactor.dart`
- `lib/features/search/application/usecase/search_word/search_word_output_data.dart`
- `lib/features/search/presentation/ui_model/search_ui_model.dart`
- `lib/features/search/presentation/view_model/viewmodel.dart`
- `lib/features/search/presentation/view/search_fragment.dart`
- `lib/features/quiz/presentation/ui_model/quiz_search_model.dart`
- `lib/features/quiz/presentation/view_model/quiz_search_view_model.dart`
- `lib/features/quiz/presentation/view/quiz_search_fragment.dart`
- 対応する fake、application/ViewModel/widget test

### Ranking / MyWord list

- `lib/features/ranking/presentation/ui_model/ranking_ui_model.dart`
- `lib/features/ranking/presentation/view_model/new_ranking_view_model.dart`
- `lib/features/ranking/presentation/view/ranking_fragment.dart`
- `lib/features/ranking/presentation/effect_provider.dart`
- `lib/features/my_word/presentation/ui_model/my_word_ui_model.dart`
- `lib/features/my_word/presentation/view_model/my_word_view_model.dart`
- `lib/features/my_word/presentation/view/my_word_fragment.dart`
- 既存 Ranking test の更新と MyWord list ViewModel test の追加

### Detail / status read state

- `lib/features/word_page/presentation/ui_model/jpn_esp_state.dart`
- `lib/features/word_page/presentation/view_model/word_page_view_model.dart`
- `lib/features/word_page/presentation/view/**`
- `lib/features/quiz/presentation/ui_model/quiz_game_model.dart`
- `lib/features/quiz/presentation/view_model/quiz_game_viewmodel.dart`
- `lib/features/quiz/presentation/view/quiz_game_fragment.dart`
- `lib/app/presentation/dictionary_status_view_models.dart`
- `lib/app/presentation/word_status_buttons.dart`
- `lib/features/my_word/presentation/ui_model/my_word_status_state.dart`
- `lib/features/my_word/presentation/view_model/my_word_item_view_model.dart`
- `lib/features/my_word/presentation/view_model/my_word_status_view_model.dart`
- provider/Widget と状態遷移 test

### Command / effect

- `lib/features/my_word/presentation/view_model/my_word_command.dart`
- `lib/features/my_word/presentation/view_model/my_word_status_command.dart`
- `lib/features/my_word/presentation/ui_model/my_word_event.dart`
- `lib/features/my_word/presentation/ui_model/my_word_status_command_event.dart`
- `lib/features/my_word/presentation/view/create_word_modal.dart`
- `lib/features/my_word/presentation/view/my_word_card_modal.dart`
- `lib/app/presentation/dictionary_status_view_models.dart`
- `lib/features/auth/presentation/ui_model/sign_in_model.dart`
- `lib/features/auth/presentation/view_model/sign_in_view_model.dart`
- `lib/features/auth/presentation/view/**`
- `lib/features/user/presentation/model/user_profile_ui_model.dart`
- `lib/features/user/presentation/view_model/user_profile_view_model.dart`
- `lib/features/user/presentation/view/profile.dart`
- 関連 DI provider と command/effect test

## スコープ外

- Phase 2-3 の `build()` 起点 I/O 除去。今回の UI 分岐変更に必要な provider 契約は整えるが、全 load 起動点の移設は先取りしない。
- Phase 2-4 の Coordinator、`Ref`、`AppNavigatorService` 全廃。今回追加する one-shot effect へ対象画面の成功遷移を移せるが、routing 全体の所有権変更は行わない。
- Phase 2-5 の query projection/domain entity 分離。state payload を明示しても Repository や entity の所有権は変えない。
- Phase 2-6 の `SyncReport` UI 接続。
- word-status の domain/repository/data 契約統合、Local-first 8 の旧 sync API 削除。
- `StateNotifier` から新しい Riverpod Notifier API への全面移行、Freezed 導入、全 state の単一巨大 class 化。
- rename、copy file 統合、obsolete coordinator 削除、依存整理など Phase 3 の作業。
- DB schema、同期 protocol、route contract、検索順・ページサイズ・フィルタ規則などのユーザー向け仕様変更。

## 参照する計画書と contexts

- `docs/refactor/phase2/2-standardize-viewmodel-state.md`
- `docs/refactor/contexts/current.md`
- `docs/refactor/contexts/feature-map.md`
- `docs/refactor/contexts/app-routing.md`
- `docs/refactor/contexts/next-phase-guide.md`
- `docs/refactor/contexts/plans/phase2.1-move-usecases-to-application.md`
- `docs/FLUTTER_ARCHITECTURE_REVIEW.md` 5、8.1、9.1、9.2

依存条件は満たされている。Phase 0 の `Result` 伝播修正と Phase 2-1 は完了済みで、2026-08-07 時点の context では analyze と全 test が成功している。

## 実装手順

### 0. Characterization test と遷移表を先に固定する

1. Search、Quiz Search、Ranking、WordPage、MyWord list、MyWord commands、SignIn/Profile、word status の現行 provider と ViewModel public API を一覧化する。
2. 現行の成功時 payload、pagination の page 計算、filter reset、辞書方向、dialog close/reload 順序を characterization test で固定する。
3. 各スライスに次の遷移表を作り、未定義遷移を実装前に解消する。

```text
initial -> loading -> data | empty | failure
data -> loading(previous) -> data | empty | failure(previous)
empty -> loading -> data | empty | failure
idle -> submitting -> succeeded + effect | failed
```

4. 遅い旧 request が新 query/filter の結果を上書きしないよう request token/query snapshot を state transition test に含める。起動点の移設は Phase 2-3 に残す。

### 1. 小さな共通語彙を導入する

1. `QueryState<T>`、`CommandState`、effect envelope/consume 契約を pure presentation 型として追加する。
2. `previousData` と `warnings` の不変条件、`hasData`/`isInitialLoading` など必要最小限の selector を定義する。
3. `AppError` → 表示文言 mapper を追加し、少なくとも validation、unauthorized、not-found、database/network、unexpected の fallback をテストする。
4. 共通型に feature entity、Riverpod、Navigator、BuildContext、Repository、UseCase を import させない。

### 2. Search application の warning 契約を修復する

1. ranking number、simple meaning、star count の各補助取得結果を `_records` で空 map に潰さず、成功値と warning を同時に返す。
2. `Search*OutputData` に warning 情報を追加する。主検索失敗は従来どおり `Result.failure`、補助取得だけの失敗は主 payload 成功 + warning とする。
3. Esp-Jpn、Jpn-Esp、活用形、Quiz 用検索の4経路に同じ規則を適用する。
4. 「本当に補助情報が0件」と「取得失敗で値がない」を application test で区別する。

### 3. Search と Quiz Search を query state へ移行する

1. query/filter の入力 state と検索結果 payload を分け、`copyWith` で nullable error を消せない問題を除去する。
2. 空 query は `initial`、初回0件成功は `empty`、初回 failure は `failure` にする。
3. pagination は `loading(previousData)` を経由し、成功時だけ append/page 更新する。failure 時は previous data と warning/error を保持する。
4. query snapshot または generation ID を照合し、旧 query の完了結果を破棄する。
5. Widget は list の空・非空ではなく query state を exhaustive に描画する。initial、loading、empty、failure/retry、data + pagination indicator、data + warning を区別する。

### 4. Ranking と MyWord list を移行する

1. Ranking は filter/page metadata と `QueryState<RankingItems>` を分離する。`isLoadingNext/isLoadingPrev` と `Future<bool>` による failure 表現を query state へ置換する。
2. 追加 load failure では items、`currentPageRange`、`hasNext` を変更せず `QueryFailure(previousData)` にする。成功0件だけを終端ページとして扱う。
3. filter 変更では query を `initial` に戻し、既存 `rankingFilterEffectProvider` の scroll reset は UI-only effect のまま維持する。
4. MyWord list も同じ pagination 規則へ揃え、`_previousItemLength` 比較を状態契約から導ける `hasNext`/load result に置き換える。
5. refresh failure では表示中の list を消さず、retry 可能な warning/error を表示する。

### 5. WordPage、Quiz Game、item/status read を移行する

1. WordPage の nullable dictionary/conjugation を、方向ごとの明示 payload を持つ query state にする。`copyWithNull` を削除できる形にする。
2. 辞書取得を主結果、活用形取得を optional 補助結果として扱う。辞書 failure は `QueryFailure`、活用形 failure は dictionary data + warning とする。
3. Quiz Game の progress state は維持し、`fetchEnglishConj()` の空 map fallback と `getConjugaciones()` の `null` fallback を非同期 query state/provider に置換する。
4. MyWord item と3種 status adapter は `AsyncValue` の loading/error をダミー文字列や false 値へ変換しない。Widget が loading/error/data を描画できる型を公開する。
5. refresh 中は status button を直前値で表示できるが、初回 loading/failure を false status として操作可能にしない。

### 6. MyWord と word-status command を統一する

1. register/update/delete/toggle を `idle -> submitting -> succeeded|failed` にする。
2. `registerWord` の `onComplete/onError/onInvalid`、update/delete の `onComplete` を削除し、typed failure と effect に変換する。
3. 成功時にのみ `closeDialog`、`reloadList`、必要な success notice effect を発行する。validation failure と repository failure の表示を分ける。
4. nullable `MyWordCommandEvent`、`MyWordStatusCommandEvent`、`WordStatusCommandEvent` を effect envelope または command state へ置換し、error detail を保持する。
5. 同じ effect が rebuild/provider再購読で二重処理されず、別 ID の新 effect を誤消費しないことを test する。

### 7. Auth/Profile command を統一する

1. `SignInUIState` の5つの `ButtonStatus` を、操作キー付き command state へ置換する。同時実行を許す必要がある操作だけ feature state 内に独立 slot を持つ。
2. `Future<String>` を返す sign-in/sign-up/sign-out/password reset を `Future<void>` + state/effect に変更する。
3. `UserProfileUIState` の save/sign-out を typed command state にし、成功後の通知・画面遷移を effect にする。
4. `AppSession` と `AuthLifecycleState` は変更せず、認証 identity/profile の source of truth を増やさない。
5. error message は mapper 経由で Widget に表示し、認証・profile state にユーザー向け文言を埋め込まない。

### 8. UI、DI、旧型を収束させる

1. 各 Widget の `ref.listen` を effect ID + consume 契約へ揃え、`build()` 内で effect を実行しない。
2. provider 型と test override を新 state/effect contract に更新する。
3. 参照が0になった `ButtonStatus` の利用、旧 event class、nullable `errorMessage`、dummy `loading/error` model、callback 引数を削除する。enum/file 自体の全面削除は参照0を確認できた場合だけ行う。
4. `rg` で `Failure -> []/{}/null/default false`、`Future<String>` command、UI callback、raw `error.message` 表示が対象スライスに残っていないことを確認する。

## テスト計画

### 共通 state test

- initial、初回 loading、data、empty、failure の相互排他。
- refresh loading/failure が previous data を保持する。
- data/empty が warnings を保持する。
- command が idle/submitting/succeeded/failed を正しく遷移し、submitting 中に二重送信しない。
- effect ID の発行、consume、古い ID による新 effect の誤消費防止。
- AppError の presentation message mapping と unknown fallback。

### ViewModel test

- Search/Quiz Search: 初回成功、0件、主 failure、補助 failure warning、pagination成功/failure、query競合。
- Ranking/MyWord list: 初回empty、append、終端、追加 load failure の previous data/page保持、filter/refresh。
- WordPage: 主辞書 failure、辞書成功 + 活用形 failure warning、方向切替時の stale response 防止。
- item/status: loading/error が dummy data/false に変換されない、refresh時だけ previous value を使う。
- MyWord/word-status command: success effect、failure時 success effectなし、二重submit抑止、effect単回消費。
- Auth/Profile: validation/repository failure、各操作の独立状態、成功notice、failure時navigationなし。

### Widget test

- initial、loading、empty、failure + retry、data、previous data + refresh error の表示。
- warning が主データを隠さず表示される。
- 保存中は対象操作だけ無効化される。
- dialog close/navigation/Snackbar が成功時に1回だけ、rebuild後に再実行されない。

### Architecture/static checks

- application/domain から presentation state、effect、表示文言、BuildContext/Navigator を importしない。
- common presentation state から feature/application/infrastructure を importしない。
- 対象 application の補助 failure を空 mapへ変換しない。
- import-boundary baseline に新規違反を追加しない。

## 検証順序

各 slice で関連 test を先に実行し、最後に全体検証を行う。Flutter/Dart command はリポジトリ指示どおり sandbox 外で直接実行する。

```text
flutter test test/unit/core/presentation
flutter test test/unit/features/search
flutter test test/unit/features/quiz
flutter test test/unit/features/ranking/presentation/view_model/ranking_view_model_test.dart
flutter test test/unit/features/my_word
flutter test test/unit/features/auth
flutter test test/unit/features/user
flutter test test/widget
flutter test test/tool/import_boundaries/check_import_boundaries_test.dart
flutter analyze
flutter test
```

実際の追加 test path に合わせて絞り込みコマンドは調整する。生成コードを変更した場合だけ build runner を実行するが、本計画では Freezed 等の生成コード導入を前提にしない。

## contexts 更新方針

- 実装中の詳細、完了 slice、検証結果、未解決事項は本 plan の状態とチェック項目へ反映する。
- 全主要 slice と全体検証が完了した時だけ `docs/refactor/phase2/2-standardize-viewmodel-state.md` を完了へ更新する。
- 全体の現在地が変わる完了時だけ `docs/refactor/contexts/current.md` に、採用した state/effect 契約、移行済み slice、検証結果、Phase 2-3 の入口を短く追記する。
- build-time I/O、Coordinator/Ref、projection ownership など実装中に見つけたスコープ外事項は、それぞれ Phase 2-3/2-4/2-5 の future note として根拠 path と触らなかった理由を残す。

## 完了条件

- [ ] Search、Quiz Search、Ranking、MyWord list、WordPage で initial/loading/data/empty/failure が型として区別される。
- [ ] refresh/pagination failure が previous data と page/filter metadata を破壊しない。
- [ ] Search の補助データ failure が空 mapへ消えず warning として presentation に届く。
- [ ] Quiz/WordPage/status/item の failure が `null`、空 map、dummy文字列、false status に変換されない。
- [ ] MyWord、word-status、Auth、Profile の command に idle/submitting/succeeded/failed があり、二重送信を防げる。
- [ ] command failure で成功 notification、dialog close、navigation、reload effect が発行されない。
- [ ] one-shot effect が rebuild/再購読で二重処理されないテストがある。
- [ ] error-to-message 変換が presentation にあり、対象 Widget が raw `error.message` を直接表示しない。
- [ ] 主要 ViewModel に初回成功、empty、failure、refresh/pagination failure の状態遷移 test がある。
- [ ] Phase 2-3以降、同期、DB、route contract、ユーザー向け検索仕様へ変更が波及していない。
- [ ] import boundary check、`flutter analyze`、全 `flutter test` が成功する。

## 実装単位と停止条件

実装は「共通契約」「Search warning」「Search/Quiz Search」「Ranking/MyWord list」「detail/status read」「MyWord/status command」「Auth/Profile command」「UI収束」の順で小さく進める。各単位で対象 test が失敗したまま次へ進まない。状態語彙を揃えるために Repository、同期、routing、DB まで変更する必要が出た場合は、その変更を行わず本 plan のスコープ外メモへ記録して判断を止める。
