# Phase 2-5: Query projection と write domain を分離する実装プラン

状態: 実装未着手
作成日: 2026-08-07

## 目的

`docs/refactor/phase2/5-separate-query-projections.md` に従い、Search、Ranking、WordPage が表示のために必要とする JOIN・集約・補助情報を application query/read model として明示する。catalog / write domain entity と画面用 projection の変更理由を分離し、次の依存を解消する。

- core word Repository が Ranking feature の DataSource を注入される構造。
- Ranking の画面用 status field が `Ranking` domain entity に混在する構造。
- Search の primary item と `rankingNos` / `simpleMeanings` / `starCounts` が並行 collection として返り、同じ `wordId` で presentation が再結合する構造。
- infrastructure が `UIConsts.oneLineMeaningMaxLength` を参照し、完全な意味文字列を不可逆に切り詰める構造。
- Ranking の status JOIN / filter が現在の account scope を契約に持たない構造。

CQRS のための別 DB、別 isolate、別同期経路は導入しない。既存の Drift DB を読み取る query port と projection 型の所有者を分けることが本フェーズの目的である。

## 現状調査

### Search

現在の `SearchWordInteractor` は次の順で結果を組み立てる。

1. `IEsjWordRepository` / `IJpnEspWordRepository` / `IConjugacionsRepository` から primary item を取得する。
2. primary item の `wordId` を集める。
3. core word Repository に対して ranking、meaning、star count の bulk query を別々に実行する。
4. `SearchWordOutputData` が primary item の list と3個の `Map<int, ...>` を返す。
5. `SearchViewModel` と `SearchResults` が collection を保持し、`SearchFragment` が `wordId` でもう一度結合する。

primary query の失敗は全体 failure、3種類の補助 query の失敗は `SearchSupplementaryFailure` になる。この partial-result 契約は Phase 2-2 で導入済みなので維持する。ただし「補助 query が失敗した」と「その単語に値が存在しない」を空 map だけで区別しないよう、page-level warning と item の nullable enrichment を同じ query response にまとめる。

### Ranking

- `Ranking` は rank、ranked word、lemma、wordId、hasConj に加え、`isLearned`、`isBookmarked`、`hasNote` を持つ。
- `RankingDao.getFilteredRankingWithStatusByPage` は Ranking、PartOfSpeech、WordStatus、Conjugation を結合し、DataSource が Drift row の tuple、Repository が `Ranking` を作る。
- UI が実際に card 表示へ使うのは rank、ranked word、lemma、wordId、hasConj である。status button は `features/word_status` の account-scoped live projection を別途 watch しており、Ranking item 内の status boolean は表示の正本ではない。
- status は filter predicate には必要だが、現在の SQL は `account_id` を受け取らない。複合主キーが `{accountId, wordId}` である現在の schema では別 account の status を混ぜ得る。
- status subquery を常に `INNER JOIN` するため、status row がない語を filter 未指定時にも落とし得る。
- `FeatureTag.multiLemma` を受け取った `Set` から DAO 内で remove しており、query helper が入力 collection を変更する。

### WordPage

- `WordPageViewModel` は西和辞書、和西辞書、活用の3 UseCase を直接保持し、`WordPageState` は方向別の domain entity collection と個別 `QueryState` を持つ。
- 西和では辞書が primary data、活用が optional enrichment である。活用取得失敗は辞書を表示したまま warning として保持する Phase 2-2 の契約がある。
- full dictionary content は詳細画面の primary data であり、query 層で省略してはならない。
- status controls は `features/word_status` が current account の live projection と command state を所有する。詳細 query に status snapshot を重複保持すると stale な二つ目の正本になるため、本フェーズでは `WordDetailViewData` に含めない。
- ranking number は現画面で表示していない。未使用 field を先回りして取得せず、画面要件が追加された時に optional enrichment として query 契約へ追加する。

## 採用する設計

```text
SearchViewModel
  -> SearchQueryUseCase
  -> ISearchQueryRepository (application port)
  -> DriftSearchQueryRepository / SearchQueryDao
  -> SearchResultPage<SearchResultItem>

RankingViewModel
  -> LoadRankingsUseCase + CurrentSession
  -> IRankingQueryRepository (application port)
  -> DriftRankingQueryRepository / RankingDao
  -> RankingPage<RankingListItem>

WordPageViewModel
  -> LoadWordDetailQuery
       -> catalog dictionary / conjugation repositories
       -> WordDetailViewData

status button
  -> existing features/word_status live projection
  -> current account-scoped status
```

