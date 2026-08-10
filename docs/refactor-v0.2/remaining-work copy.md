# `concept.md` リファクタ残作業実行計画

調査日: 2026-08-09

## 1. 調査範囲と結論

この文書は、次のものだけを根拠にした現行スナップショットである。

- `docs/refactor-v0.2/concept.md`
- 現在の `lib/`、`test/`、`tool/`、`.github/workflows/quality.yml`
- 解析、テスト、import boundary checker の実行結果

`concept.md` 以外の設計文書、既存の移行計画、ADR は読んでおらず、根拠にもしていない。特に `concept.md:396` の Accepted ADR 手順は、今回の「他のドキュメントは無視する」という調査条件により、監査対象および完了条件から明示的に置き換える。ADR の存在・内容・状態は**未確認**であり、完了済みとは扱わない。本調査では `concept.md`、現行コード、本書で固定する推奨決定を ownership の根拠とする。将来 ADR の監査・更新が必要なら、他文書を扱う権限を得た別作業にする。

結論は次のとおりである。

- Catalog、WordStatus、MyWord、WordDetail query などの主要な業務モデル変更はかなり実装済みであり、ここは作り直さない。
- 一方、`concept.md:1-6` の中心である「全 feature の `port/internal` 化」「feature 外からは port のみ」「横断処理を app workflow に置く」「route から画面内部を隠す」は未完である。
- 現行 boundary checker は 28 件で失敗している。checker がまだ表現していない feature→app、app→feature non-port、presentation facade の逆依存も残る。
- よって現在は「業務モデル移行は概ね完了、依存境界・composition・routing・公開 surface の移行は未完」であり、strict な concept 構造完了とは判定できない。
- 現行 UI/非同期処理には重大なリスクがある。ただし、現在のソースだけでは、それらがこのリファクタによって生じた回帰だとは証明できない。このため、concept 構造完了を **Gate A**、安全な release-ready 受入を **Gate B** として分ける。

## 2. 判定区分と現在の検証結果

### 判定区分

本文では次のラベルを使う。

- **[A: concept 不変条件]**: `concept.md` から直接導ける strict 構造条件。Gate A の必須条件。
- **[A: 推奨決定]**: `concept.md` の曖昧さを現行コードに即して解消する、実装前に固定すべき決定。採用後は Gate A の設計条件になるが、`concept.md` にその具体案が直接書かれているとは主張しない。
- **[P0: 技術検証]**: 現時点では断定できず、spike の証拠で選ぶ項目。
- **[B: release-ready 受入]**: concept の直接要件ではない既知リスク。構造移動前の characterization は必須だが、修正そのものは Gate A ではなく Gate B で判定する。
- **[C: 改善候補]**: 今回の Gate A/B に含めない。

D1〜D7 は全てを一括して「concept 必須」とは扱わない。各節で、直接の不変条件、推奨決定、技術検証を分けて記載する。

### 現在の検証結果

| 検証 | 調査時点の結果 | 扱い |
|---|---:|---|
| `dart analyze` | 成功 | 最終時も成功が必要 |
| `flutter analyze` | 成功 | 最終時も成功が必要 |
| `flutter test` | 427 tests 成功 | **調査時点の参考値のみ**。最終 test 件数の閾値にはしない |
| `dart run tool/check_import_boundaries.dart --check --baseline tool/import_boundaries/baseline.json` | 28 violations、exit 1 | Gate A 未達。最終的に 0、exit 0 が必須 |

境界 28 件の内訳は `core_no_feature` 18 件、`domain_no_framework` 2 件、Firebase allowlist 4 件、feature cycle 4 件である。空の基準値は `tool/import_boundaries/baseline.json:1-6`、失敗判定は `tool/check_import_boundaries.dart:20-22`、現行ルールは `tool/import_boundaries/rules.json:5-10` にある。このコマンドは CI に既に組み込まれている (`.github/workflows/quality.yml:16-18`)。baseline を増やして成功扱いにしてはならない。

別途、生成物を除いた import の snapshot scan では、feature→app 55 件、app→feature top-level port 以外 92 件、core→feature 28 件が再現されている。これは checker の「28 violations」とは異なる走査・分類の**非 gating 参考値**である。実装中に件数は変わるため、最終判定には使わず、P0 で追加する正式ルールの 0 件だけを Gate A に使う。代表例は次のとおりである。

- core→feature: `lib/core/di/data/data_di.dart:4-16`、`lib/core/infrastructure/database/drift/database_provider.dart:11-28`
- feature→app: `lib/features/my_word/di/data_di.dart:2-4`、`lib/features/my_word/di/view_model_di.dart:1-6`
- app→feature internal/non-port: `lib/app/bootstrap/catalog_composition.dart:3-21`、`lib/app/bootstrap/sync_composition.dart:4-11`
- app presentation facade: `lib/app/presentation/search_card.dart:1-2`、`lib/app/presentation/search_view_models.dart:1-2`、`lib/app/presentation/word_status_buttons.dart:1-75`
- router→presentation: `lib/router/router.dart:6-10`、`lib/router/study.dart:4-6`、`lib/router/word_detail.dart:4-8`

行番号はこの調査時点のものであり、実装により移動する。

## 3. 完了済み: やり直さない項目

以下は `concept.md` の目的に沿う実装が現行ソースに存在する。境界移動時に公開面を整える必要はあるが、別モデルとして再設計しない。

