# リファクタ残作業 詳細実装プラン

作成日: 2026-08-09

## 1. 目的と文書の優先順位

本書は [`remaining-work.md`](./remaining-work.md) を実行可能な変更系列へ分解するための索引兼進行管理ルールである。設計上の根拠と Gate A/B の定義は `remaining-work.md` を上位とし、本書群はそのスコープを無断で広げない。

詳細は次の三分冊に置く。

- [P0 詳細](./implementation-plan-p0.md): 境界規則、DB/wire characterization、技術 spike、挙動基準、contract freeze
- [Gate A 詳細](./implementation-plan-gate-a.md): DB/core、feature 縦スライス、routing/composition、rename、収束
- [Gate B 詳細](./implementation-plan-gate-b.md): 非同期 race、表示状態、mutation effect、guest migration、WordDetail 受入

完了判定は次の二段階を維持する。

- **Gate A:** strict な `concept.md` 構造完了
- **Gate B:** 既知の重大リスクを含む release-ready acceptance

「リファクタ完了」は Gate A、「release-ready」は Gate A と Gate B の両方が完了した時だけ宣言する。Gate C と ADR 監査は今回の対象外である。

## 2. 調査で追加確定した実装判断

`remaining-work.md` の方針をコード単位へ落とすため、次を実装 baseline とする。

| 論点 | 確定する扱い |
|---|---|
| session fence | account ID だけでは同一 account の再ログインを区別できない。pure な `SessionScopeKey(accountScope, epoch)` を app が生成し、feature の query/command/presentation entry へ値として渡す。feature は `app/session` を import しない |
| pagination identity | retry 対象を表す `PageIdentity` と、古い応答を捨てる `RequestToken` を分ける。retry は前者を維持し、後者だけ更新する。型はまず各 feature が所有し、共通化を先行しない |
| Search/Quiz account | Catalog query/bridge自体はaccount-neutralのままにする。一方、B2のVM/presentation result-set identityには `SessionScopeKey` を含め、account/epoch切替でentryをrekeyし旧completionとaccount別status projectionを破棄する |
| MyWord warning | 現行producerはwarningを生成しない。producerを捏造せず、既存`QueryData/QueryEmpty` warning contractをstate-injection widget testで到達・描画可能にする。cross-layerでは実producerがないことを明記する |
| Firebase 4件 | 現在の4ファイルは既に canonical な WordStatus internal infrastructure にある。主作業は旧 allowlist を正しい exact path へ直し、port/application への SDK 漏出を新ルールで拒否すること。無意味な再移動はしない |
| DB runtime | 第一候補は現在の `lib/core/infrastructure/database/drift/` を neutral physical runtime として保ち、feature DAO getter と feature 所有 Table 宣言だけを切り離す案。`core/database_runtime` への名称移動自体は Gate A 条件にせず、spike で必要性が出ない限り generated path churn を避ける |
| DB差分の基準 | fresh native、asset-upgrade native、fresh Web、existing Webは現時点で完全一致しない。起点間を同一化せず、各起点の変更前後で差分0を要求する |
| Sync policy | retry/backoff/fence/queue/checkpoint policy は Sync internal に残す。owner feature は pure Sync port の dataset adapter/runtime seam だけを実装し、internal policy class を import しない。具体 signature は P0 の一 handler proof で固定する |
| post-sync retry | retryable `SyncReport` はdurable schedulerを唯一のretry ownerとしUIは予定通知だけ、non-retryableかつcurrent epoch/no in-flight時だけpublic runnerを手動retryする。migrationを再実行しない |
| status mutation | `(sessionKey, word/ref)` 単位で全operationをsingle-flightにし、全controlsをdisableする。effectはopaque instance/epoch/sequence ID付きFIFO queueで失わない |
| app bridge path | Search/Quiz と Catalog の bridge はそれぞれ `lib/app/integration/catalog_search/`、`lib/app/integration/catalog_quiz/`（新規）に置く。paging/snippet/warning policy は置かない |
| WordDetail 名称順 | P2 では現行 `features/word_page/port` を作り、P3 でディレクトリ全体を `features/word_detail` へ一度だけ rename する。P2 で新旧二つの feature を作らない |
| route parse | neutral result は `lib/core/result/route_parse_result.dart`（新規）へ置く。Quiz の canonical URL は catalog wire value と positive word ID を持ち、catalog 欠落の legacy URL は別 alias route として EspJpn 互換を維持する |
| Quiz display hint | `word` は optional hint であり identity ではない。hint の不一致で parse failure にしない。「矛盾 payload」は identity field が複数供給された場合だけを指し、重複 identity source を設計しないなら該当 test も作らない |
| WordDetail retry | B7の上位受入にないprimary retryは追加しない。failure/empty/warning/status mount/invalid routeを自動化し、retryは別product decisionにする |
| Web seeder | `_importMyWordStatus` が JSON の3 status rowを skipする既存挙動を確認した。Gate A の移動で黙って修正も恒久仕様化もせず、P0 で再現と影響を記録する。修正は別 bug として scope 決定し、構造変更と同じ commit に混ぜない |