query contract は各 consumer feature の `application/query` が所有し、Drift 実装は同 feature の `data/query` が所有する。core domain Repository は catalog entity の取得だけを担当し、feature 固有の画面 projection を返さない。

### 共通制約

- query model は Flutter、Riverpod、Drift、Widget、UI 定数を import しない plain immutable Dart object とする。
- query model から domain command / write entity への `toEntity`、暗黙 constructor、共通 `copyWith` bridge を追加しない。
- primary field が取得できない場合は `Result.failure` とする。optional enrichment の失敗だけを warning / partial result として返す。
- nullable field は「値が存在しない / 当該方向では適用外」を表し、query 自体の失敗は response の warning で表す。失敗を `0`、空文字、`-1`、空 entity に変換しない。
- Drift row や `Tuple2` は data 層の外へ出さない。
- page / size は0始まり page と正の size に統一し、既存画面のページング挙動を変えない。命名修正だけを目的に pagination 全体を再設計しない。

## Query model と API

### Search application query

`lib/features/search/application/query/` に次を追加する。

- `SearchQuery`: query text、dictionary direction、page、size、conjugation suggestion の要否。
- `SearchResultItem`: `wordId`、`headword`、direction、`hasConjugation`、完全な `meaningText?`、`rankingNo?`、`starCount?`。
- `ConjugationSearchItem`: `wordId`、headword、matches、完全な meaning、ranking / star enrichment。既存の `SearchResultConjugacions` を screen response の外へ漏らさないための query item とする。
- `SearchResultPage`: primary items、先頭ページだけの conjugation suggestions、`hasNext`、`List<QueryIssue>`。
- `QueryIssue`: source と `AppError`。presentation の `QueryWarning` への変換は ViewModel 境界で行う。
- `ISearchQueryRepository`: 西和 / 和西の分岐を `SearchQuery` に集約し、`Future<Result<SearchResultPage>> search(SearchQuery query)` を公開する。

`meaningText` は HTML 全文そのものではなく、辞書データから意味要素を抽出してタグを除いた完全な意味テキストとする。ただし文字数では切らない。card の1行表示は `Text(maxLines: 1, overflow: TextOverflow.ellipsis)` 等の presentation 制約で行う。DB 転送量が計測上問題になる場合だけ、後続変更で `meaningMaxChars` を `SearchQuery` の明示契約として追加し、UI 定数を直接参照しない。

Search card は item 一つを受け取る API へ寄せる。並行 map lookup と `dynamic matches` は廃止し、dictionary direction / conjugation item の型で分岐する。既存の status button は `wordId` と direction から live state を取得するため、Search item に status snapshot は持たせない。

### Ranking application query

`lib/features/ranking/application/query/` に次を追加する。

- `RankingQuery`: page、size、include / exclude の PartOfSpeech、include / exclude の FeatureTag、`accountId`。
- `RankingListItem`: rank、rankedWord、lemma、wordId、hasConjugation。
- `RankingPage`: items と `hasNext`。`size + 1` 取得の判定を UseCase / repository のどちらが所有するかを一意にし、ViewModel の `take` と二重にしない。
- `IRankingQueryRepository`: `Future<Result<RankingPage>> fetchPage(RankingQuery query)` と、active caller が残る場合のみ `fetchByWordId` を公開する。

`LoadRankingsInteractor` は `CurrentSession` を注入され、`accountIdOrNull ?? guestAccountScope` を query の `accountId` に設定する。data / DAO 層は session provider を読まない。status filter は指定 account の row だけを条件に使う。

Ranking item の status boolean は削除する。status filter は query predicate、status button 表示は既存 live projection という二つの責務に分ける。filter 適用後に status が更新された場合の list 再読込契約は現行の filter effect を維持し、本フェーズで reactive JOIN stream へ変更しない。

### WordPage application query

`lib/features/word_page/application/query/` に次を追加する。

- `WordDetailQuery`: wordId、wordType、hasConjugation hint。
- sealed `WordDetailViewData`。
  - `EspJpnWordDetailViewData`: full dictionary entries、optional conjugation。
  - `JpnEspWordDetailViewData`: full dictionary entries。
- `WordDetailQueryResult`: view data と optional enrichment の `QueryIssue`。
- `ILoadWordDetailQuery` / `LoadWordDetailQuery`。