| 完了済みの内容 | 現行の根拠 | 残る注意 |
|---|---|---|
| `CatalogId` と stable wire value | `lib/features/catalog/port/catalog_id.dart:1-20` | serialization は enum 名でなく `wireValue` を使う |
| `CatalogWordRef` | `lib/features/catalog/port/catalog_word_ref.dart:3-22` | feature 間の辞書語 identity として継続利用する |
| Catalog/Conjugation Reader port | `lib/features/catalog/port/catalog_reader.dart:5-7`、`lib/features/catalog/port/conjugation_reader.dart:5-9` | consumer はこの種の provider-neutral port を使う |
| Catalog の業務 entity を Catalog 内部へ移管 | `lib/features/catalog/internal/domain/word/esp_jpn_word.dart:3-27`、`lib/features/catalog/internal/domain/word/jpn_esp_word.dart:1-19` | core へ戻さない |
| 辞書詳細の sealed variant | `lib/features/catalog/port/model/catalog_entry_detail.dart:5-52` | 巨大 nullable entity へ統合し直さない |
| Quiz 所有の候補取得契約 | `lib/features/quiz/application/candidate_search/quiz_candidate_source.dart:1-8` | top-level port 化と adapter 配置/cycle は未完 |
| 辞書 WordStatus の論理モデル統合 | `lib/features/word_status/domain/word_status.dart:3-17` | 方向別 persistence/sync は維持する |
| 方向別 WordStatus adapter | `lib/features/word_status/internal/infrastructure/jpn_esp/jpn_esp_dictionary_word_status_adapter.dart:16-95`、`lib/features/word_status/internal/infrastructure/esp_jpn/esp_jpn_dictionary_word_status_adapter.dart` | DB/Firebase/SyncDataset を統合しない |
| Catalog 語と MyWord の分離 | `lib/features/my_word/domain/entity/my_word.dart:4-15` | `MyWord` に辞書語を再統合しない |
| MyWord と MyWordStatus の一覧 projection | `lib/features/my_word/application/query/my_word_item_projection.dart:5-17`、`lib/features/my_word/data/query/drift_my_word_item_query_repository.dart:7-37` | write model ではなく read projection のままにする |
| WordDetail route から `hasConj` を除去 | `lib/app/routing/contracts/word_detail_route.dart:8-60`、`test/unit/app/routing/contracts/route_contract_test.dart:9-80` | 詳細取得後に Catalog が能力判定する |
| WordDetail の query/route 契約レベルの aggregation | `lib/features/word_page/application/query/load_word_detail_query.dart:13-85`、`lib/features/word_page/application/query/word_detail_query_result.dart:4-9`、`test/unit/features/word_page/application/query/load_word_detail_query_test.dart:20-116` | **完了は query/route 契約レベルに限定する。** UI の全状態受入は不足しており Gate B で扱う |
| Ranking の read-only projection | `lib/features/ranking/data/data_source/local/ranking_dao.dart:13-23,47-112`、`lib/features/ranking/data/query/drift_ranking_query_repository.dart:10-60` | 他 feature の table へ write API を追加しない |

## 4. 実装前に固定する不変条件・推奨決定

### D1. `port/internal` と framework 例外

**[A: concept 不変条件]**

- 全 feature は top-level `port/` と `internal/` の二層にする (`concept.md:1-6,41-87`)。
- feature 外からは `features/<feature>/port/**` のみを参照する。
- internal domain entity を外部公開せず、Command/Query/Result/Event/ID の port DTO に写像する。
- route は feature port から公開し、app router は presentation 実装を直接 import しない。

**[A: 推奨決定]**

公開面を次のように限定する。

```text
features/<feature>/
├─ port/
│  ├─ model/                  # pure Dart DTO / ID / Event
│  ├─ command.dart            # pure Dart
│  ├─ query.dart              # pure Dart
│  ├─ reader.dart             # pure Dart interface
│  ├─ route.dart              # pure Dart route DTO / serialization
│  ├─ composition.dart        # pure Dart interface/factory only
│  └─ presentation_entry.dart # Flutter型を許す唯一の明示的UI入口
└─ internal/
   ├─ application/
   ├─ domain/
   ├─ infrastructure/
   ├─ presentation/
   └─ di/
```

- business port、model、Command、Query、Result、Event、Reader、route DTO は pure Dart とし、Flutter、Riverpod、Firebase、Drift、GoRouter を import しない。
- `port/presentation_entry.dart` 相当の明示ファイルだけは `Widget`/`WidgetBuilder` 等の Flutter 型を限定許可する。business DTO と Riverpod Provider/Override を同じ library から公開しない。
- `port/composition.dart` の公開 interface/factory は pure Dart の入力・出力だけを持つ。同一 feature の internal factory 実装を呼ぶ場合も、公開 signature に framework 型を漏らさない。
- Riverpod の `Provider`/`Override`、Firebase/Drift instance の wiring は feature internal または app composition に置く。port から export しない。
- 同一 feature の `port/composition.dart`→internal factory、および `port/presentation_entry.dart`→internal presentation のみを、ファイル名と方向を限定した facade 例外にする。
- test は public contract test と同一 feature white-box test を区別し、本番 `lib/` の例外を広げない。

checker と Gate A もこの例外規則をそのまま使い、「port 全体は framework 可」のような広い allowlist は作らない。

### D2. consumer-owned port、Search/Quiz の ownership、cycle 解消

**[A: concept 不変条件]**

`concept.md:158-175` に従い、Quiz/Search が必要とする契約は consumer が所有し、Catalog の Quiz/Search 直接依存をなくす。横断 mapping/orchestration は app 側で合成する。

**[A: 推奨決定]**

```text
Search port ── app catalog_search bridge ── Catalog raw-capability port
Quiz port   ── app catalog_quiz bridge   ── Catalog raw-capability port
```

- `QuizCandidateSource` を `features/quiz/port/`、Search source を `features/search/port/` に置く。
- Catalog port は SQL、Riverpod、Search/Quiz DTO を知らない provider-neutral な raw capability を公開する。例は raw catalog hit、辞書 entry、conjugation、ranking metadata の読み取りである。
- **Search が** query interpretation、direction、paging、snippet、enrichment、partial-failure/warning semantics、Search result DTO を所有する。
- **Quiz が** candidate query/page/result、Quiz 固有 filtering/enrichment/failure semantics を所有する。
- app bridge は pure DTO mapping と複数 port の呼び出し順だけを担当し、Search/Quiz の paging、snippet、warning policy を吸収しない。
- consumer-owned port を実装する「Catalog-backed adapter」は app workflow/integration に置く。Catalog internal は Search/Quiz を import しない。
- 現在 Catalog integration 配下にある SQL/paging/enrichment ロジックは、owner を判別して Catalog raw reader または Search/Quiz internal へ移植し、再実装しない。

Search/Quiz は「port を作る作業」と「bridge を移す作業」を別フェーズに分断せず、各 feature の縦スライス内で同時に切り替える。

### D3. DB runtime と feature persistence

**[P0: 技術検証]**

DB の最終配置はまだ確定しない。現行 DAO は `DatabaseAccessor<DatabaseProvider>` と generated row/mixin に依存する。例は `lib/features/catalog/internal/infrastructure/drift/dao/esp_jpn/esp_jpn_word_dao.dart:1-12`、`lib/features/my_word/data/data_source/local/drift_my_word_dao.dart:1-17`、`lib/features/ranking/data/data_source/local/ranking_dao.dart:19-23` である。具体 `AppDatabase` を app 所有に移すだけでは、feature DAO→app の上向き依存を作る。

P0 spike では少なくとも次を比較する。