## 3. 開始点と測定方法

2026-08-09 に boundary checker を再実行した開始点は次のとおりである。

| rule | 件数 | 主な解消 package |
|---|---:|---|
| `core_no_feature` | 18 | 現checker表示の18件はA-DBで解消。P0でauth lifecycle allowlistを外すと追加10 importがdebtとして可視化され、A-SESSIONでcodeを移して0にする。rule変更をA-SESSIONまで遅らせない |
| `domain_no_framework` | 2 | A-MYWORD で Flutter annotation/import を pure Dart 化 |
| `firebase_import_allowlist` | 4 | A-FIREBASE-SEAMで現canonical WordStatus pathを許可。expanded ruleの残debtはowner移動後A-FIREBASE-ZEROで0 |
| `no_feature_cycle` | 4 | A-SEARCH と A-QUIZ で Catalog cycle を解消 |

P0 で checker の検査範囲を増やすため、総件数は一度増える可能性がある。したがって進捗は次のように測る。

1. P0-CHECKER 完了時に全ルールを固定し、`--format json` の出力を進行記録へ保存する。
2. その後は rule ごとの新規違反を禁止し、担当 slice の対象 rule を 0 にする。
3. 数値を成功扱いにする baseline は作らない。`tool/import_boundaries/baseline.json` の `violations` は常に空のままにする。
4. 最終的な唯一の合格値は全 rule 0、exit 0 である。

## 4. 実行依存グラフ

```text
P0-DECISIONS ─┬─ P0-CHECKER ───────────────────────────────┐
              ├─ P0-DB-CONTRACT ─ P0-DB-SPIKE ────────────┼─ P0-COMPOSITION-PROOF / P0-SYNC-PROOF
              ├─ P0-PUBLIC-SURFACE ────────────────────────┘
              └─ P0-BEHAVIOR

P0 exit ─┬─ A-DB ─ A-SEARCH ──────────── A-QUIZ
         │     └──────────────────────── A-SYNC（下記Firebase seamともjoin）
         ├─ A-SESSION-SEAM ─ A-FIREBASE-SEAM ─ A-SYNC
         └─ B-SCROLL（各B ownerは対応A packageの完了も待つ）

A-SEARCH/A-QUIZ/A-DB/A-SYNC ────────────────┐
A-AUTH ─────────────────────────────────────┼─ feature internal 化
A-USER ─ A-SESSION workflow収束 ────────────┘

feature internal 化
  ├─ A-FACADE ─ A-ROUTE ─ A-APP
  └────────────────────────────┘

A-APP ─ A-RENAME ─ A-DEAD ─ A-CHECKER-ZERO ─ A-FINAL

Gate B の修正は対応する Gate A owner が安定した直後に別 change set として実施し、
最終的に B-FINAL を通す。
```