dictionary entity は読み取り専用 catalog model であり write command entity ではないため、本フェーズでは全 nested dictionary / example / idiom 型を複製しない。`WordDetailViewData` が画面単位の集約境界となり、その内側では既存 catalog entity を再利用する。将来、画面固有 field が catalog entity に追加されそうになった時は view data 側へ追加する。

primary dictionary failure は query failure、空 list は empty、conjugation failure は dictionary data を保った `QueryIssue(source: 'conjugation')` とする。`WordPageViewModel` は3 UseCase ではなく `ILoadWordDetailQuery` 一つだけに依存し、`QueryState<WordDetailViewData>` を保持する。full content を presentation まで保持する。

## Drift query 実装

### SearchQueryDao

- Search 画面用の word page query と、wordId 群に対する dictionary / conjugation / ranking enrichment を `features/search/data/query` に集約する。
- 西和 primary query、和西 primary query、活用 suggestion は既存 DAO の検索順・page offset を characterization test で固定してから移す。
- ranking は同一 word に複数 ranking row がある場合、現行どおり最小 `ranking_id` の row を採用する。
- star count は既存 headword の `<sup>(***)</sup>` 規則を query mapper の pure function として切り出して test する。
- meaning parser は意味要素をすべて plain text 化し、30文字で打ち切らない。西和の「活用 meaning 優先、辞書 meaning fallback」という優先順位を維持する。
- primary word query 成功後の enrichment は独立して error を捕捉し、失敗した source だけを `QueryIssue` にする。primary item 自体は失わない。

最初の実装では既存 DAO を内部利用してもよいが、`IEsjWordRepository` / `IJpnEspWordRepository` を画面用 bulk map API の置き場として残さない。単一 SQL 化は正しさと query count の test を分けて行える場合だけ実施し、CQRS 境界変更と SQL 最適化を同時の必須条件にしない。

### RankingDao

現在の文字列連結 SQL helper を次の条件で置き換える。

- `accountId` を必須 parameter とし、status include / exclude は `account_id = :accountId` を必ず含む。
- filter 未指定時は status row の有無で ranking item を落とさない。
- status include は account-scoped `EXISTS`、exclude は account-scoped `NOT EXISTS` を基本とする。JOIN が必要な場合も current account に絞った subquery を `LEFT JOIN` する。
- `multiLemma` は status field ではないため SQL 組み立て前に immutable copy へ分離する。caller の Set を変更しない。
- PartOfSpeech と FeatureTag の値を SQL 文字列へ直接埋め込まず Drift expression / bound variable を使用する。page / size も bound parameter または Drift `limit` を使う。
- `hasConjugation` は `EXISTS` projection として返す。
- Drift row を `RankingQueryRow` など data-private 型へ読み、repository mapper が `RankingListItem` に変換する。架空の `wordId: -1` や空 headword は作らず、必須 DB 値欠落は typed infrastructure failure とする。

DB schema と seed format は変更しないため migration は不要である。

## Domain / Repository の収束

Search と Ranking の consumer を query port へ切り替えた後、参照数を再確認して次を行う。

- `IEsjWordRepository` から `getRankingNoById`、`getRankingNosByWordIds`、`getSimpleMeaningById`、`getSimpleMeaningsByWordIds`、`getStarCountById`、`getStarCountsByWordIds` を削除する。別の active catalog caller が見つかった method は catalog 契約として残すか、caller 用 query port へ移してから削除する。
- `IJpnEspWordRepository` から画面 enrichment 用の ranking / meaning / star bulk method を削除する。
- `EsjWordRepository` constructor から `IRankingLocalDataSource` を削除し、`core/di/data/repository_di.dart` から Ranking feature の import と provider read を削除する。
- `EsjWordRepository` / `JpnEspWordRepository` から `UIConsts` import と `_convert1line` を削除する。
- `IEspRankingRepository` と `RankingRepository` は write command を持たない旧 read port なので、全 caller を `IRankingQueryRepository` へ移した後に削除する。
- `Ranking` domain entity は `RankingListItem` へ置換し、active caller が0になった時点で削除する。
- `JpnEspWord` の `isLearned`、`isBookmarked`、`hasNote` は現行 converter / caller を確認し、catalog identity に不要なら同じフェーズで削除する。status は `features/word_status` projection だけを正本にする。
- fake Repository ではなく fake query port / fake UseCase を test helper として用意し、presentation test が domain entity を画面 payload として組み立てないよう更新する。

