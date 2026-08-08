# Phase 2-6: SyncReportをUI・retry・telemetryへ接続する実装プラン

- 対象タスク: [`../../phase2/6-consume-sync-report.md`](../../phase2/6-consume-sync-report.md)
- 状態: 実装前
- 作成日: 2026-08-07
- 前提: Local-first 4の`SyncEngine`/`SyncReport`、5 dataset handler、Drift `sync_outbox`がproduction compositionへ接続済みであること

## 目的

`SyncEngine.runOnce()`が返す不変の`SyncReport`を、次の3つの用途へ明示的に接続する。

1. manual syncの実行状態とユーザー向け結果表示。
2. retryableなoutbox failureの時刻どおりの再起動。
3. payloadや個人識別子を含まない構造化log/metrics。

raw `SyncReport`を永続化したり、全アプリ状態を保持する第二のStoreにしたりしない。未送信mutation、attempt count、`nextAttemptAt`、dead-letterの正本は引き続きDrift `sync_outbox`とする。UIはreportから導出した小さな表示状態だけを保持し、telemetryはreportを安全なイベントへ即時変換する。

## 現状調査

### Engineとreport

- `lib/features/sync/application/sync_engine.dart`はdataset順にhandlerを実行し、成功、skip、failure、cancelを`SyncReport.datasetResults`へ保持する。
- `SyncReport.datasetResults`はunmodifiableである。`accountId`、cycle開始・終了時刻、dataset結果を持つ。
- `DatasetSyncResult`は既に必要なsealed variantを持つため、このPhaseでvariantや永続形式を作り直さない。
- 一部datasetが失敗しても独立datasetは続行される。親dataset失敗時の子datasetは`dependency did not succeed`でskipされる。
- Engineが想定外例外を`handler_exception`へ変換する一方、skip/cancel reasonの一部は表示文に近い自由文字列である。

### 呼び出し元

- `lib/app/bootstrap/lifecycle_effects.dart`はsession readyとapp resumeで`scheduler.foreground(...)`を呼ぶが、返されたreportを破棄している。
- `lib/app/guest_migration/presentation/guest_migration_prompt.dart`も移管後syncのreportを破棄し、例外だけを文字列logへ出している。
- `SyncScheduler`は現状`SyncEngine.runOnce()`への一行委譲であり、observer、retry wake-up、disposeを持たない。
- 明示的なmanual syncボタン、manual sync ViewModel、reportのUI interpreterは存在しない。

### Queueとretry

- 各handlerはretryable failure時に`SyncQueue.retry(...)`を呼び、attempt数に応じたbackoff後の`nextAttemptAt`をDriftへ保存する。
- `DriftSyncQueue.leasePending(...)`は`nextAttemptAt <= now`だけをleaseする。このため早すぎるforeground triggerが発生してもmutation自体は強制再送されない。
- Queueにはaccount単位の最早`nextAttemptAt`を読むAPIがなく、指定時刻にEngineを再起動するschedulerもない。
- dead-letterはQueueで別stateになるが、payloadを読まずに状態を集計するquery APIはない。

### error分類と観測

- `SyncErrorClassifier`は現在、例外文字列から`auth_required`、`invalid_payload`、`transient_remote_failure`へ分類する。offlineと一般的な一時remote failureは区別されていない。
- `AppLogger.event`にはkeyベースの再帰redactionがあるが、`SyncReport`専用serializerはない。report自体をloggerへ渡すと`accountId`やcursorを誤って出す余地がある。
- analytics/telemetry backendは導入されていない。既存dependencyで利用できるのは構造化loggerまでである。

### presentation

- `MainActivity`のapp barにはprofile導線があり、全主要画面から到達できる。同期は横断機能なので、manual sync入口はこのapp barに置く。
- local write系ViewModelは既にlocal Repositoryの成功をcommand successとして扱う。remote delivery結果を既存commandの失敗へ上書きする経路はない。この分離を維持する。
- 一度きりの通知には既存の`UiEffectEnvelope`/`UiNoticeEffect`パターンを利用できる。

## 採用する設計