P0-CHECKER、P0-DB-CONTRACT、P0-PUBLIC-SURFACE、P0-BEHAVIOR は相互に並行可能である。DB ownership決定後に二つのP0 proofを行う。P0 exit 後は A-SESSION-SEAM と A-DB1の非App filesを別workerで進められるが、両者の `lib/app/bootstrap/**` switchはApp lane統合担当が直列に行う。A-SEARCHはA-DB2のCatalog composition切替後、同じApp/Catalog integration ownerが開始し、A-FIREBASE-SEAMはsession seam後、A-SYNCはA-DBとFirebase seamの両方が完了してから開始する。DB annotationとchecker rulesも各排他laneの統合担当だけが取り込む。

## 5. 変更系列一覧

各 ID は一つの reviewable change set を表す。大きい package は分冊内の sub-ID で複数 PR に分ける。

| ID | 成果 | 前提 | Gate |
|---|---|---|---|
| P0-DECISIONS | owner、path、pure contract、session/paging identity を固定 | なし | A/B前提 |
| P0-CHECKER | D1/D3 を表現する checker rule と allow/deny fixture | P0-DECISIONS | A前提 |
| P0-DB-CONTRACT | schema/migration/native/Web/asset/wire の before oracle | P0-DECISIONS | A前提 |
| P0-DB-SPIKE | DB ownership 採用案と棄却証拠 | P0-CHECKER、P0-DB-CONTRACT | A前提 |
| P0-PUBLIC-SURFACE | 各 feature の port/entry/composition signature 表 | P0-DECISIONS | A前提 |
| P0-COMPOSITION-PROOF | framework型を公開せずapp→internalも作らないfactory/entry seamと単一DB lifecycleの実証 | P0-PUBLIC-SURFACE、P0-CHECKER、P0-DB-SPIKE | A前提 |
| P0-SYNC-PROOF | owner handlerがSync internal policyをimportしないruntime seamと採用DB lifecycleの実証 | P0-PUBLIC-SURFACE、P0-CHECKER、P0-DB-SPIKE | A前提 |
| P0-BEHAVIOR | B1〜B7 の green characterization と defect reproduction owner | P0-DECISIONS | B前提 |
| B-SCROLL | `InfinityScrollController` reset generation/retry 契約 | P0-BEHAVIOR | B共通 |
| A-DB | neutral DB runtime と owner persistence を分離 | P0-DB-SPIKE | A |
| A-SEARCH | Search port/internal + Catalog raw reader + app bridge | P0-COMPOSITION-PROOF、A-DB | A |
| A-QUIZ | Quiz port/internal + Catalog bridge、Search internal 依存除去 | A-SEARCH、A-DB | A |
| A-SESSION-SEAM | sole epoch coordinatorを最終app workflow pathへ置き、pure session scopeとSync fenceへ同じeventを配り、featureの`CurrentSession`依存をexplicit inputへ反転 | P0-PUBLIC-SURFACE | A |
| A-FIREBASE-SEAM | canonical SDK rule、wire contract、app transaction helperへの上向き依存解消。global zeroはまだ宣言しない | A-SESSION-SEAM、P0-SYNC-PROOF | A |
| A-SYNC | Sync port/internal、dataset adapter、registry、session triggerを一回で切替 | A-DB、A-SESSION-SEAM、A-FIREBASE-SEAM、P0-SYNC-PROOF | A |
| A-SESSION | auth lifecycleをapp workflowへ移し、login/logout/account-switch compositionを収束 | A-SYNC、A-AUTH、A-USER | A |
| A-CATALOG | 既存二層を D1 に適合、raw capability/composition を収束 | A-DB、A-SEARCH、A-QUIZ | A |
| A-AUTH | Auth を port/internal 化 | A-SESSION-SEAM、A-FIREBASE-SEAM | A |
| A-USER | UserProfile を port/internal 化（名称はまだ `user`） | A-DB、A-SYNC、A-SESSION-SEAM、A-FIREBASE-SEAM | A |
| A-MYWORD | MyWord を port/internal 化 | A-DB、A-SYNC、A-SESSION-SEAM、A-FIREBASE-SEAM | A |
| A-RANKING | Ranking を port/internal 化 | A-DB、A-SESSION-SEAM | A |
| A-WORDSTATUS | WordStatus を port/internal 化 | A-DB、A-SYNC、A-SESSION-SEAM、A-FIREBASE-SEAM | A |
| A-WORDDETAIL | WordDetail owner を現行 `word_page` 内で二層化 | A-CATALOG | A |
| A-FIREBASE-ZERO | 全feature SDK importをcanonical internal infrastructureへ収束しexpanded ruleを0 | A-AUTH、A-USER、A-MYWORD、A-WORDSTATUS | A |
| A-FACADE | app presentation facade 3件を owner entry/shared shellへ移す | owner feature 全て | A |
| A-ROUTE | feature-owned pure route、Quiz identity、legacy alias | A-FACADE、A-WORDDETAIL、A-QUIZ | A |
| A-APP | router/bootstrap/composition を graph/workflow のみに収束 | A-ROUTE、A-SESSION、全 feature、A-FIREBASE-ZERO | A |
| A-RENAME | `word_page`→`word_detail`、`user`→`user_profile` | A-APP | A |
| A-DEAD | unused write API、legacy CRUD、shim/export を参照0後削除 | A-RENAME | A |
| A-CHECKER-ZERO | production 全 rule 0、baseline空 | A-DEAD | A |
| A-FINAL | codegen、analyze、全 test、互換 evidence review | A-CHECKER-ZERO | A |
| B-MYWORD | B1 | A-MYWORD、A-SESSION-SEAM、B-SCROLL | B |
| B-SEARCH | B2 Search | A-SEARCH、A-SESSION-SEAM、A-FACADE、B-SCROLL | B |
| B-QUIZ-SEARCH | B2 Quiz Search | A-QUIZ、A-SESSION-SEAM、A-FACADE、B-SCROLL | B |
| B-STATUS | B3 | A-MYWORD、A-WORDSTATUS、A-FACADE | B |
| B-QUIZ-GAME | B4 | A-QUIZ、A-ROUTE | B |
| B-RANKING | B5 | A-RANKING、A-SESSION-SEAM、B-SCROLL | B |
| B-GUEST | B6 | A-FINAL | B |
| B-WORDDETAIL | B7 semantic rendererとfinal router acceptance | A-FINAL | B |
| B-FINAL | Gate B cross-layer matrix全成功後、最終HEADでA-FINAL全commandを再実行 | 全 B package、A-FINAL | B |