## DI の変更

- Search: `searchWordUseCaseProvider` は core word Repository 3個ではなく `searchQueryRepositoryProvider` を注入する。
- Ranking: `rankingQueryRepositoryProvider` を追加し、`loadRankingsUseCaseProvider` は query repository と `currentSessionProvider` を注入する。
- WordPage: `loadWordDetailQueryProvider` を追加し、`wordPageViewModelProvider` は query handler 一つを注入する。
- provider factory だけが Riverpod `Ref` を使う。query repository / handler に `Ref`、provider callback、`BuildContext` を渡さない。
- `DatabaseProvider` の既存 table / DAO registration は query DAO 追加に必要な最小変更だけを行い、database lifecycle は変更しない。

## 実装手順

### 0. Baseline と field inventory を固定する

1. `flutter analyze`、全 test、import-boundary check の開始時結果を記録する。
2. Search、Ranking、WordPage の card / fragment が読む field、route callback が読む field、status controls が別途 watch する field を表形式の characterization test / plan note に固定する。
3. core word Repository の各 enrichment method、`IEspRankingRepository.getRankingList/getRankingById`、`Ranking` status field の全 caller を `rg` で再確認する。
4. Search の並び順、page offset、先頭ページだけの活用候補、meaning fallback、ranking duplicate 選択を test で固定する。
5. Ranking の include / exclude / multiLemma / pagination の現行期待値を UseCase test で固定する。ただし account 混在と status row 必須化は不具合として新契約を優先する。
6. WordPage の dictionary primary / conjugation optional、stale result 抑止、single initialization の test を維持する。

### 1. Query model と port を追加する

1. Search の `SearchQuery`、item、page、issue、repository port を追加する。
2. Ranking の `RankingQuery`、`RankingListItem`、page、repository port を追加する。
3. WordPage の query、sealed view data、result、handler port を追加する。
4. model test で collection が unmodifiable であること、必須 field に sentinel default がないこと、query model が framework / Drift を importしないことを確認する。

### 2. Ranking projection を先に切り替える

1. in-memory Drift fixture と Ranking query integration test を作る。
2. `RankingDao` を account-scoped predicate と status-row-optional query へ変更する。
3. Drift repository mapper と `IRankingQueryRepository` 実装を追加する。
4. `LoadRankingsInteractor` を query port + `CurrentSession` 依存へ変更し、page / filter input を `RankingQuery` に変換する。
5. ViewModel、`RankingResults`、Fragment、Card、fake を `RankingListItem` へ移す。
6. status button が引き続き live projection を使用し、item boolean を参照しないことを確認する。
7. active caller が0になった `Ranking`、`IEspRankingRepository`、旧 Repository / tuple DataSource API を削除する。

Ranking を先に行う理由は、Search が依存している ranking DataSource の query API と Ranking 画面用 JOIN API を分離した後で、core word Repository の依存を安全に外せるためである。

### 3. Search projection を切り替える

1. meaning parser、star parser、ranking duplicate selection を pure mapper / DAO test で実装する。
2. `DriftSearchQueryRepository` を追加し、primary failure と enrichment issue の境界を実装する。
3. `SearchWordInteractor` を query repository の薄い validation / orchestration 層へ変更する。既存 public UseCase API を一段で置換できるなら出力 DTO 群を新 page model に統合する。
4. `SearchViewModel` と `SearchResults` を item list 中心に変更し、parallel maps と ViewModel 内の `QuizlessResult` 再結合を削除する。
5. `SearchFragment` / card を typed item から描画し、presentation で1行省略する。
6. core word Repository から画面 enrichment API と Ranking DataSource dependency を削除する。
7. `UIConsts.oneLineMeaningMaxLength` が infrastructure から0参照になったことを確認する。定数自体は presentation でまだ必要なら残し、未参照なら Phase 3 の cleanup 対象とする。

### 4. WordPage projection を切り替える

1. `LoadWordDetailQuery` で direction ごとの dictionary query と optional conjugation を集約する。
2. dictionary failure、empty、conjugation warning、full content 維持の unit test を追加する。
3. `WordPageViewModel` を `ILoadWordDetailQuery` 一依存へ変更し、state を `QueryState<WordDetailViewData>` 中心にする。
4. direction ごとの Fragment は sealed subtype を exhaustive に描画する。
5. status button の provider / command path と route contract は変更しない。
6. 旧 fetch UseCase は WordPage 以外の caller を確認し、不要なら削除、別 caller があれば catalog application API として残す。