```text
MainActivity sync button
        |
        v
ManualSyncController ---- AppSession / SessionFence
        |                         |
        +------ SyncScheduler.foreground(SyncContext)
                                      |
                         SyncEngine.runOnce()
                                      |
                         immutable SyncReport
                           /          |          \
                          v           v           v
                 UI interpreter   telemetry    retry decision
                 (derived state)   serializer   (Queue due time)
                                                   |
                                             one-shot timer
                                                   |
                                        reason = retry_due

Drift sync_outbox = pending/retry/dead-letterの唯一の永続的な正本
```

### 1. reportのapplication-level集計

`SyncReport`本体へUI文言やlogger依存を追加せず、pureな集計器を`features/sync/application`に追加する。

候補:

- `lib/features/sync/application/report/sync_report_summary.dart`
- `lib/features/sync/application/report/sync_report_interpreter.dart`
- `lib/features/sync/application/report/sync_reason_codes.dart`

`SyncReportSummary`は少なくとも次を持つ。

- cycle全体の`duration`。
- success、skipped、retryable failure、non-retryable failure、cancelledのdataset集合または件数。
- pushed/pulled合計。countはsuccess variantからだけ集計する。
- `hasPartialSuccess`、`hasRetryableFailure`、`hasNonRetryableFailure`、`isCancelledOnly`等のpure getter。
- error codeとreason codeの安全な集合。cursor、account ID、entity/payloadは持たせない。

分類優先順位は次で固定する。

1. 全datasetがcancelled、またはsession変更によるcancel: `cancelled`。ユーザーエラー通知なし。
2. 全datasetが`sync_already_running`: `alreadyRunning`。二重実行エラーにしない。
3. 1件でも`auth_required`: `authenticationRequired`。
4. 1件でもnon-retryable failure: `needsAttention`。成功datasetがあれば同時にpartialであることも保持する。
5. retryable failureがあり、そのcodeがoffline: `offlineDeferred`。
6. その他のretryable failure: `retryScheduled`または`temporarilyUnavailable`。
7. failureがあり、別datasetは成功: `partialSuccess`。
8. 全対象dataset成功: `succeeded`。

`DatasetSyncSkipped`は一律成功扱いにしない。`dependency_failed`は元failureに付随するpartial result、`sync_already_running`はbusy、productionでは本来発生しない`handler_unavailable`はinternal warningとして扱う。

### 2. reason/error codeの安定化

自由文字列をUIやmetricsが直接比較しないよう、Engineが生成するskip/cancel理由とclassifierが生成するerror codeを定数化する。sealed result自体は変更しない。

最低限のstable code:

```text
skip: sync_already_running, dependency_failed, handler_unavailable
cancel: session_changed, caller_cancelled
failure: offline, auth_required, invalid_payload,
         transient_remote_failure, handler_exception
trigger: session_ready, app_resumed, post_guest_migration,
         manual, retry_due
```

- handler内部の細かなcancel位置（before start、during push等）はUI分類に使わない。
- telemetryでは既知codeだけを出し、未知のreason/errorは文字列をそのまま出さず`unknown`へ正規化する。
- offline判定はFirestore/transport例外の既知codeを`SyncErrorClassifier`で`offline`へ正規化する。認証切れは`auth_required`、schema/validationは`invalid_payload`を維持する。
- classifierの文字列判定をこのPhaseで全面的な例外hierarchyへ作り直さない。ただし入力とstable outputのcharacterization testを追加する。

### 3. manual syncのUIモデル

cross-featureなUIであるため、controllerと表示modelは`lib/app/presentation/sync/`に置く。`features/sync/application`へFlutter、Riverpod、UI文言を入れない。

候補:

- `lib/app/presentation/sync/manual_sync_controller.dart`
- `lib/app/presentation/sync/manual_sync_state.dart`
- `lib/app/presentation/sync/sync_ui_message.dart`
- provider追加先: `lib/app/bootstrap/sync_composition.dart`または専用`sync_presentation_composition.dart`

`ManualSyncController`は次だけを担当する。

1. `AppSessionReady`のaccount IDとcurrent epochから`SyncContext(reason: manual)`を作る。
2. 実行中はbuttonをdisableし、重複tapを発生させない。
3. schedulerから返ったreportをpure interpreterへ渡す。
4. raw reportをstateへ保持せず、`ManualSyncOutcome`とone-shot noticeだけを保持する。
5. controller dispose後やsession切替後の古い完了通知を捨てる。