## 6. PR と multi-agent の運用

### メインスレッド

- 依存グラフ、decision baseline、作業予約表、boundary debt、shim 台帳を保持する。
- DB 案、public signature、例外追加、互換性差分、scope 変更を最終判断する。
- `lib/app/bootstrap/**`、`lib/app/routing/**`、`lib/router/**`、`database_provider.dart`、`tool/import_boundaries/**` の統合順を管理する。
- 各 change set の報告を実コードと test 結果に照らし、次 package を解放する。
- Gate A/B の最終コマンドを自ら統合実行する。

### サブエージェント

- 一度に一つの bounded package と明示された所有ファイルだけを担当する。
- 同じ workspace の他編集を revert せず、競合を検出したら統合担当へ返す。
- 完了報告に変更ファイル、移動元/先、追加・削除した shim、実行 command と結果、残る違反を含める。
- owner や wire/schema の新判断が必要になった時は実装で既成事実化せず、メインへ decision request を返す。

### 排他的な統合レーン

次は並行編集しない。

- DB lane: `database_provider.dart`、物理 Table、migration、generated DB
- App lane: `app/bootstrap`、`app/routing`、旧 `router`
- Rule lane: checker 本体、rules、baseline、fixture
- Shared UI lane: `infinityscroll.dart` と app facade 解消