1. **第一候補:** neutral な `core/database_runtime` に具体 DB、物理 schema、executor/connection、v1〜v7 migration を残す。feature は業務 DAO/repository/mapper を所有し、neutral DB accessor/generated row を internal adapter で包む。core は feature を import しない。
2. Table/accessor を feature internal に分け、neutral runtime が登録 descriptor を受け取る構成。Drift generator が静的列挙と既存 migration を保てるか検証する。
3. app に具体 DB/schema registration を置く構成。feature→app が発生せず、公開 pure factory だけで注入できることを spike が実証した場合にのみ採用候補にする。

app-owned DB/schema registration は推奨確定ではない。採用する場合も、単一 app database composition file→feature schema adapter の最小例外を checker fixture と decision log で正当化し、business DAO/repository/entity への app→internal 許可に広げない。core に feature import を残す案も恒久解にしない。

spike の選択条件は次である。

- core→feature 0、feature→app 0 を満たす。
- native SQLite と Web IndexedDB が既存データを再利用できる。
- runtime SQL schema と wire semantics の差分が 0。
- generated file の path 変更は許容するが、generated Dart 型名と emitted SQL の変化を審査し、adapter/test への影響を明示する。
- DB schema/version 変更を伴わない。

### D4. route owner と純粋な route contract

**[A: concept 不変条件]**

route は画面 feature の port から公開し、app は route graph を組み立てるだけにする (`concept.md:5-6`)。route DTO は D1 に従う pure Dart である。

**[A: 推奨決定]**

- Catalog は `CatalogWordRef` を所有するだけとする。
- WordDetail route/entry は `features/word_detail/port/`、Quiz route/entry は `features/quiz/port/`、その他の画面も各 user feature port が所有する。
- `RouteParseResult` は feature→app 依存を作らない pure neutral location、推奨は `core/result/route_parse_result.dart` 相当に置く。
- `app/routing` は各 route/entry を組み立て、redirect/graph/invalid-route presentation を担当する。旧 `lib/router/` は収束後に削除する。

`concept.md:67` の `catalog_route.dart` 例と `concept.md:81,362-370` の独立 WordDetail 所有には曖昧さがある。本計画では後者と現行型に合わせ、WordDetail route は WordDetail owner と決定する。

**[A: 推奨決定 — 新しい境界から導出] Quiz route identity**

これは `concept.md` に直接明記された項目ではなく、`CatalogWordRef` と純粋 route 境界から導く追加決定である。現行 `QuizGameRoute` は raw `int wordId` と必須表示文字列しか持たない (`lib/app/routing/contracts/quiz_game_route.dart:3-29`)。次へ変更する。

- identity は `CatalogWordRef`。
- URL serialization は enum 名でなく `CatalogId.wireValue` (`lib/features/catalog/port/catalog_id.dart:1-20`) と positive `wordId` を使う。
- catalog parameter がない legacy Quiz URL は、現在の Quiz 能力に合わせ `CatalogId.espJpnMain` として互換 parse する。
- `CatalogId.jpnEspMain` が明示された Quiz URL は、未対応能力を暗黙変換せず parse failure とする。
- `word` 文字列は optional display hint とし、identity や取得成功条件に使わない。
- unknown catalog、非正整数、矛盾 payload、legacy/new URL を contract test で固定する。

### D5. Sync engine と app workflow

**[A: concept 不変条件]**

Sync は独立した横断基盤、session lifecycle/guest migration/sync trigger は app workflow とする (`concept.md:16,20-26,41-57`)。feature orchestration を core に置かない。

**[A: 推奨決定]**

- `features/sync/port` は pure な `SyncDataset`、`SyncContext`、`DatasetSyncHandler`、outbox/cursor/checkpoint、cancellation/session fence、result/event を公開する。
- engine、policy、retry scheduler、infrastructure は `features/sync/internal` に置く。
- MyWord/UserProfile/WordStatus は Sync port を実装する internal adapter を持ち、app registry が公開 composition factory 経由で登録する。
- Sync engine は個別 feature を import しない。
- `session_lifecycle`、`guest_migration`、`sync_trigger` は `app/workflows/` に置く。trigger だけを app に置き、Sync engine 自体は Sync feature に残す。
- feature use case は app の `CurrentSession` を import せず、command/query input に account ID を含めるか、consumer-owned pure `AccountContextReader` を注入する。

Sync の構造移行は Phase P1 の一項目だけで完結させ、後の generic feature 移行で同じ移動を繰り返さない。

### D6. presentation owner と active app facade

**[A: 推奨決定]**

`lib/app/presentation/` の次の三つは一時 facade ではなく現在も利用中であり、独立して解消する。

- `search_card.dart` は Quiz が Search internal Widget を使う export (`lib/features/quiz/presentation/view/quiz_search_fragment.dart:4`)。
- `search_view_models.dart` は WordDetail が Search provider/query state を読む export (`lib/features/word_page/presentation/view/esp_jpn/conjugacion_fragment.dart:3,24`)。
- `word_status_buttons.dart` は Search/Quiz/Ranking/WordDetail から MyWord/WordStatus internal provider と UI を合成する (`lib/app/presentation/word_status_buttons.dart:1-75`)。

owner を次で固定する。

- Search/Quiz の両方で使う純粋な表示 card は、feature DTO/provider を受け取らない `core/ui` の shared Flutter UI とする。Search/Quiz internal がそれぞれ pure display input と callbacks に写像する。
- WordDetail の conjugation highlight/query は Search VM を購読せず、`WordDetailPresentationInput` 相当の表示入力または WordDetail 内の local state とする。route identity には混ぜない。
- 辞書語の status UI entry は WordStatus の `port/presentation_entry.dart`、MyWord 固有 status UI entry は MyWord の同等入口が所有する。
- feature 非依存の icon/button row だけが残るなら `core/ui`、status state、command、effect listener は各 owner feature internal に置く。
- app はこれら Widget/provider の facade を持たず、route graph と workflow composition に専念する。

### D7. 名称と persistence/sync 不変条件

**[A: 推奨決定] 名称**

`concept.md:89` は `word_detail` または `entry_detail` と曖昧だが、feature 一覧と責務説明 (`concept.md:11,22,81,362-370`) および現行 public 型に合わせ、`word_page`→`word_detail` とする。`user`→`user_profile` とし、Auth と UserProfile は分離したままにする。rename は P3 で一度だけ行う。

**[A: concept 不変条件] persistence/sync**

`concept.md:268-276,392-408` に従い、今回の構造変更で DB migration と同期 protocol 変更を同時に行わない。次を凍結する。

