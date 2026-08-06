# リファクタ全体指針

## この文書の役割

この文書は、個別タスクを実行する開発者またはLLMが、プロジェクト全体の目的と制約を短時間で把握するための共通コンテキストである。詳細な証拠は[`FLUTTER_ARCHITECTURE_REVIEW.md`](../FLUTTER_ARCHITECTURE_REVIEW.md)、文書一覧は[`index.md`](index.md)を参照する。

## 現状の評価

プロジェクトは、Feature Module、Clean Architecture、MVVM、CQRSを意図している。Repository port、Interactor、Riverpod DI、DTO分離、`Result<T>`など、維持すべき設計要素も存在する。同期はlocal-firstを意図しているが、現状はlocal/remoteを同じRepositoryやUseCaseから直接更新する経路が残り、Driftが唯一の読み書き先にはなっていない。

実態は、feature-firstの縦割りと`core`の横断レイヤが混在した、移行途中のレイヤード・モジュラーモノリスである。主な問題は次のとおり。

- `core -> feature`、domain -> Flutter、feature間循環など、依存方向が固定されていない
- 認証、DB migration、同期にデータ・セキュリティ上の重大な問題がある
- Firebase認証stream、Auth Store、User Store、Coordinatorなど状態のwriterが複数ある
- `Result`を導入しているが、誤判定や握りつぶしで失敗が伝播しない
- read modelとwrite domainが混在し、CQRSは部分的な状態に留まる
- 未使用抽象、重複、命名揺れ、大型クラスが変更コストを上げている

## 最優先原則

1. **データを守ってから構造を動かす。** Phase 0完了前に大規模な移動やrenameを始めない。
2. **単一のsource of truthを決める。** 同期対象の業務データと同期metadataはDriftだけをアプリ内の読み書き先とする。認証identityはFirebase Auth、認可はSecurity Rules/backendをauthorityとする。
3. **失敗を値として最後まで伝える。** `Result.failure`を例外と誤認せず、UIまたは呼出し元まで保持する。
4. **依存は内向きかつ一方向にする。** domainはFlutter、Riverpod、Firebase、Drift、GoRouterを知らない。
5. **featureの所有権を明示する。** 別featureの`presentation`型を共有契約として利用しない。
6. **抽象は交換点か業務境界にだけ置く。** 一対一転送interfaceや未使用Presenterを増やさない。
7. **変更前にcharacterization testを置く。** 特にmigration、同期、認証は現状挙動を確認してから直す。

## 目標アーキテクチャ

```text
lib/
├── app/
│   ├── bootstrap/           # composition root、起動処理、横断effect
│   ├── routing/             # GoRouterとpureなroute contract
│   └── session/             # CurrentSessionとアプリ全体のsession state
├── core/
│   ├── result/              # 技術非依存Result / Failure
│   ├── logging/             # redactionを含む安全なログ境界
│   └── shared/              # 本当にfeature非依存な値だけ
├── features/sync/
│   ├── application/         # SyncEngine、Queue port、SyncReport、dataset contract
│   └── infrastructure/      # Drift outbox/checkpoint実装
└── features/<feature>/
    ├── domain/              # entity、value object、業務規則、port
    ├── application/         # UseCase、command、query、orchestration
    ├── infrastructure/      # Drift adapter、feature固有sync remote adapter
    └── presentation/        # View、ViewModel、UI state
```

依存方向は次を基本とする。

```text
presentation -> application -> domain
infrastructure -------------> domain/application port
app/bootstrap --------------> 全実装を組み立てる
```

`core`は何でも置く共有フォルダではない。複数featureで本当に同じ意味と変更理由を持つ型だけを配置する。

## 認証・User・認可の境界

- AuthenticationはFirebase UID、provider、email verificationなど「誰か」を扱う。
- User Profileは表示名、設定、学習プロフィールなどアプリ固有データを扱う。
- Authorizationはrole、subscription、操作権限を扱い、最終的にはSecurity Rulesまたはbackendで強制する。
- AuthとUser Profileは別Repositoryのまま維持する。
- Firebase認証streamを認証状態の唯一のsource of truthにする。
- 編集可能User Profileは認証済みUIDでscopeしたDrift rowをsource of truthとし、FirebaseとはSyncEngine経由で同期する。
- role、subscription、entitlement、account provisioningはremote authorityのまま維持し、editable Profileのoutboxへ含めない。
- Routerや同期が必要とする統合状態は、可変Storeではなく`AppSession`として派生させる。
- 未認証表現を`null`または`SignedOut`の一種類に統一し、空IDの`AppAuth`を作らない。

## 同期設計の共通規則

- UI、ViewModel、通常UseCase、通常RepositoryはDriftだけを読み書きする。
- Firebase data accessはSyncEngine配下のfeature固有remote adapterだけに許可する。
- 業務row更新と`sync_outbox`追加を同一Drift transactionで行う。
- SyncQueueはDrift永続outboxとし、未送信状態を別のdirty flagと二重管理しない。
- 配送保証はat-least-onceとし、mutation IDとrevisionで冪等にする。
- Firebaseのserver-confirmed acknowledgment後だけoutboxをackする。
- pull checkpointは`(accountId, dataset)`で分離したserver cursorとし、remote反映と同一Drift transactionで進める。
- deleteは差分同期可能なtombstoneとして扱う。
- conflict resolutionはdatasetの性質に合わせ、共通contractとtestで固定する。
- `SyncEngine.runOnce()`はdataset別成功・失敗・skip・cancelを含む`SyncReport`を返す。
- account切替時に旧accountのcycleをcancelし、row、cursor、未送信mutationを混在させない。
- Firestore listenerはwake signalだけを発行し、直接Driftを更新しない。

