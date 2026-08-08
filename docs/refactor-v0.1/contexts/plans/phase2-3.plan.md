# Phase 2-3: build時I/O除去の実装計画

## 完了状況

この計画に記載した実装および検証は完了。

- [x] Word Detail のロード処理を provider lifecycle へ移管した。
- [x] WordPage の公開 fetch API を撤去した。
- [x] `quizWordProvider` の更新処理を撤去した。
- [x] Word Detail の状態遷移テストを補完した（unit test: 9 passed）。
- [x] Bootstrap の rebuild と readiness failure を対象とするテストを追加・更新した。
- [x] `flutter analyze` が成功した（Word Detail 対象および全体検証）。
- [x] `flutter test` 全件が成功した（286 tests）。

実施した検証は、本計画のテスト要件のうち Word Detail の provider lifecycle、公開 fetch API の撤去、状態遷移、quiz state 更新の撤去、Bootstrap の再ビルドおよび readiness 失敗表示に関する範囲をカバーする。

## 概要

現行コードで残っている `WordPageFragment.build()` 起点の辞書取得と、`EspJpnDictionaryFragment.build()` からの `quizWordProvider` 更新を除去する。Word Detailのロードは、`wordId`・辞書方向・活用有無を値として持つprovider familyのライフサイクルへ移し、同じキーでは一度だけ取得する。

起動処理はすでに `app/bootstrap` の `FutureProvider` に移行済みのため構造変更せず、一度だけ実行されることと失敗表示をテストで固定する。

## 実装変更

### Word Detailのロード所有権

- `wordId`、`WordType`、`hasConj`を持ち、値等価性を実装した不変な `WordPageLoadKey` をpresentation query用の型として追加する。
- `wordPageViewModelProvider` のfamily引数を `int` から `WordPageLoadKey` に変更する。
- provider生成時に `WordPageViewModel.initialize()` を一度だけ呼び、Widgetはproviderをwatchして描画するだけにする。
- `initialize()` は内部の開始済みフラグで冪等化し、複数Widgetから同じキーをwatchしてもfetchを重複させない。
- 既存の公開fetchメソッドは初期ロード処理へ統合し、Widgetから直接呼べない形にする。
- `jpnEsp` は和西辞書だけ、`espJpn` は西和辞書と、`hasConj=true` の場合だけ活用データを取得する。
- 西和辞書成功・活用取得失敗時は、既存仕様どおり辞書データを表示しつつwarningと活用failureを保持する。辞書自体の失敗はfailureとして保持し、空データへ変換しない。
- `autoDispose` は維持する。I/O契約がキャンセルAPIを持たないため、dispose後および古いキーの完了結果は `mounted` とロード世代の確認で破棄し、stateへ反映しない。
- Word Detail配下の辞書・活用Fragmentには同じ `WordPageLoadKey` を渡し、全Fragmentが同じprovider instanceを参照する。
- 対象の中心は [word_page_fragment.dart](C:/Users/deded/Documents/LocalDev/my_dic/lib/features/word_page/presentation/view/word_page_fragment.dart)、ViewModel、DI providerとする。

### 描画stateとUI副作用の分離

- `build()` 内の `fetchJpnEspDictionaryById()` と `fetchEspJpnItemsById()` 呼び出しを削除する。
- `EspJpnDictionaryFragment` の `addPostFrameCallback` と `quizWordProvider` 更新を削除する。
- `quizWordProvider` は読み取り利用がないため削除し、検索・ランキング・Word Detailに残る書き込みも除去する。
- クイズ画面の単語は既存の `QuizGameRoute.word` を唯一の入力とし、URL・route schemaは変更しない。
- Word Detailのクイズボタンはロード済み辞書の見出し語を `QuizGameRoute` に渡す。辞書データが未取得・empty・failureの間は遷移を無効化する。
- navigation、ダイアログ、Snackbarなどはボタンコールバックまたは既存の `ref.listen`／`listenManual` 内に限定する。通常のWidget評価中には実行しない。
- My Word、Ranking、Searchのページネーションはスクロールイベント起点であり、build時I/Oではないため今回の構造変更対象外とする。

### Bootstrapの固定

- 現行の `AppBootstrapper` → `ProviderScope` → `appReadinessProvider` という初期化順序を維持する。
- DB probeとapplication lifecycle effectの有効化は `appReadinessProvider` に残し、`AppReadinessGate.build()` は `AsyncValue` の描画だけを担当する。
- readiness providerの再watchやWidget rebuildでDB probe・effect登録が再実行されないことをテストで固定する。
- readiness失敗時も `BootstrapFailureApp` が表示され、`MyApp` を構築しないことを確認する。

## API・型の変更

- 追加: `WordPageLoadKey(wordId, wordType, hasConj)`。
- 変更: `wordPageViewModelProvider(int)` → `wordPageViewModelProvider(WordPageLoadKey)`。
- 変更: Word Detail配下Fragmentの入力を単独の `wordId` から共通ロードキーへ統一する。
- 削除: Widgetから呼ばれていた個別初期fetch APIと未使用の `quizWordProvider`。
- 維持: `WordDetailRoute`、`QuizGameRoute` のURL形式、UseCase／Repositoryインターフェース、永続データ形式。

## テスト計画

- fake UseCaseの呼び出し回数を記録し、同じロードキーを複数回watch・rebuildしても各fetchが一回だけであることを確認する。
- 同じキーを複数の子Fragmentがwatchしても同じstateを共有することを確認する。
- `wordId`、辞書方向、`hasConj` の変更で新しいproviderが生成され、必要なUseCaseだけが呼ばれることを確認する。
- `hasConj=false` では活用取得が呼ばれないことを確認する。
- success、empty、辞書failure、活用のみfailureの各 `QueryState` 遷移を確認する。
- `Completer` で取得を保留し、provider dispose後に完了させてもstate更新や非同期例外が発生しないことを確認する。
- Word Detailを繰り返しpumpしてもfetch・navigation・quiz state更新が発生せず、ボタン操作時だけ実際の見出し語で一度遷移することを確認する。
- bootstrapの成功一回、環境初期化失敗、readiness失敗、rebuild時の非重複をWidget testで確認する。
- 最終検証として `flutter analyze`、対象テスト、`flutter test` 全体を実行する。現時点の基準では静的解析と既存bootstrapテストは成功している。
- 検証完了後、対象リファクタ文書の状態と完了チェックリストを更新する。

## 前提

- 実I/Oのキャンセル機構はUseCase契約へ追加せず、このフェーズではdispose後の結果無視で安全性を保証する。
- ページネーション、クイズ全体のstate再設計、DB ownership、Coordinatorからの`Ref`除去は別フェーズとして扱う。
- ユーザー操作に直接結び付いたコールバック内のmutationやnavigationは許容し、描画評価中に自動実行される副作用だけを禁止する。