- schema version 7 (`lib/core/infrastructure/database/drift/database_provider.dart:101-102`)
- native DB file 名 `kotobank.db` (`lib/core/shared/consts/enviroment.dart:3`) と application support directory 配下の既存 path/copy behavior (`lib/core/infrastructure/database/drift/database_provider.dart:539-585`)
- Web IndexedDB 名 `my_dic_db` と既存 Wasm/IndexedDB open behavior (`lib/core/infrastructure/database/drift/database_provider.dart:539-550`、`lib/core/infrastructure/database/drift/_WEB/web_executor.dart:5-9`)
- prepackaged database/seed asset 名・path と seeding: `assets/kotobank.db`、`assets/mydic.db`、`assets/es_en_conjugacions.db`、`assets/db_for_web/kotobank.json.gz`、`assets/db_for_web/es_en_conjugacions.json.gz` (`pubspec.yaml:53-61`、`lib/core/shared/consts/enviroment.dart:9-12`)
- table/index/column 名、column order が意味を持つ処理、SQLite affinity、nullable、default、CHECK、FK、ON DELETE、複合 PK の列順序
- fresh create と v1〜v7 の全 migration path、seed の idempotency、row/account/revision/deletedAt/outbox/checkpoint semantics (`lib/core/infrastructure/database/drift/database_provider.dart:111-370,374-478`)
- native SQLite と Web IndexedDB の既存ユーザーデータ再利用
- Firebase collection/document/field/path と timestamp/revision/tombstone semantics
- `SyncDataset.stableId` (`lib/core/shared/enums/sync_dataset.dart:4-19`)

`test/unit/features/my_word/my_word_schema_sync_contract_test.dart:11-59` は一部を固定しているが十分ではない。最終条件は「generated diff 0」ではなく、**runtime SQL schema と wire semantics の差分 0** である。generated path の移動は許容し、generated 型名と emitted SQL はレビュー対象にする。

## 5. Gate A 残作業: 依存順の Phase P0〜P3

### Phase P0 — 境界規則、互換契約、技術 spike、characterization

#### P0-1. Gate と scope replacement を固定する **[A: 推奨決定]**

- **目的:** ADR 未確認や Gate B の不具合修正を、concept 完了済みと混同しない。
- **具体作業:** Gate A/B/C の判定を実装チケットに付け、`concept.md:396` の ADR 手順は今回の他文書禁止により本書の decision baseline で置換したと明記する。ADR は未確認のまま対象外に残す。
- **主な対象:** `docs/refactor-v0.2/concept.md:392-408` と本書第 2・4 節。
- **完了条件:** 各タスクが A不変条件/A推奨/P0検証/B/C のいずれかを持ち、ADR を読まずに Accepted/完了とする記述がない。

#### P0-2. pure port と framework 例外を checker 仕様にする **[A: concept 不変条件 + 推奨決定]**

- **目的:** 移動後に Riverpod/Flutter 型が business port へ漏れることを防ぐ。
- **具体作業:** D1 のルールを checker fixture test と rules に追加する。`port/presentation_entry.dart` の Flutter 型、pure `port/composition.dart` の同一 feature factory bridge だけを限定許可し、Provider/Override、Flutter route、Firebase/Drift DTO の port 漏出を拒否する。DB 例外は spike 前に追加しない。
- **主な対象:** `tool/check_import_boundaries.dart:20-387`、`tool/import_boundaries/rules.json:1-12`、`test/tool/import_boundaries/check_import_boundaries_test.dart`。
- **完了条件:** 許可/禁止の fixture が揃い、規則が D1 と同じ。baseline は空。実コードの違反は各縦スライスで減らし、P3 で 0 にする。

#### P0-3. DB/wire characterization と DB ownership spike を完了する **[P0: 技術検証 + A: concept 不変条件]**

- **目的:** core import 解消で既存 native/Web データを別 DB として開いたり、migration/schema を変えたりしない。
- **具体作業:** D7 の全凍結対象について schema snapshot/PRAGMA、migration fixture、native file reuse、Web IndexedDB reuse、asset seed、Firebase/Sync wire contract test を追加する。その上で D3 の3案を最小実装し、generated dependency graph と runtime SQL を比較する。採用案と不採用理由を本書または source test に残す。
- **主な対象:** `lib/core/infrastructure/database/drift/database_provider.dart:56-585`、`lib/core/shared/consts/enviroment.dart:1-12`、`lib/core/infrastructure/database/drift/_WEB/web_executor.dart:5-9`、feature DAO/Table、schema/sync contract tests。
- **完了条件:** D3 の配置案が証拠付きで一つに決まる。fresh/v1〜v7/native/Web の既存データが同一 DB として開く。runtime SQL schema/wire semantics 差分 0。app DB 例外を使うなら feature→app 0 を実証する限定 checker test がある。

#### P0-4. Gate B の挙動を構造移動前に characterize する **[B: release-ready 受入の前提]**

- **目的:** 既存の欠落と構造移動で生じた回帰を区別できるようにする。
- **具体作業:** 第 6 節の各状態遷移・非同期順序を最小 unit/widget/integration harness で再現し、現在の結果を記録する。正しい既存挙動は green characterization test で固定する。既知不具合は、失敗再現→最小修正→acceptance green を一つの変更系列にし、壊れた期待値を恒久 test にしない。失敗 test のまま main へ merge しない。
- **主な対象:** MyWord/Search/Quiz/Ranking/WordDetail/WordStatus/guest migration の presentation/view model/provider と既存 tests。
- **完了条件:** 第 6 節の全シナリオに test owner と test level が割り当てられ、構造移動前の基準結果が残る。修正そのものは Gate A 完了条件に混ぜない。

#### P0-5. route/owner/name の推奨決定を確定する **[A: 推奨決定]**

- **目的:** directory move の途中で owner が分岐しないようにする。
- **具体作業:** D2、D4、D5、D6、D7 の owner、純粋 contract、最終名称を実装チケットへ固定する。特に Search semantics、Quiz route legacy policy、presentation facade の移動先を未決のままにしない。
- **主な対象:** 本書 D2、D4〜D7。
- **完了条件:** 全 port/adapter/route/presentation entry/composition の owner と public signature が一意である。

### Phase P1 — foundation と feature 縦スライス

#### P1-1. spike 結果に従って DB/core 境界を実装する **[A: concept 不変条件]**