### 5. 残存 API と import を収束する

1. 旧 output DTO、parallel map、tuple projection、screen-only domain field の参照を0にする。
2. fake Repository / mock constructor / provider override を query port に合わせて更新する。
3. generated Drift file が変わる場合は通常の build runner 手順で再生成し、生成物を手編集しない。
4. import-boundary check で `core -> features/ranking` が解消し、新しい feature 間 presentation / DI 依存を追加していないことを確認する。

## テスト計画

### Search query / mapper test

- 西和と和西の primary item が正しい wordId、headword、direction、hasConjugation を持つ。
- ranking / meaning / star が同じ wordId の item に投影され、parallel map を presentation が扱わない。
- 同一 wordId に複数 ranking row がある場合は既存規則どおり最小 rankingId を選ぶ。
- conjugation meaning が存在すれば辞書 meaning より優先し、なければ辞書へ fallback する。
- 30文字を超える meaning が query result 内で切り詰められない。presentation test では card が1行 ellipsis になる。
- meaning / ranking / star の一つが失敗しても primary item は返り、該当 source の issue が一つ記録される。
- primary word query が失敗した場合は空 page ではなく `Result.failure` になる。
- page 0 だけに活用 suggestion が入り、page 1以降への append で重複しない。
- empty query validation と stale query result 抑止は現行 ViewModel test を維持する。

### Ranking query integration test

- filter 未指定で status row のない ranking item も返る。
- account A の learned/bookmarked/note filter に account B の row が混入しない。
- guest scope と authenticated account scope が別結果になる。
- include / exclude を同時指定した時に current account の rowだけで判定する。
- PartOfSpeech include / exclude、multiLemma grouping、ranking order、page offset、`size + 1` の hasNext が維持される。
- conjugation row の有無が `hasConjugation` に正しく投影される。
- input filter Set が query 実行後も変更されていない。
- null wordId / headword を sentinel に変換せず failure として扱う。
- `RankingListItem` に learned / bookmarked / hasNote field が存在しなくても filter と status button が成立する。

### WordPage query / ViewModel test

- 西和 query が full dictionary と活用を一つの `EspJpnWordDetailViewData` として返す。
- 和西 query が `JpnEspWordDetailViewData` を返す。
- primary dictionary failure は `QueryFailure`、空 list は `QueryEmpty` になる。
- conjugation failure は dictionary data を表示したまま warning となる。
- full content は query / ViewModel / Fragment 間で切り詰められない。
- provider family ごとの single initialization、再 build での重複 I/O 防止、古い応答の破棄を維持する。
- status update は detail query の再取得を必要とせず live status projection に反映される。

### Architecture / static check

実装後に少なくとも次を確認する。

```text
rg "IRankingLocalDataSource|rankingLocalDataSourceProvider" lib/core
rg "UIConsts|oneLineMeaningMaxLength" lib/core/infrastructure lib/features/*/data
rg "isLearned|isBookmarked|hasNote" lib/features/ranking/application lib/features/ranking/domain
rg "rankingNos|simpleMeanings|starCounts" lib/features/search/presentation
rg "Tuple2<RankingTableData" lib test
rg "wordId: -1|wordId \?\? -1" lib/features/ranking lib/features/search
rg "toEntity|toCommand" lib/features/search/application/query lib/features/ranking/application/query lib/features/word_page/application/query
```

最初の6検索は active code で0件を目標とする。最後の検索は query model から write model への変換が追加されていないことを確認する。

## 検証順序

Flutter / Dart command はリポジトリ指示どおり sandbox 外で直接実行する。

```text
flutter test test/unit/features/ranking
flutter test test/unit/features/search
flutter test test/unit/features/word_page
flutter test test/unit/core/infrastructure
dart run tool/check_import_boundaries.dart --baseline tool/import_boundaries/baseline.json --check
flutter analyze
flutter test
```

現時点では Search query test directory が存在しないため、実装時に `test/unit/features/search/application/query/` と `test/unit/features/search/data/query/` を追加する。Ranking の Drift integration test は `test/unit/features/ranking/data/query/`、WordPage query test は `test/unit/features/word_page/application/query/` を基準にする。対象 test を各実装単位で先に通し、全 test は最後に実行する。