## UI・状態管理の共通規則

- Widgetの`build()`は描画に限定し、DB open、fetch、navigation副作用を開始しない。
- ViewModel stateは最低限loading、data、empty、failureを区別する。
- ViewModelは別featureのView型をimportしない。
- route contractはpure Dartの値として`app/routing`へ置く。
- `Ref`を長寿命Coordinatorへ保持させず、必要なportまたはcallbackを明示的に注入する。

## エラー処理の共通規則

- `Result.runtimeType`でerror種別を判定しない。`when`、pattern matching、errorの`is`判定を使う。
- Repositoryが返す`Result`を`await`しただけで捨てない。
- domain/application failureはFirebase、Drift、Databaseなどの技術名を含めない。
- infrastructure例外はadapter境界でアプリ共通failureへ変換する。
- UI表示文言はfailure codeからpresentation層で変換する。
- best-effort処理は、必須処理との違いを型、戻り値、ログ、テストで明示する。

## テスト戦略

優先順位は次のとおり。

1. DB schema v1〜現行へのmigration fixture test
2. 業務row更新とoutbox enqueueのatomicity test
3. dataset・account別server cursorとremote反映のatomicity test
4. process kill、remote failure、retry、lease、ackのtest
5. conflict resolution、tombstone、重複deliveryの収束test
6. Sign Up、email verification、profile ensure、guest統合の結合テスト
7. `Result.failure`伝播のUseCase・ViewModel test
8. Router、deep link、browser refresh test
9. bootstrap、SyncEngine、provider lifecycle test

`test/**`をanalyzer除外から戻し、最終的にはclean checkoutのCIで`flutter analyze`と`flutter test`を完走させる。

## フェーズの進め方

- Phase 0: データ消失・機密情報・不成立フローを止血する。X
- Local-first 1〜4: Phase 0完了後、同期contract、Drift schema、SyncQueue、SyncEngineを構築する。X
- Phase 1: compositionと依存規則を固定し、今後の変更方向を限定する。
- Local-first 5〜7: Local-first基盤とPhase 1-1・1-2・1-4の完了後、status、MyWord、User Profileをdataset単位で切り替える。
- Local-first 8: 全dataset移行後に旧同期経路を削除する。
- Phase 2: applicationとpresentationを新しい境界へ合わせる。
- Phase 3: テストで挙動が固定された後に、残骸・重複・命名を整理する。

Local-firstトラックの詳細は[`local_first/index.md`](local_first/index.md)を参照する。Local-first 1〜4とPhase 1-1・1-2・1-4は並行可能だが、production dataset切替は両方の完了後に行う。その他のフェーズ内番号は推奨順序であり、各タスクの依存関係を優先する。

## 全体完了条件

- domainからFlutter、Firebase、Drift、Riverpod、GoRouterへのimportが0
- `core`から`features/**`内部型へのimportが0
- feature間の双方向依存が0
- 別featureの`presentation/**` importが0
- 認証状態とRouter/tab stateのsource of truthがそれぞれ1つ
- 同期対象データのUI/Application read/writeがDriftだけを通る
- Firebase data accessがAuth、bootstrap、sync remote adapter境界だけに存在する
- 全schema versionから現行versionへのmigration testが通る
- user-owned row、outbox、server cursorがaccount別である
- 業務rowとoutbox、remote反映とserver cursorがそれぞれatomicである
- sync cursorがaccount・dataset別で、部分失敗時に進まない
- remote failure後の再送testが通る
- process kill後にQueueを復旧できる
- tombstone、重複delivery、二端末競合が規定状態へ収束する
- 旧`SyncService`、旧sync UseCase、直接remote writerへの参照が0
- Repositoryの`Failure`が呼出し元まで失われず伝播する
- Sign Upの実処理とUI表示が一致する
- token、password、refresh tokenをログへ出す経路がない
- clean checkoutのCIでanalyzeとtestが完走する

## タスク実行時に避けること

- Phase 0の修正と広範囲renameを同じ変更へ混ぜない
- テストなしでmigrationやconflict resolutionを共通化しない
- directory移動だけで依存方向が直ったと判断しない
- 新しいglobal singletonや可変Storeで既存状態を同期しない
- application層でlocal更新後に別呼出しでoutboxへenqueueしない
- Firebase SDKのlocal cache受付をserver acknowledgmentとしてoutboxをackしない
- 同じdatasetを旧同期と新SyncEngineで同時に処理しない
- clientの現在時刻だけをremote差分cursorにしない
- 同期対象のdeleteをtombstoneなしのhard deleteだけで表現しない
- `core`へ移すことをfeature循環の標準解決策にしない
- 失敗を空配列、`null`、ログだけへ変換して成功扱いしない