- **目的:** core の database/data-DI 範囲から feature 依存を除去し、DB runtime と feature の業務 persistence を分離する。
- **具体作業:** P0-3 で採用した案だけを実装する。`core/di/data/data_di.dart` の Catalog DAO provider を Catalog composition へ移し、feature DAO/repository/mapper は owner internal に置く。物理 DB/schema/migration、native/Web connection、Web seeder は採用案に従って neutral に保ち、D7/P0-3 で凍結した DB file/IndexedDB/asset/seed/既存データ再利用の挙動を維持する。
- **主な対象:** `lib/core/infrastructure/database/drift/database_provider.dart:10-585`、`lib/core/infrastructure/database/drift/_WEB/web_executor.dart:5-11`、`lib/core/infrastructure/database/drift/_WEB/web_database_seeder.dart:18-840`、`lib/core/di/data/data_di.dart:4-70`、Catalog/MyWord/Ranking/WordStatus/Sync/UserProfile の persistence。
- **完了条件:** P1-1 対象の `core/infrastructure/database/` と `core/di/data/` から feature への依存が 0 で、該当する `core_no_feature` 18 件が 0。P0 DB/wire tests が全て greenで、runtime SQL schema/wire semantics 差分 0。auth lifecycle 等を含む global core→feature 0 は P1-5 完了後に再確認し、最終的には P2-4 で判定する。

#### P1-2. Search を port + bridge の一縦スライスで閉じる **[A: concept 不変条件 + 推奨決定]**

- **目的:** Catalog↔Search cycle を解消しながら Search semantics を Search に残す。
- **具体作業:** Search の pure Query/Result/Page/Warning/source を `search/port` に定義し、application/domain/data/presentation/DI を internal へ移す。同じ変更内で Catalog raw reader と app catalog_search bridge を作り、旧 Catalog integration の ownership を D2 に従って分割する。
- **主な対象:** `lib/features/search/`、`lib/features/catalog/internal/infrastructure/integration/search/`、`lib/app/bootstrap/catalog_composition.dart:13-21,52-97`。
- **完了条件:** Catalog→Search 0、Search 外→Search internal 0。paging/snippet/enrichment/partial failure は Search owner、app bridge は mapping/orchestration のみ。Search contract/characterization tests が green。

#### P1-3. Quiz を port + bridge の一縦スライスで閉じる **[A: concept 不変条件 + 推奨決定]**

- **目的:** Catalog↔Quiz cycle を解消し、consumer-owned port を完成させる。
- **具体作業:** `QuizCandidateSource` と candidate/query/page/result を `quiz/port` へ移し、同じ変更内で Catalog raw capability と app catalog_quiz bridge へ接続する。Quiz internal から Search internal 依存を除く。route identity の変更は P2 routing で行う。
- **主な対象:** `lib/features/quiz/application/candidate_search/quiz_candidate_source.dart:1-8`、`lib/features/catalog/internal/infrastructure/integration/quiz_candidate/`、Quiz application/DI、Catalog composition。
- **完了条件:** Catalog→Quiz 0、Quiz→Search 0、Quiz 外→Quiz internal 0。candidate paging/enrichment/failure contract tests が green。

#### P1-4. Sync port/internal と handler registry を一度だけ移行する **[A: concept 不変条件 + 推奨決定]**

- **目的:** Sync↔feature cycle と app の internal import をなくす。
- **具体作業:** D5 の pure Sync port を作り、engine/policy/infrastructure を Sync internal へ移す。各 dataset handler は owner feature internal に置き、app registry は pure composition factory 経由で登録する。session lifecycle/guest migration/sync trigger だけを app workflow へ移す。
- **主な対象:** `lib/features/sync/application/`、`lib/features/sync/infrastructure/`、`lib/app/bootstrap/sync_composition.dart:4-30`、MyWord/User/WordStatus sync adapter。
- **完了条件:** Sync engine→個別 feature 0、各 feature→Sync は `sync/port` のみ、app registry→feature internal 0。stable ID/outbox/checkpoint tests が green。この移行を P2 で繰り返さない。

#### P1-5. session/auth 対象の上向き依存を app workflow へ反転する **[A: concept 不変条件]**

- **目的:** core の feature orchestration と、session/auth 周辺の feature→app を先に解消する。
- **具体作業:** core auth lifecycle/effect を `app/workflows/session_lifecycle` へ移す。Auth/MyWord/Ranking/UserProfile/WordStatus の対象 use case へ account ID または pure consumer-owned reader を注入し、app session/provider import を除く。Firebase transaction helper も pure port + app implementation にする。
- **主な対象:** `lib/core/application/auth_lifecycle/`、`lib/core/application/effects/auth_effect_provider.dart:4-5`、`lib/app/session/`、`lib/features/my_word/di/`、`lib/features/ranking/di/usecase_di.dart:3-15`、Auth/User/WordStatus data/di。
- **完了条件:** この項目で列挙した session/auth 対象について feature→app 0、core auth workflow→feature 0。login/logout/account-switch workflow tests が green。**この段階では全 feature の global feature→app 0 を宣言しない。**

#### P1-6. Firebase SDK を owner infrastructure に閉じる **[A: concept 不変条件]**

- **目的:** Firebase/Flutter 型を port/domain/application へ漏らさず、allowlist を狭く保つ。
- **具体作業:** WordStatus 等の remote DAO/mapper を canonical internal infrastructure path に置き、Timestamp/Document 型を pure DTO へ変換する。collection/path/wire field は変更しない。
- **主な対象:** WordStatus `internal/infrastructure/*/firebase/`、MyWord/UserProfile remote adapter、`tool/import_boundaries/rules.json:5-10`。
- **完了条件:** Firebase allowlist 4 件が 0。Firebase import は限定 internal infrastructure/app SDK composition のみ。wire contract tests が green。

### Phase P2 — 残る feature、presentation facade、routing、global composition

#### P2-1. 残る feature を `port/internal` に閉じる **[A: concept 不変条件]**

- **目的:** P1 で済ませた Search/Quiz/Sync 以外の public surface を統一する。
- **具体作業:** Auth、UserProfile、MyWord、WordDetail、WordStatus、Ranking を D1 の二層へ移す。pure port DTO/factory と限定 presentation entry を先に作り、caller を切り替えてから旧 path を削除する。Catalog の既存 port/internal も D1 の pure/framework rule に合わせる。
- **主な対象:** `lib/features/auth/`、`user/`、`my_word/`、`word_page/`、`word_status/`、`ranking/`、`catalog/`。
- **完了条件:** 全 feature が top-level `port/internal` のみ。feature 外→internal/non-port 0。business port framework import 0。

#### P2-2. active app presentation facade を解消する **[A: 推奨決定]**