UI表示規則:

| outcome | 表示 | error扱い |
| --- | --- | --- |
| 全成功 | 「同期しました」+ 任意の送受信件数 | しない |
| 一部成功 | 「一部を同期できませんでした。保存済みの変更は保持されています」 | warning |
| offline | 「変更は端末に保存済みです。接続復帰後に再試行します」 | local操作失敗にしない |
| retryable remote failure | 「変更は保存済みです。しばらくして再試行します」 | warning |
| auth required | 「同期するには再ログインが必要です」 | warning。自動sign-outはこのPhaseで行わない |
| non-retryable/dead-letter | 「同期できない変更があります」 | warning。dataset名やpayload本文は画面に出さない |
| session change/cancel | noticeを出さない | errorにしない |
| already running | buttonのrunning表示を維持するか、通知なし | errorにしない |

`MainActivity` app barへsync iconを追加し、`AppSessionReady`時だけ有効にする。実行中は既存`RotatingIcon`を表示する。結果通知は既存のexactly-once effect consumptionに合わせて`ScaffoldMessenger`で表示する。未認証・未検証・profile loading中はremote syncを開始しない。

local mutationのcommand ViewModelや成功toastは変更しない。remote delivery failureが後から発生しても「保存に失敗しました」へ変換せず、sync専用warningとしてのみ表示する。

### 4. telemetry portと安全なserializer

application側にbackend非依存portを追加し、schedulerが全triggerのreportを必ず1回渡す。

候補:

- `lib/features/sync/application/port/sync_telemetry.dart`
- `lib/features/sync/infrastructure/telemetry/app_logger_sync_telemetry.dart`

初期adapterは既存`AppLogger.event`への構造化出力とする。将来analytics backendを追加する場合も同じportを実装し、このPhaseのserializer testを再利用する。イベント例:

```text
event: sync_cycle_completed
context:
  trigger: manual
  duration_ms: 123
  outcome: partial_success
  pushed_count: 2
  pulled_count: 4
  datasets:
    - dataset: my_words
      result: failed
      error_code: transient_remote_failure
      retryable: true
      cursor_unchanged: true
```

禁止field:

- `accountId`、uid、email、device ID。
- access/refresh token、authorization、credential。
- cursor本体とdocument ID。
- mutation ID、entity ID、field mask。
- payload、単語、メモ、プロフィール本文。
- raw exception、stack trace、自由入力されたreason。

durationは現行reportの`finishedAt - startedAt`であるcycle durationを使う。dataset別durationは現行contractに存在しないため、`SyncReport`を再設計してまで追加しない。datasetごとの件数はsuccess resultだけから出し、failed resultに存在しない部分件数を推測しない。

loggerへ`SyncReport`や`DatasetSyncResult.toString()`を直接渡すことを禁止し、安全なserializerが構築したprimitive mapだけを渡す。telemetry adapter自身が例外を投げてもsync結果やUIを失敗させない。

### 5. Queue時刻に従うretry scheduling

`SyncQueue`へpayloadを返さないread APIを追加する。

```dart
Future<DateTime?> earliestPendingAttemptAt({required String accountId});
```

`DriftSyncQueue`では`state == pending`かつ対象accountの行だけから最小`nextAttemptAt`を返す。dead-letterとleased rowはtimer対象外とする。Fake/Drift contract testでaccount分離、UTC、empty、dead-letter除外を固定する。

timerは交換可能な小さなportへ分離する。

```text
SyncRetryWakeup
  schedule(accountId, dueAt, callback)
  cancel(accountId)
  dispose()
```

production実装はaccountごとに高々1本の`Timer`を持つ。新しいdue timeが既存より早い場合だけ置き換える。testではfake clock/fake wake-upを使い、実時間sleepを行わない。

`SyncScheduler.foreground(context)`の処理順:

1. Engineを実行してreportを得る。
2. telemetryへ安全に通知する。
3. reportにretryable failureがある場合だけQueueの最早pending時刻を読む。
4. `nextAttemptAt`より前にはEngineを再起動しないtimerを設定する。
5. timer発火時は同account/epoch、新しい`CancellationToken`、`reason: retry_due`でEngineを起動する。
6. retry runのreportも同じtelemetryと再arm判定へ通す。
7. session変更時は旧account timerをcancelする。競合して既にcallbackが始まっていてもSessionFenceが旧epochのapply/ackを拒否する。

manual、resume等がretry期限前にEngineを起動しても、Queueの既存`leasePending(nextAttemptAt <= now)`条件を変更しない。pullは実行できるが、pending mutationの早期再送は起きない。

retryableなpull failureでQueue行が存在しない場合、このtimerは作らない。network復帰、resume、次回manual等のforeground triggerで再試行する。Queueにないpull retryまで永続scheduler化することはスコープ外とする。

non-retryable failure/dead-letterではtimerを作らない。dead-letter件数表示が必要な場合はpayloadを返さない別集計queryを追加し、`peekPending()`やraw rowをpresentationへ公開しない。

### 6. lifecycle/sessionとの接続

- `lifecycle_effects.dart`はfire-and-forgetの例外文字列logをやめ、schedulerがreport観測とretry armを行う経路へ統一する。
- scheduler自体がEngine外例外を安全な`sync_cycle_crashed`イベントへ変換する。ただし例外をmanual callerへは返し、controllerが予期しない失敗noticeを出せるようにする。
- `session_composition.dart`でaccount変更時に旧accountのretry wake-upをcancelする。新accountは`AppSessionReady`後の既存triggerでsyncを開始する。
- guest migration後triggerも同じscheduler observerを通す。結果はmigration自体の成功・失敗表示を上書きしない。
- scheduler providerの`ref.onDispose`でtimerを全てcancelする。

## 実装手順

### Stage 0: baselineと契約を固定する

1. import-boundary check、`flutter analyze`、全testの開始時結果を記録する。
2. 現在のEngine testへ全成功、一部失敗、dependency skip、already-running、session cancelのreport characterizationを補う。
3. 5 handlerすべてについてretryableがQueueのpending+future `nextAttemptAt`、non-retryableがdead-letterになる既存testの有無をinventoryし、不足分を共通contract testまたはdataset別testで固定する。
4. lifecycleとguest migrationのscheduler caller、既存sync buttonが0件であることを`rg`で記録する。
5. `SyncReport`とloggerにaccount ID、cursor、payloadが渡されていない現状をsecurity testのbaselineにする。

Stage gate: 現行挙動がtestで再現でき、Local-first 8の未完了Emulator実行をこのPhaseのunit実装完了と混同していない。

### Stage 1: stable codeとreport interpreterを追加する

1. skip/cancel/error/trigger codeの定数を追加する。
2. Engineとclassifierをstable code使用へ置換する。
3. offline/auth/non-retryable/unknownのclassifier testを追加する。
4. `SyncReportSummary`とinterpreterを追加し、raw reportからUI/telemetry共通の安全な集計値を作る。
5. success/partial/offline/auth/retry/non-retryable/cancel/busyのtable-driven testを追加する。

Stage gate: UI文言、Riverpod、loggerなしで全分類をpure unit testできる。

### Stage 2: telemetryを全reportへ接続する

1. `SyncTelemetry` portとno-op/fakeを追加する。
2. `AppLoggerSyncTelemetry`のserializerを実装する。
3. schedulerが成功reportを一度だけobserverへ渡すよう変更する。
4. lifecycle、resume、guest migration、manual、retryのtrigger codeを固定する。
5. serializer security testで禁止値と禁止keyが出力に存在しないことを確認する。
6. telemetry失敗がEngine結果やmanual resultを変えないtestを追加する。

Stage gate: 部分失敗が構造化eventに残り、raw report/account/cursor/payloadがlogへ渡らない。

### Stage 3: Queue-aware retry timerを実装する