## スコープ外

- CQRS 用の別 DB、read replica、materialized table、キャッシュ、isolate の導入。
- DB schema / seed JSON / sync protocol / outbox の変更。
- status command entity、word-status feature、sync handler の統合・再設計。
- Ranking status を reactive stream にする変更。現行どおり filter 再適用時に page query を実行する。
- Search SQL の性能最適化を目的とした FTS、index、query plan の全面変更。必要なら計測後の独立タスクにする。
- WordPage に現在表示していない ranking/status snapshot を追加すること。
- route URL、`WordDetailRoute.hasConj`、navigation、quiz 初期化の再設計。
- Freezed 導入、`new_ranking_view_model.dart`、`pagenation`、`wiki_esp_ranking_repository.dart` 等の rename-only cleanup。
- copy file / obsolete abstraction の削除。Phase 3 の各タスクへ残す。

## リスクと停止条件

- core word Repository の enrichment method に Search 以外の active caller が見つかった場合は一括削除しない。caller の画面所有者を特定し、対応する query port へ移すか catalog 契約として残すかを決める。
- Ranking filter の account scope 修正で既存 fixture の件数が変わる場合、旧 unscoped 挙動は互換仕様として維持しない。current account / guest scope の正しい結果を新しい基準にする。ただし product が「全 account 集約」を要求している証拠が見つかった場合は実装を止めて契約を再確認する。
- meaning の完全テキスト化で顕著なメモリ / query latency 退行が計測された場合、infrastructure から UI 定数を再参照せず、application `SearchQuery` に用途と上限を明示した snippet contract を追加する。
- WordPage view data を作るために全 nested catalog model の複製が必要になった場合は、write modelとの分離に必要な最小境界を超えているため停止し、catalog read model の ownership を再評価する。
- query implementation が application / domain から Drift、Flutter、Riverpod を import する形になった場合は境界違反として進めない。
- optional enrichment failure を空文字、0、false、空 entity だけに変換し、warning が失われる実装になった場合は次の slice へ進まない。

## contexts 更新方針

- 実装中は本 plan の状態、完了した slice、実行した test 数、未解決事項を更新する。
- 全 completion criteria と全体検証が通った時だけ `docs/refactor/phase2/5-separate-query-projections.md` を完了へ変更する。
- `docs/refactor/contexts/current.md` に query model / port の正本、core Ranking 依存解消、検証結果を短く追記する。
- `docs/refactor/contexts/core-map.md` から core word Repository の画面 enrichment / Ranking DataSource 依存を削除する。
- `docs/refactor/contexts/feature-map.md` の Search、Ranking、WordPage を application query model と data query implementation に更新する。
- `docs/refactor/contexts/next-phase-guide.md` には残した SQL 性能改善、rename、copy cleanup だけを future note として残す。

## 完了条件

- [ ] Search が `SearchResultItem` / `SearchResultPage` を使用し、presentation が primary list と enrichment map を `wordId` で再結合していない。
- [ ] Ranking が `RankingListItem` / `RankingPage` を使用し、画面用 status field を domain entity に持たない。
- [ ] WordPage が `WordDetailViewData` を query state の単位として使用し、dictionary / conjugation の primary / optional failure が区別されている。
- [ ] Ranking status filter が current account または guest scope に限定され、status row のない語を filter 未指定時に落とさない。
- [ ] core word Repository から Ranking DataSource dependency と画面用 enrichment API が除かれている。
- [ ] infrastructure が `UIConsts.oneLineMeaningMaxLength` を参照せず、full meaning が query / Repository 内で切り詰められない。
- [ ] query failure が空値や sentinel entity に変換されず、primary failure と optional issue が型で区別される。
- [ ] query model から write command / entity への暗黙変換がない。
- [ ] Search / Ranking の JOIN・projection integration test と WordPage aggregation test がある。
- [ ] DB / sync schema、route contract、status command path に意図しない変更がない。
- [ ] import-boundary check、`flutter analyze`、全 `flutter test` が成功する。

## 実装単位

実装は「baseline / field inventory」「query model / port」「Ranking account-scoped projection」「Search projection」「WordPage aggregate」「旧 API / import 収束」「全体検証」の順で進める。各単位で対象 test が成功するまで次へ進まない。特に Ranking の account scope 修正と Search の meaning 表示変更は別単位にし、データ境界の不具合と presentation の見た目の退行を同時にデバッグしない。