- **目的:** app→feature internal と feature→app の presentation cycle をなくし、UI owner を明確にする。
- **具体作業:** D6 に従い、共有純 card/button shell を `core/ui`、Search/Quiz wrapper を各 internal、辞書 status entry を WordStatus port、MyWord status entry を MyWord port へ移す。WordDetail conjugation から Search provider 購読を除き、表示入力/local state に置換する。全参照切替後に app facade 三ファイルを削除する。
- **主な対象:** `lib/app/presentation/search_card.dart:1-2`、`lib/app/presentation/search_view_models.dart:1-2`、`lib/app/presentation/word_status_buttons.dart:1-75`、`lib/features/word_page/presentation/view/esp_jpn/conjugacion_fragment.dart:1-46` と全 caller。
- **完了条件:** 三 facade への参照 0、feature→`app/presentation` 0。WordDetail→Search VM/provider 0。shared UI は feature DTO/provider を import しない。status effect listener は owner feature にある。

#### P2-3. feature-owned route と Quiz identity を移行する **[A: concept 不変条件 + 推奨決定]**

- **目的:** route DTO を pure にし、app router を graph assembly に限定する。
- **具体作業:** D4 に従い route/parse/presentation entry を各 feature port へ移す。neutral `RouteParseResult` を先に作る。`QuizGameRoute` を `CatalogWordRef` + optional display hint に変え、`wireValue`、legacy catalog欠落、JpnEsp拒否を実装する。WordDetail の既存 legacy compatibility と `hasConj` 非依存を維持する。
- **主な対象:** `lib/app/routing/contracts/quiz_game_route.dart:1-31`、`lib/app/routing/contracts/word_detail_route.dart:1-60`、`lib/app/routing/contracts/route_parse_result.dart`、`test/unit/app/routing/contracts/route_contract_test.dart:9-103`、各 route caller。
- **完了条件:** route DTO は pure Dart。Quiz public constructor/field に raw identity-only `wordId` がなく、全 parse matrix が green。feature port→app routing import 0。

#### P2-4. app routing/composition を graph のみに収束する **[A: concept 不変条件]**

- **目的:** P1/P2 の局所解消を global dependency 0 へ収束させる。
- **具体作業:** `lib/router/` を `app/routing` に統合し、feature presentation 直接 import を feature presentation entry に切り替える。Catalog/Sync/WordStatus/guest migration composition も pure feature factory/port のみを使う。P0 DB spike が実証した限定例外以外の app→internal を除く。
- **主な対象:** `lib/router/router.dart:1-259`、`lib/router/study.dart:1-95`、`lib/router/word_detail.dart:1-34`、`lib/app/bootstrap/`、`lib/app/routing/`。
- **完了条件:** global feature→app 0、core→feature 0、app→feature internal/non-port 0（P0で実証したDB限定例外がある場合はその一ファイルのみ）。router→internal presentation 0。route/auth redirect/composition integration tests が green。

### Phase P3 — rename、dead API/shim 収束、CI zero

#### P3-1. 最終名称へ一度だけ rename する **[A: 推奨決定]**

- **目的:** dependency 移行と rename を分離する。
- **具体作業:** `features/word_page`→`features/word_detail`、`features/user`→`features/user_profile` とし、`WordPage*` 名も意味が同じ範囲で `WordDetail*` にそろえる。空の旧方向別 WordStatus directory を参照 0 後に削除する。
- **主な対象:** `lib/features/word_page/`、`lib/features/user/`、`lib/features/esp_jpn_word_status/`、`lib/features/jpn_esp_word_status/` と tests/imports。
- **完了条件:** 旧 path import 0。意図した legacy URL key 以外の旧名称がない。生成物を再生成済み。

#### P3-2. 未使用 write/legacy CRUD と移行 shim を削除する **[A: 推奨決定]**

- **目的:** read-only Catalog と revision/outbox-aware MyWord の境界を、未使用 API から再び破られないようにする。
- **具体作業:** `rg` と analyzer で production・test・generated code の参照 0 を確認したものだけ削除する。Catalog は全 DAO の write method を棚卸しする。候補は `insertWord/updateWord/deleteWord` (`lib/features/catalog/internal/infrastructure/drift/dao/esp_jpn/esp_jpn_word_dao.dart:17-24` と JpnEsp 同等)、`insertConjugation/updateConjugation/deleteConjugation` (`lib/features/catalog/internal/infrastructure/drift/dao/esp_jpn/conjugation_dao.dart:237-247`)、Example/Idiom/PartOfSpeechList/Supplement DAO の `insert/update/delete` (`lib/features/catalog/internal/infrastructure/drift/dao/esp_jpn/example_dao.dart:24-31`、`lib/features/catalog/internal/infrastructure/drift/dao/esp_jpn/idiom_dao.dart:23-30`、`lib/features/catalog/internal/infrastructure/drift/dao/esp_jpn/part_of_speech_list_dao.dart:25-32`、`lib/features/catalog/internal/infrastructure/drift/dao/esp_jpn/supplement_dao.dart:25-35`) である。MyWord は local source の旧 `insertMyWord/deleteMyword/updateMyWord/getMyWordsAfter/watchMyWordIdsAfter` (`lib/features/my_word/data/data_source/local/i_my_word_local_data_source.dart:13-23`) を候補にする。MyWord の現行 repository が使う revision/tombstone API (`lib/features/my_word/data/repository_impl/my_word_repository.dart:89-204`) は削除しない。
- **主な対象:** 上記 API、旧 re-export/provider alias、compatibility shim、対応 generated accessor。
- **完了条件:** 各削除 API の参照 0 証拠がある。Catalog に公開 write API 0。MyWord create/update/delete/outbox/tombstone tests は green。wire/schema 変更なし。

#### P3-3. boundary checker を全規則で 0 にする **[A: concept 不変条件]**

- **目的:** 最終構造を CI で再発防止する。
- **具体作業:** P0 の rules/fixtures を production 全体へ適用し、少なくとも次を検査する。
  1. feature 外→`features/<x>/port/**` 以外は禁止
  2. feature→app 禁止
  3. core→feature 禁止
  4. feature cycle 禁止
  5. business port/domain→Flutter/Riverpod/Firebase/Drift/GoRouter 禁止
  6. Flutter は `port/presentation_entry.dart` のみ限定許可
  7. `port/composition.dart` は pure interface/factory のみ。Provider/Override 禁止
  8. Firebase は canonical internal infrastructure/app SDK composition のみ
  9. DB spike で必要性が実証された例外だけを exact file/direction で許可