1. `SyncQueue.earliestPendingAttemptAt`をFakeとDriftへ追加する。
2. Drift fixtureでaccount scope、UTC、state filter、最小値を検証する。
3. fake wake-up/clockを使えるretry scheduling portを追加する。
4. schedulerにretryable reportからのarm、同時timer一本化、再arm、disposeを実装する。
5. `nextAttemptAt - 1ms`ではEngine未実行、時刻到達時だけ実行するtestを追加する。
6. non-retryable/dead-letter/cancel/successでは新規timerを作らないことを確認する。
7. manual/resumeが期限前に走ってもQueue leaseが0件である既存Drift testと結合して、早期再送なしを固定する。
8. account切替で旧timerをcancelし、callback競合時もold epochがcancel reportになることを確認する。

Stage gate: retry予定時刻はQueueだけから決まり、scheduler固有の別backoffや別永続状態が存在しない。

### Stage 4: manual sync controllerとUIを接続する

1. manual state、outcome、message mapperを追加する。
2. controllerがcurrent account/epochでcontextを作り、raw reportを保持せずderived state/effectへ変換する。
3. `MainActivity` app barにready時だけ有効なsync buttonとrunning iconを追加する。
4. exactly-once notice listenerを追加し、dispose/session change後のstale noticeを抑止する。
5. 全成功、一部成功、offline、auth、dead-letter相当、cancel、double tapのcontroller testを追加する。
6. widget testでbutton enable条件、spinner、SnackBar、cancel時にSnackBarが出ないことを確認する。
7. local writeの既存success testを維持し、remote未送信がcommand failureへ変換されていないことを確認する。

Stage gate: ユーザーが手動実行結果を区別でき、local保存成功とremote delivery状態が別の表示経路にある。

### Stage 5: 全caller収束と文書更新

1. lifecycleとguest migrationの直接的な例外文字列logを安全なscheduler/telemetry経路へ置換する。
2. `SyncReport`を受け取って破棄するactive callerがないことを検索する。
3. retry用Timer、report、derived UI stateがDBやSharedPreferencesへ保存されていないことを確認する。
4. focused test、security test、import check、analyze、全testを順に実行する。
5. completion criteriaを満たした時だけ元タスクとcontextsを完了へ更新する。

## 対象ファイル

### 主な更新候補

- `lib/features/sync/application/sync_scheduler.dart`
- `lib/features/sync/application/sync_engine.dart`
- `lib/features/sync/application/policy/sync_error_classifier.dart`
- `lib/features/sync/application/port/sync_queue.dart`
- `lib/features/sync/infrastructure/persistence/drift/drift_sync_queue.dart`
- `lib/app/bootstrap/sync_composition.dart`
- `lib/app/bootstrap/lifecycle_effects.dart`
- `lib/app/bootstrap/session_composition.dart`
- `lib/app/guest_migration/presentation/guest_migration_prompt.dart`
- `lib/main_activity.dart`

### 新規候補

- `lib/features/sync/application/report/**`
- `lib/features/sync/application/port/sync_telemetry.dart`
- `lib/features/sync/application/port/sync_retry_wakeup.dart`
- `lib/features/sync/infrastructure/telemetry/app_logger_sync_telemetry.dart`
- `lib/features/sync/infrastructure/scheduling/timer_sync_retry_wakeup.dart`
- `lib/app/presentation/sync/**`
- 対応する`test/unit/features/sync/**`、`test/unit/app/presentation/sync/**`、`test/widget/sync/**`

ファイル名は既存配置との衝突を再確認して実装時に確定する。generated Drift fileを手編集しない。この計画のQueue queryは既存table/indexで実装可能なため、原則としてschema versionは上げない。実測でaccount/state/nextAttemptAt queryが問題になる場合だけ、別のmigration計画としてindex追加を判断する。

## テスト計画

### report interpreter

- 5 dataset全成功で`succeeded`、件数合計、正のdurationになる。
- 1 dataset failureでも他のsuccess結果と件数が保持される。
- parent failure + child dependency skipが一つのpartial failureとして解釈される。
- offline、auth、transient、invalid payload、handler exceptionを区別する。
- cancel-onlyとsession changeはsilent outcomeになる。
- already-runningはerrorやpartial failureにならない。
- unknown reason/errorのraw文字列をsummary/telemetryへ出さない。

### scheduler/retry