feature 内部の実装と test は、上記共有ファイルを触らない限り並行可能である。

## 7. 変更単位の Definition of Ready / Done

### Ready

- 前提 ID が完了している。
- owner、public signature、既存 path、最終 path が一意である。
- behavior を触る場合は先行 characterization または同一 change set 内の red reproduction がある。
- DB/wire を触る場合は before oracle と stop condition がある。
- 共有ファイルの owner が一人に予約されている。

### Done

- 対象 caller が新 contract へ切替済みで、旧参照が `rg` で 0。
- 一時 shim が残る場合、削除 ID と唯一の caller が台帳化されている。
- 対象 unit/widget/cross-layer test、両 analyze が green。
- codegen 対象なら生成物を同じ change set に含め、型名と emitted SQL の差分を審査済み。
- checker JSON を記録し、新規 rule 違反がない。担当 rule は計画どおり減っている。
- schema/wire/route legacy semantics に無承認差分がない。

## 8. 検証レベル

| Level | 実行時点 | 内容 |
|---|---|---|
| V0 | P0 contract/rule | checker fixture、schema/wire snapshot、対象 pure unit test |
| V1 | 各 change set | format、対象 unit/widget test、`dart analyze`、`flutter analyze`、checker JSON |
| V2 | 縦スライス完了 | owner port から app bridge/entry までの cross-layer test、関連 feature 全 test |
| V3 | Phase exit | `flutter test` 全体、boundary debt review、shim/generated diff review |
| V4 | Gate A/B final | `remaining-work.md` 第8節の全 command と Gate B matrix |

P0 でルールを増やした後から A-CHECKER-ZERO まで global checker は既知 debt で非0になり得る。これを隠すために CI、rule、baseline を弱めない。保護 branch が全 job green を要求する場合は stacked draft branch 上で系列を組み、A-CHECKER-ZERO 後にまとめて統合する。

## 9. stop condition と rollback 境界

次の場合はその package を止め、直前の green checkpoint へ戻してメイン判断を求める。

- runtime SQL、schema version、table/index/column/constraint、DB/IndexedDB名、asset path に無承認差分が出た。
- migration後のrow数/sentinel値、account・ID対応、relation、revision/deletedAt、outbox/checkpoint値がbefore oracleと異なる。
- seed件数/asset hash/copy-once/temporary cleanup/reopen、またはnative/Web既存DB再利用が崩れる。
- Firebase path/field、`SyncDataset.stableId`、revision/tombstone/outbox/checkpoint semantics が変わった。
- Firebase document ID型、identity field値、required/optional/type、`lastMutationId`、client/server timestamp、`schemaVersion`、または`duplicate`/`superseded`/`applied`結果が変わった。
- feature→app または core→feature を解消するために広い allowlist が必要になった。
- port に Provider/Override、Drift/Firebase/GoRouter 型を公開しないと wiring できない。
- legacy route を削除しないと新 route を実装できない。
- behavior test を削除・skip・弱い期待値へ変えないと移動が通らない。
- unrelated な schema migration、sync protocol、UI refresh が必要になった。

各 rollback 単位は change set とする。DB migrationを追加しないため、通常の code revert で戻せる状態を維持する。generated code は生成元と同じ change set で戻す。

## 10. 進行記録テンプレート

各 package 完了時に次を記録する。

実装開始時に `docs/refactor-v0.2/contexts/current.md`（新規）を作り、次のblockをpackageごとに追記する。完了済みpackageの記録を上書きせず、最新のactive packageとblockerを先頭にも要約する。

```text
Package:
Commit/PR:
Owner files:
Decision changes: none / link
Tests added or moved:
Commands and results:
Boundary counts by rule:
Schema/wire/generated diff: none / reviewed link
Shims introduced:
Shims removed:
Known defects not fixed:
Next unblocked packages:
```

メインスレッドはこの記録を基にのみ package を完了扱いにし、ファイル移動だけ・test 件数だけ・checker baseline 更新だけでは完了としない。