- **主な対象:** `tool/check_import_boundaries.dart:20-387`、`tool/import_boundaries/rules.json:1-12`、`test/tool/import_boundaries/check_import_boundaries_test.dart`、`tool/import_boundaries/baseline.json:1-6`。
- **完了条件:** 許可/禁止 fixture が D1/D3 と一致。baseline は空。実 repository の violations 0、exit 0、CI green。

#### P3-4. 全検証と compatibility 収束を行う **[A: concept 不変条件]**

- **目的:** 一時 export、生成物、route compatibility が境界の裏口にならないようにする。
- **具体作業:** deprecated export/provider alias/旧 composition path を参照 0 後に削除し、build runner、analyze、boundary、全 tests を実行する。WordDetail legacy `type` parse は外部 deep-link support 未確認のため contract test 付きで維持する。
- **主な対象:** 移行中の facade/export、`*.g.dart`、route/schema/sync tests。
- **完了条件:** Gate A DoD を全て満たし、既存シナリオを削除・弱体化していない。test 件数そのものは判定に使わない。

## 6. Gate B: release-ready 受入作業

以下は現行ソースで確認できる重大リスクだが、現在のソースだけでは refactor 起因と証明できない。したがって concept の strict 構造 DoD ではない。ただし、構造移動前の characterization を必須とし、release-ready とするなら全て修正・受入する。

### B1. MyWord 初回ロード、account fence、pagination

**現在の事実:** `MyWordFragment.initState` は load を開始せず (`lib/features/my_word/presentation/view/my_word_fragment.dart:28-32`)、`QueryInitial` は静的表示 (`:97-100`) で、`autoLoadFirstPage` を持つ list は data branch にしかない (`:109-138`)。view model は generation/account request key を持たず、await 後に無条件 append する (`lib/features/my_word/presentation/view_model/my_word_view_model.dart:22-49`)。

**受入シナリオ:** 

- 初回表示で page 0 が一度だけ load され、rebuild/auto-load 競合で二重 append しない。
- guest→account A→account B→signed-out の各切替で state/page/controller を reset し、該当 account を reload する。
- request key に account ID、query/filter、page、generation を含め、旧 account の in-flight 結果を破棄する。
- retry は失敗した同じ page を取得し、成功後も ID/row を重複 append しない。
- empty/error/stale-data/warning の各表示と retry が到達可能である。

### B2. Search/Quiz の warning、QueryEmpty、stale-data、pagination retry

**現在の事実:** Search VM は warning/previous-data failure を生成する (`lib/features/search/presentation/view_model/viewmodel.dart:50-70,86-99`) が UI は stale data だけを描画する (`lib/features/search/presentation/view/search_fragment.dart:76-92`)。Quiz も同様 (`lib/features/quiz/presentation/view_model/quiz_search_view_model.dart:41-57`、`lib/features/quiz/presentation/view/quiz_search_fragment.dart:69-81`)。

**受入シナリオ:** 

- `QueryData` と `QueryEmpty` のどちらでも warning を表示する。
- previous data を残した failure/loading は banner と retry を表示し、data を消さない。
- pagination failure の retry は同じ page/query/account key を使い、前後 page や重複 item を append しない。
- query/filter 変更後の古い応答は破棄する。

### B3. WordStatus/MyWordStatus mutation state と effect

**現在の事実:** MyWordStatus command は `pendingEffect` を生成する (`lib/features/my_word/presentation/view_model/my_word_status_command.dart:12-28,51-73`) が status toggle caller は購読しない (`lib/features/my_word/presentation/view/my_word_fragment.dart:150-156`、`lib/app/presentation/word_status_buttons.dart:36-75`)。辞書 WordStatus command も失敗 event の購読経路がない (`lib/features/word_status/presentation/dictionary_word_status_view_model.dart:71-110`)。

**受入シナリオ:** 

- submitting 中は同一操作を dedupe/disable し、異なる古い mutation の結果で新状態を上書きしない。
- success/failure effect は一度だけ表示・consume され、rebuild で再表示しない。
- dispose、route離脱、account切替後には SnackBar/effect/state update を通知しない。
- failure は表示可能な typed error を保持し、retry 後 success と区別できる。

### B4. Quiz read failure と no-data の分離

**現在の事実:** Quiz game VM は取得失敗を空 map/null に変換する (`lib/features/quiz/presentation/view_model/quiz_game_viewmodel.dart:43-69`)。provider はそれを成功として包む (`lib/features/quiz/di/view_model_di.dart:12-20`、`lib/features/quiz/di/provider_di.dart:31-35`)。

**受入シナリオ:** 

- candidate 0件、word not found、正常な conjugationなし、primary catalog failure、conjugation read failure、補助 asset failureを別状態として test する。
- infrastructure failure は empty/null success にならず error/retry へ到達する。
- 正常な conjugationなしだけは success(no-data) として Quiz 開始不可を表現する。
- retry success で stale error が残らない。

### B5. Ranking account/filter/request fence

**現在の事実:** Ranking load は await 後の generation/account/query check がなく (`lib/features/ranking/presentation/view_model/new_ranking_view_model.dart:27-79`)、filter reset と競合できる (`:107-119,144-165`)。

**受入シナリオ:** 

- request key に account ID、filter、page、generation を含める。
- guest→A→B→signed-out と filter変更で reset/reload し、旧 in-flight を破棄する。
- page 0 の二重 append、応答逆転、retry の page ずれ、filter変更前 item の混入がない。
- dispose 後に state を更新しない。

### B6. guest migration failure UX と session safety

**現在の事実:** prompt は例外を catch して記録するだけでユーザー通知がない (`lib/app/guest_migration/presentation/guest_migration_prompt.dart:45-99`)。

**受入シナリオ:** 

- 実失敗は通知され、同じ安全な操作を retry できる。
- migration中に account A→B/signed-out へ変わった場合は旧 session の結果を適用せず、session-changed cancellation と実失敗を区別する。
- 二重実行、二重移行、古い completion による dialog/navigation を防ぐ。
- 成功 toast、履歴画面、進捗演出は Gate C であり、B には含めない。

### B7. WordDetail UI 全状態

query/route 契約は実装済みだが、UI 受入は別途必要である。現行 UI は活用ありの時だけ tab/FAB を作る (`lib/features/word_page/presentation/view/word_page_fragment.dart:82-101,114-144`)。partial warning は一部 view に表示される (`lib/features/word_page/presentation/view/esp_jpn/dictionary_fragment.dart:39-46`、`conjugacion_fragment.dart:52-69`) が、方向/empty/failure の組合せ全体は未確認である。