- retryable failure + future pending rowで最早時刻に1 timerだけ設定される。
- timer発火前にEngineを呼ばない。
- 同じaccountの遅い時刻で早いtimerを上書きしない。
- retry後もfuture pendingが残れば再armする。
- success、cancel、non-retryable、dead-letterだけではarmしない。
- account Aのdue timeにaccount Bのrowが影響しない。
- session変更とprovider disposeでtimerがcancelされる。
- stale callbackが走ってもSessionFenceでapply/ackされない。
- telemetry observer例外がretry schedulingを止めない。

### manual UI

- ready sessionだけbuttonが有効である。
- tapから完了までrunning表示となりdouble tapしない。
- success、partial、offline、auth、needs-attentionの文言が異なる。
- cancel/session changeではerror SnackBarを表示しない。
- controller stateに`SyncReport`、account ID、cursor、payloadを保持しない。
- widget dispose後にSnackBarやstate updateを行わない。
- local command successの既存表示はremote failure reportで失敗へ変わらない。

### security/telemetry

- eventはdataset stable ID、trigger、result種別、duration、件数、既知reason/error codeだけを含む。
- token、authorization、email、account ID、uid、cursor document ID、entity ID、mutation ID、word/note/profile payloadが含まれない。
- 禁止値を意図的に埋めたfixtureでもserializer出力に現れない。
- raw exceptionとunknown free-form reasonが出力されない。
- reportごとにcycle eventが重複せず1回だけ記録される。

## 静的確認

実装後に少なくとも次を確認する。

```text
rg -n "SyncReport" lib test
rg -n "syncSchedulerProvider|\.foreground\(" lib test
rg -n "accountId|email|token|payload|cursor|entityId|mutationId" lib/features/sync/infrastructure/telemetry test/security
rg -n "Timer|nextAttemptAt" lib/features/sync lib/app test/unit/features/sync
rg -n "Foreground sync failed|Post-migration foreground sync failed" lib
```

- 1件目ではraw reportを保持するpresentation provider/storeが0件であることを確認する。
- 2件目ではproduction callerが共通schedulerを通ることを確認する。
- 3件目は単純0件ではなく、安全なserializerが禁止fieldを出力していないことをtestと併せて確認する。
- 4件目ではTimerがretry wake-up adapterに閉じ、`nextAttemptAt`の正本がQueueであることを確認する。
- 5件目は旧raw exception logが0件を目標とする。

## 検証順序

Flutter/Dart commandはリポジトリ指示どおりsandbox外で直接実行する。

```text
flutter test test/unit/features/sync/application
flutter test test/unit/features/sync/infrastructure
flutter test test/unit/app/presentation/sync
flutter test test/widget/sync
flutter test test/security
dart run tool/check_import_boundaries.dart --baseline tool/import_boundaries/baseline.json --check
flutter analyze
flutter test
```

新規directory名は実装時の配置に合わせて実在するpathへ調整する。各Stageでfocused testを通してから次へ進み、全testは最後に実行する。既存Local-first 8のFirebase Emulator/Java 21 blockerは別の受入gateとして維持し、このPhaseのunit/widget成功だけでEmulator検証済みとは記録しない。

## スコープ外

- `SyncReport`/`DatasetSyncResult`のvariant再設計、Freezed化、JSON永続化。
- report履歴画面、同期履歴DB、第二のcheckpoint/status Store。
- outbox payload、cursor、remote entityをUIやtelemetryへ公開すること。
- OS background task、push notification、常駐service、アプリ終了後も有効なtimer。
- Queueに存在しないpull retryの永続スケジュール。
- connectivity package導入とnetwork復帰trigger全体。既存/将来のwake signalは同じschedulerへ接続する。
- analytics vendor、Sentry等の外部SDK導入。初期実装はbackend非依存portと安全なlogger adapterまでとする。
- dead-letter編集/削除/再送UI。画面では安全なwarningだけを出す。
- remote protocol、Firestore schema/rules、Drift outbox schema、conflict resolutionの変更。
- local mutation直後の全feature wake-up追加。別taskで追加しても同じscheduler APIを使用する。
- 認証切れ時の自動sign-out/reauth flow再設計。

## リスクと停止条件