**受入シナリオ:** 

- primary detail success + conjugation partial failure で辞書本文を残し warning を表示する。
- 正常な conjugationなしでは活用 tab と Quiz FAB を表示しない。
- Esp→Jpn と Jpn→Esp を別々に描画し、Jpn→Esp に活用/Quiz UIを出さない。
- primary failure、empty、invalid/unknown route を適切な error/empty/invalid page にする。
- legacy URL の `hasConj` query があっても UI 能力判定へ影響せず、取得結果だけで決める。
- `QueryEmpty(warnings: ...)` でも warning を失わない。

## 7. 今回スコープ外の改善候補

以下は Gate A/B に含めない。

- MyWord の `hasNote` no-op を辞書 WordStatus と統合すること (`lib/app/presentation/word_status_buttons.dart:53-75`、`concept.md:335-360`)。
- Conjugation を独立 feature にすること。独立 lifecycle/UI が生まれるまでは Catalog 内能力とする (`concept.md:127-177`)。
- Catalog と MyWord を一つの write entity に統合すること。将来必要なら `library`/`my_vocabulary` read projection とする (`concept.md:293-333`)。
- WordDetail legacy `type` parameter を即時削除すること。外部 deep-link support 期間は今回未確認である。
- MyWord item stream の loading/error/null を 1px widget へ潰す表示改善 (`lib/features/my_word/presentation/view/my_word_fragment.dart:146-149`)。
- Bootstrap failure 画面へ raw exception を表示しない sanitization/telemetry 改善 (`lib/app/bootstrap/bootstrap.dart:101-116`)。
- guest migration の成功 toast、履歴/進捗 UI。
- port 化と無関係な全面 UI refresh、localization、ログ形式統一、一般 performance tuning。

## 8. Definition of Done

### Gate A — strict concept 構造完了

次の全てを満たした時、`concept.md` のコード構造リファクタを完了とする。

#### 公開面と依存

- 全 feature が top-level `port/internal` のみ。
- business port/model/Command/Query/Result/Event/route/composition interface は pure Dart。
- Flutter 型は `port/presentation_entry.dart` のみ限定許可。Riverpod Provider/Override は port にない。
- feature 外→internal/non-port 0、feature→app 0、core→feature 0、feature cycle 0。
- app は route graph/workflow/composition を担当し、active presentation facade を持たない。
- P0 DB spike が例外を必要と証明した場合だけ、exact file/direction の schema-registration 例外が fixture test 付きで存在する。それ以外の app→internal は 0。

#### owner と route

- Search/Quiz は consumer-owned port + Catalog raw capability + app bridge で閉じ、Search semantics は Search、Quiz semantics は Quiz が所有する。
- Sync engine は Sync feature、session lifecycle/guest migration/sync trigger は app workflow。
- WordDetail/Quiz 等の route DTO/entry は各 user feature port、app は graph のみ。
- Quiz route identity は `CatalogWordRef`、serialization は `CatalogId.wireValue`、legacy catalog欠落は EspJpn 互換、明示 JpnEsp は failure、display word は optional hint。
- final path は `word_detail` と `user_profile`。

#### データ互換性

- schema version 7、native DB file/path、Web IndexedDB名、asset/seeding を維持する。
- table/index/column、affinity/null/default/CHECK/FK/ON DELETE/複合PK順序に runtime 差分がない。
- fresh create と v1〜v7 migration が native/Web の既存データを再利用する。
- Firebase path/fields と `SyncDataset.stableId`、revision/tombstone/outbox/checkpoint semantics に差分がない。
- generated path 変更は許容するが、generated型名/emitted SQLを審査済み。runtime SQL schema/wire semantics 差分 0。

#### 収束と自動化

- 未使用 Catalog write API、MyWord legacy CRUD、一時 facade/export/shim は参照 0 を確認して削除済み。
- `tool/import_boundaries/baseline.json` は空。
- boundary violations 0、両 analyze 成功、boundary checker tests と全 repository tests 成功。
- 既存 scenario を削除・期待値弱体化で通していない。test の総件数は DoD に使わない。
- ADR は今回未確認・対象外のままであり、Accepted と偽って完了条件を満たさない。

### Gate B — release-ready acceptance

Gate B は第 6 節の全 scenario が自動 test で成功した時に満たす。特に次を含む。

- guest→A→B→signed-out の reset/reload、account付き request key、旧 in-flight 破棄。
- MyWord/Ranking の page 0 二重 append なし、same-page retry、重複なし。
- Search/Quiz の QueryEmpty warning、stale-data banner、pagination retry。
- WordStatus/MyWordStatus の submitting/dedup/effect once/dispose後通知なし。
- Quiz の failure/no-data 全経路分離。
- WordDetail の partial warning、活用なしUI、Jpn方向、primary failure/invalid route、legacy `hasConj` 非影響。
- guest migration の失敗通知/retry/session safety。

Gate A は Gate B の未修正を「concept 構造未完」とは数えない。一方、release-ready と宣言する場合は A と B の両方を満たす。

### 検証コマンド

path 変更で生成コードに影響する場合は先に実行する。

```powershell
dart run build_runner build --delete-conflicting-outputs
```

最終確認は次の順で全て成功させる。

```powershell
dart run tool/check_import_boundaries.dart --check --baseline tool/import_boundaries/baseline.json
dart analyze
flutter analyze
flutter test test/tool/import_boundaries/check_import_boundaries_test.dart
flutter test
```

期待結果は boundary 0 / exit 0、両 analyze 0 issues、boundary checker tests と全 repository tests 成功である。427 は調査時点の参考値であり、最終件数の下限ではない。

## 9. 実行順の要約

```text
P0: pure-port/checker規則 → DB/wire凍結と技術spike → Gate B characterization → owner決定
  ↓
P1: spikeに基づくDB/core → Search縦スライス → Quiz縦スライス → Sync一回だけ → session/auth → Firebase
  ↓
P2: 残るfeature → active app facade解消 → pure route/Quiz identity → routing/composition global zero
  ↓
P3: word_detail/user_profile rename → dead API/shim削除 → checker zero → 全検証
  ├─ Gate A: strict concept 構造完了
  └─ Gate B: 第6節のrelease-ready受入を別gateで完了
```

ディレクトリ移動から始めず、P0 で規則・DB互換契約・挙動基準を先に置く。これにより、`concept.md:392-408` が避けようとしている構造変更、DB migration、同期 protocol 変更の同時実施を防ぐ。