- offlineを安定して識別できるFirebase/transport codeがadapter境界で取得できない場合、例外本文の新しい自由文字列判定を無制限に増やさない。既知codeを型付きadapter errorへ正規化する最小変更を先に行う。
- `DatasetSyncFailed`がretryableを返すのにQueueにpending rowがない場合は、pull failureまたはhandler契約不整合を区別する。scheduler独自の推測時刻を作らず、Queue retryはarmしない。
- retry timerがapp/session lifecycleより長く生存する、または複数provider instanceから同account timerが作られる場合はStage 4へ進まず、composition ownershipを一つに固定する。
- UIがraw error codeをそのまま翻訳・表示する形になった場合は進めない。application summaryとpresentation message mapperの境界を保つ。
- manual sync結果を既存local commandの`CommandFailed`へ書き戻す必要が生じた場合は、local-first契約違反として実装を止める。
- telemetry要件としてproduction analytics backendへの送信が必須だと判明した場合は、vendor、同意、保持期間、release環境を決める別判断が必要である。port/serializerまでは進められるがbackend導入を暗黙に選ばない。
- retry queryに新indexが必要な規模・計測結果が出た場合は、このPhaseへ無断でDB migrationを混ぜず、upgrade testを含む別sliceへ分ける。
- Local-first 8のEmulator gateが未完了であることを理由にreport consumption実装を止める必要はないが、remote安全性まで完了したとは記録しない。

## contexts更新方針

- 実装中は本planの状態、完了Stage、focused/full test結果、残件を更新する。
- 全completion criteriaと全体検証が通った時だけ`docs/refactor/phase2/6-consume-sync-report.md`を完了へ変更する。
- `docs/refactor/contexts/current.md`へmanual sync、retry ownership、telemetry port、検証結果を短く追記する。
- `docs/refactor/contexts/runtime-and-status.md`へsession/resume/manual/retry_dueからschedulerへ至るruntime flowを追記する。
- `docs/refactor/contexts/feature-map.md`へsync application report interpreter、scheduler、telemetry adapter、app-level manual controllerのownerを記録する。
- `docs/refactor/contexts/next-phase-guide.md`へ外部telemetry backend、connectivity wake、OS background、dead-letter管理UIなど意図的に残した項目だけを渡す。
- Local-first 8文書には、Phase 2-6が受け取ったmanual/report consumption範囲だけを事実ベースで反映し、未実行Emulator gateを完了にしない。

## 完了条件

- [ ] manual syncがcurrent account/epochで共通schedulerを起動し、型付きreportから表示結果を作る。
- [ ] UI/presentation stateがraw `SyncReport`、account ID、cursor、payloadを保持しない。
- [ ] 全成功、一部成功、offline、auth required、retryable、non-retryable、cancel、already-runningの表示規則がtestで固定されている。
- [ ] local command成功とremote delivery failureが別状態であり、未送信を「操作失敗」と表示しない。
- [ ] lifecycle、guest migration、manual、retryのreportが同じ安全なtelemetry portを通る。
- [ ] 部分失敗でも成功datasetの結果と件数がsummary/telemetryから失われない。
- [ ] telemetry/logがdataset、cycle duration、件数、既知reason/error codeに限定される。
- [ ] telemetry/log/UIにtoken、email、account ID、cursor、entity/mutation ID、本文、remote payload、raw exceptionが含まれない。
- [ ] retryable outbox failureだけがQueueの最早`nextAttemptAt`に従って再起動される。
- [ ] `nextAttemptAt`前のmanual/resume triggerでpending mutationを強制再送しない。
- [ ] non-retryable/dead-letter/cancelでretry timerを作らない。
- [ ] session変更とdisposeで旧account timerが停止し、競合時もSessionFenceが旧account apply/ackを防ぐ。
- [ ] Drift outboxがretry/dead-letterの唯一の永続的な正本であり、report履歴Storeを追加していない。
- [ ] focused test、security test、import-boundary check、`flutter analyze`、全`flutter test`が成功する。

## 実装単位

実装は「baseline」「stable code/report interpreter」「telemetry」「Queue-aware retry」「manual UI」「caller収束/全体検証」の順に行う。各単位は独立してreview可能にし、特にretry timerとmanual UIを同じ変更単位にしない。retryの正しさをfake clockで確定してからUIを接続し、UI不具合と時刻・session raceを同時にデバッグしない。
