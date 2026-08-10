# Gate B 詳細 — release-ready acceptance

## 1. 共通実装契約

Gate B は挙動変更である。P0 characterization と対応する Gate A owner/path が安定してから実装し、構造移動と同じPRへ無差別に混ぜない。

### 非同期request

- logical retry対象は owner固有の `PageIdentity`。
- response publish権限は `RequestToken(generation, pageIdentity, attempt)`。
- await後は `mounted && token == activeToken` が必須。
- account-scoped featureは `SessionScopeKey(accountScope, epoch)` をidentityに含める。
- Search/QuizのCatalog queryはaccount-neutralだが、VM result-set identityにはsession keyを含め、account/epoch変更で旧completionとstatus projectionを破棄する。
- page 0はreplace、後続のみstable identityでdedupe append。
- retryはlast failed `PageIdentity` を再利用し、pageを進めない。
- current result set内のpage loadは直列化する。旧generationが未完でもnew generation page 0は開始可能だが、同じgenerationでpage 0/page 1を同時に走らせない。
- failed `PageIdentity` とattemptの正本はowner VMだけに置く。shared controllerはbusiness identity/errorを知らず、未advanceのcurrent pageを機械的にtriggerする。
- publish時はawait前にcaptureしたlistへappendせず、token確認後のcurrent stateへstable identityでmergeする。

### UI effect

- command stateとone-shot effectを分ける。
- effectは一意のenvelope IDを持ち、owner entryが表示後に同じIDだけをconsumeする。
- rebuildで再表示せず、古いconsumeが新effectを消さない。
- dispose/route leave/session change後はstate/effectをpublishしない。
- account-scoped writeが既に開始済みなら、そのaccountへのwrite自体は取り消さず、新session UIへのpublishだけをfenceする。

### test level

通常の `flutter test` で実行できる次の三層を使う。

1. Unit: deferred fake/Completerで逆順completion、identity、dedupe、typed resultを検証。
2. Widget: state表示、banner、button、retry、effect once、disposeを検証。
3. Cross-layer: `test/integration/gate_b/`（新規）でProviderContainer + widget + fake/real adapterを接続する。`integration_test` packageは追加しない。

共通 harness:

- session sequence: guest→A→B→signed-out、A logout→同じA relogin
- deferred page source: requestごとに任意順でcomplete/fail可能
- effect recorder:表示/consume回数とroute disposeを記録
- fake Catalog readers/app bridge
- controllable session fence/epoch

test file予約は次で固定する。既存fileはGate Aのowner moveでfinal internal test pathへ移してからextendし、新規fileは該当ownerだけが作る。B-WORDDETAIL/B-GUESTはA-FINAL後なので、B change set内にrename追随を混ぜない。

feature implementationを直接importするunit/widget testはfinal `test/**/features/<owner>/internal/**` へ置いてsame-feature white-box例外に一致させる。`test/integration/gate_b/**` はowner port/presentation entryだけをimportし、internalを参照しない。

| ID | unit/widget owner path | cross-layer owner path |
|---|---|---|
| B-SCROLL | `test/widget/core/presentation/components/infinityscroll_test.dart` | なし |
| B-MYWORD | `test/unit/features/my_word/internal/presentation/my_word_view_model_test.dart`（新規）、`test/widget/features/my_word/internal/presentation/my_word_fragment_test.dart`（新規） | `test/integration/gate_b/my_word_presentation_test.dart` |
| B-SEARCH | `test/unit/features/search/internal/presentation/view_model/search_view_model_test.dart`、`test/widget/features/search/internal/presentation/search_fragment_test.dart`（新規） | `test/integration/gate_b/search_acceptance_test.dart` |
| B-QUIZ-SEARCH | `test/unit/features/quiz/internal/presentation/view_model/quiz_search_view_model_test.dart`、`test/widget/features/quiz/internal/presentation/quiz_search_fragment_test.dart`（新規） | `test/integration/gate_b/quiz_search_acceptance_test.dart` |
| B-STATUS | `test/unit/features/my_word/internal/presentation/status/my_word_status_command_test.dart`（新規）、`test/unit/features/word_status/internal/presentation/dictionary_status/dictionary_word_status_command_test.dart`、`test/widget/features/word_status/internal/presentation/dictionary_status_entry_test.dart`（新規） | `test/integration/gate_b/status_mutation_test.dart` |
| B-QUIZ-GAME | `test/unit/features/quiz/internal/presentation/view_model/quiz_game_viewmodel_test.dart`、`test/unit/features/quiz/internal/infrastructure/drift/drift_es_en_conjugacions_repository_test.dart`（新規）、`test/widget/features/quiz/internal/presentation/quiz_game_fragment_test.dart` | `test/integration/gate_b/quiz_game_acceptance_test.dart` |
| B-RANKING | `test/unit/features/ranking/internal/presentation/view_model/ranking_view_model_test.dart`、`test/widget/features/ranking/internal/presentation/ranking_fragment_test.dart` | `test/integration/gate_b/ranking_presentation_test.dart` |
| B-GUEST | `test/unit/app/workflows/guest_migration/migrate_guest_data_usecase_test.dart`、`test/widget/app/workflows/guest_migration/guest_migration_prompt_test.dart`（新規） | `test/integration/gate_b/guest_migration_workflow_test.dart` |
| B-WORDDETAIL | `test/unit/features/word_detail/internal/presentation/view_model/word_detail_view_model_test.dart`、`test/widget/features/word_detail/internal/presentation/word_detail_entry_test.dart` | `test/integration/gate_b/word_detail_presentation_test.dart`、`test/integration/gate_b/word_detail_router_test.dart` |

## 2. B-SCROLL — reset generation と retry page

対象は `lib/core/presentation/components/infinityscroll.dart` と既存controller testsである。

Tests first:

- load中にresetし、旧completionがnew generationのpage/hasMore/loadingを変えない
- failure後にretryすると同じzero-based pageを要求
- double retry triggerでもowner callbackは一回
- reset後にinitial pageとhasMoreが復元
- 同一generationのdouble triggerは一request
- auto initial loadは一度

実装:

1. controller内部にgenerationを持ち、load開始時tokenをcaptureする。
2. completion時にtoken不一致ならcontroller stateを変更しない。
3. page advanceはsuccess後だけ。failure時はnumeric current pageを進めずownerへ通知するが、failed `PageIdentity`/errorは保持しない。
4. `retryCurrentPage()` はowner VMの `retryFailed()` からだけ呼ばれ、current pageを機械的に再triggerする。controllerとVMの二重retry sourceを作らない。
5. `reset()` はgeneration increment、page/hasMore/error/loading resetを一操作で行う。
6. item/account/query/filter identityはcontrollerへ入れない。

完了条件:

- 上記unit/widget testがgreen。
- 既存consumerのpage conventionをzero-basedへ統一する移行手順が明記されている。
- B-MYWORD/B-SEARCH/B-QUIZ-SEARCH/B-RANKINGが同じcontroller contractを使える。
- controllerにfailed business identity/errorがなく、各owner VMだけがretry targetを保持する。

## 3. B-MYWORD — 初回load、session fence、pagination

### 現在の欠陥

- `MyWordFragment` の `QueryInitial` はlistをmountしないため、`autoLoadFirstPage` に到達せず初回load不能。
- VM/providerが `ref.read` したuse case/session scopeを保持し、account switch後も旧scopeを使い得る。
- item projectionだけ新sessionをwatchすると、旧ID一覧と新account cardが混ざる。
- request token、in-flight dedupe、mounted guard、stable ID dedupeがない。
- page 0もappendし、await前にcaptureしたprevious stateが逆順completionでlost updateを起こす。
- controllerのfailure/reset後 `hasMore` が回復しない経路がある。
- pageがVM/controllerでzero/one-basedに二重変換される。

### 変更対象

最終的には `features/my_word/internal/**` 配下となる次の現行ファイル:

- `presentation/view/my_word_fragment.dart`
- `presentation/view_model/my_word_view_model.dart`
- `presentation/ui_model/my_word_ui_model.dart`
- `di/view_model_di.dart`
- `application/usecase/my_word/load_my_word/**`
- `core/presentation/components/infinityscroll.dart` はB-SCROLLで先に修正
- MyWord presentation entryとapp session composition

### tests

Unit:

- page 0 replace / page 1 append
- 同一page in-flight dedupe
- page1 failure→同じidentity retry
- reset後の旧response、A→B、同じAの旧epoch responseを破棄
- initializing/unverified/profile-loading/failureへ入ると旧A entry/dataを即時detachし、ready/signed-outまでload 0
- dispose後completionを無視
- stable `wordId`重複なし

Widget:

- pump後page0を一度だけ要求
- initial loading/empty/error
- stale data + loading/failure banner + retry
- `QueryData(warnings)` / `QueryEmpty(warnings)` をstate injectionで描画。production warning producer追加は行わない
- scope changeでstate/controller resetとpage0 reload

Cross-layer:

- account別fake repositoryでguest→A→B→signed-out
- A logout→A reloginで旧epoch resultが出ない

### 実装

1. MyWord `PageIdentity(sessionKey, page, pageSize)` とrequest tokenを追加。
2. A-SESSION-SEAMで明示session scope入力とprovider family/entry rekeyは完了済みとし、そのcontractを利用する。intermediate stateのdetach機構や第二session providerをB-MYWORDで作り直さない。
3. listをinitial stateでもmountし、Query stateをbody/overlay/banner/warningとして分ける。
4. page0の唯一のtrigger ownerは新 `SessionScopeKey` でrekeyされたowner entryの初回mountとする。session listener、controller reset、rebuildから別途loadを起動しない。
5. page 0 replace、後続append、`wordId` dedupe。
6. last failed identityを保持し、retry成功後controllerを継続可能に戻す。
7. 全層をzero-based pageに統一。

完了条件:

- 各sessionでpage0が一度だけload。
- intermediate session stateで旧account item/projection表示とrepository callが0。
- 旧scope/epochのID、projection、stateがpublishされない。
- same-page retry後もpagination継続、duplicate 0、dispose後更新0。
- warning producerは追加しないが、Data/Empty warning rendererとstate-injection widget testはgreenにし、B1の表示到達要件を満たす。

## 4. B-SEARCH / B-QUIZ-SEARCH — query change、warning、retry

### 現在の欠陥

両VMにはgeneration guardがあるが、query更新時に旧 `QueryLoading` を保持する。直後のpage0がglobal `isLoading` で拒否され、旧responseはgeneration guardで捨てられるためloadingが永久に残り得る。Quizの既存 stale-response testはこの壊れた状態をgreen期待にしている。

さらに:

- `QueryData`/`QueryEmpty` warningがUIに出ない。
- stale loading/failureはdataだけ描画し、banner/progress/retryがない。
- pagination failureをUIから同じpageでretryできない。
- mergeにstable identity dedupeがない。
- scroll reset中の旧completionがnew controller stateを止め得る。

### 変更対象

Search:

- `search/.../presentation/view_model/viewmodel.dart`
- `search/.../presentation/ui_model/search_ui_model.dart`
- `search/.../presentation/view/search_fragment.dart`
- Search internal DI

Quiz Search:

- `quiz/.../presentation/view_model/quiz_search_view_model.dart`
- `quiz/.../presentation/ui_model/quiz_search_model.dart`
- `quiz/.../presentation/view/quiz_search_fragment.dart`
- Quiz internal DI

### identity

- Search word result: `CatalogWordRef`。conjugation suggestionは既存 `SearchConjugationMatchKey`。
- Quiz candidate: `CatalogWordRef`。
- VMの `PageIdentity` は `SessionScopeKey`、normalized query、direction/filter、page、pageSizeを持つ。Catalog gatewayへ渡すSearch/Quiz port queryからはsession fieldを除き、読み取り自体はaccount-neutralを維持する。
- normalizationは現行どおりleading/trailing whitespaceの`trim()`だけとし、case/Unicode/内部空白は変えない。Search direction/include-conjugationはtrim済みqueryからrequest開始時に一度算出したimmutable snapshot、Quiz filterは現状なし。全fieldにvalue equality/hashCodeを持たせる。

### tests

既存 Search/Quiz VM testへ:

- query Q0 request中にQ1へ変更し、両completion順を検証
- new query page0が旧loadingに拒否されない
- page0 replace、page1 append/dedupe
- warning in Data/Empty
- page1 failure→same-page retry
- primary failureとpartial warningの区別
- Quiz candidate 0件はB-QUIZ-SEARCHの`QueryEmpty`となり、B-QUIZ-GAMEを起動しない
- dispose中completion、session/epoch change後completionを非publish
- result-set generationとattempt sequenceが独立し、同identity retryだけattemptが増える
- double retryは一request、publish時のcurrent stateへmerge

Quiz既存の「query change後も古いQueryLoading」を期待するtestは、Q1 page0が開始し最終Q1 stateになる期待へ修正する。test削除だけで済ませない。

新規widget test:

- Data warning、Empty warning
- stale loading/failure bannerとdata維持
- Retry tapがfailed identityを要求
- query changeでold item混入なし

Cross-layer:

- fake app Catalog bridgeでpage0→page1 failure→retry
- query change中の旧bridge completion
- guest→A→同じA new epochでentry rekeyし、旧status projection/completion 0

### 実装

1. query changeでnew result-set generationを開始し、旧queryのloading flagを引き継がない。
2. current result-set generation内は一requestだけをactiveにし、page0/page1を直列化する。new generationのpage0はold generationのin-flight完了を待たない。
3. owner VM stateだけがlast failed identityとactive tokenを保持する。result-set generationとrequest attemptを別counterにし、shared controllerはfailed identityを保持しない。
4. Data/Empty bodyとwarning/bannerを独立描画。
5. retryはVMのfailed identityを再実行し、controllerは未advanceのcurrent pageを再triggerするだけとする。
6. token確認後のcurrent stateへstable identityでdedupe mergeする。

完了条件:

- Q1がQ0 loadingに阻害されない。
- warning/stale failure/retryがData/Empty双方で到達可能。
- old query item、duplicate、retry page advanceが0。
- dispose/session epoch後publish 0、double retry 0。

B-SEARCHとB-QUIZ-SEARCHはB-SCROLL完了後に別workerで並行可能である。

## 5. B-STATUS — WordStatus/MyWordStatus mutation/effect

### 現在の欠陥

MyWordStatus:

- typed command/effect/consume APIはあるがcallerがwatch/listenせず、effectが表示/consumeされない。
- autoDispose notifierをreadするだけで処理中disposeの可能性。
- await後mounted/session token guardなし。
- command dedupeはあるがbutton disabled表示なし。

Dictionary WordStatus:

- mounted guardはあるがsubmitting/dedupeなし。
- failure eventがtyped errorを失う。
- UI listenerなし。
- mutation/session identityなし。

### 変更対象

- `lib/features/my_word/internal/presentation/status/my_word_status_command.dart` と `my_word_status_entry.dart`（A-FACADEで確定するfinal path）、owner DI/fragment/card/modal
- `lib/features/word_status/internal/presentation/dictionary_status/dictionary_word_status_command.dart` と `dictionary_word_status_entry.dart`（同final path）、owner provider/status button
- 各owner `port/presentation_entry.dart` の入力contract

削除済みの `app/presentation/word_status_buttons.dart` は変更しない。P0 characterizationの参照元としてだけ記録し、B-STATUSはfinal owner entryのみを編集する。

### tests

Unit:

- same mutation dedupe、bookmark送信中のlearned/note等cross-operation tapをaggregate laneが拒否し、全controlsをdisable
- op1完了→op2開始の両順序と、旧tokenが新command state/effect queueを上書きしないこと
- typed failureとfailed command保持
- stale consume IDがnew effectを消さない
- session/dispose後completion非publish
- provider再生成、同じAのnew epoch後にeffect sequenceが再利用されても、旧consume callbackが新effectを消さない
- failure→retry successでfailure/effect clear

Widget:

- submitting中disabled
- success/failure effectを一度表示
- 表示後consume、rebuildで再表示なし
- route leave/account switch後SnackBarなし

Cross-layer:

- Aでmutation開始→B/signed-out→A completion
- writeはA scopeに留まり、B UI/state/effectへ通知しない
- A epoch1で開始→同じA epoch2へrelogin。epoch1のdirect command/effectは非publishだが、確定済み永続writeがepoch2のrepository streamから後に見えることは許可する

### 実装

1. 両ownerを `CommandState + FIFO UiEffectEnvelope queue` の同じ概念へ揃える（型の共有を必須にはしない）。単一pending slotで未consume effectを上書きしない。
2. command identityにword/ref、operation、target value、session scope/epoch、request sequenceを含める。effect IDはopaque `(entryInstanceId, sessionEpoch, sequence)` とし、provider/session再生成を跨いでも一意にする。
3. `(sessionKey, word/ref)` aggregate単位をsingle-flight laneとし、いずれかのmutation中はbookmark/learned/note等すべてのcontrolsをdisableする。異なるoperationを並行実行しない。
4. owner entryにlistenerを置き、FIFO先頭をhandle後にexact full IDでconsumeする。MyWord successは既存 `UiReloadEffect` callbackを一度、failureはtyped noticeを一度、Dictionary success/failureはowner noticeを一度だけ扱う。
5. retryはfailed target commandを同じaggregate laneで再実行する。
6. owner stream projection更新とdirect command/effectを分離する。session変更後の旧completionはdirect state/effectを出さないが、開始scopeへcommit済みの永続projectionをrollbackしない。

完了条件:

- 操作は一度、typed error/retryあり、success/failure effect once。
- cross-operation race、effect slot喪失、stale consume 0。
- dispose/session change後publish 0。
- app facadeにlistener/state ownerが残らない。

## 6. B-QUIZ-GAME — failure/no-data分離

### 現在の欠陥

- conjugation read failureと正常nullを同じnullへ変換。
- English read failureをempty mapへ変換。
- DB row missingをplaceholder mapでsuccess化。
- asset failure以外がAsyncErrorへ届かず、asset failureにもretry UIがない。
- 分散providerのためsource別failureを一つのscreen stateで判定できない。
- 現 `ConjugationReader` だけではword not foundとnormal no-conjugationを区別できない。

### result contract

P0/A-QUIZ2で配置済みの `QuizGameQuery(CatalogWordRef)`、aggregate loader、sealed `QuizGameLoadResult` を変更せず使う。

- `ready`: word、conjugation、required assetsが揃う
- `noConjugation`: primary wordは存在するが正常に活用なし。successだがQuiz開始不可
- `notFound`: primary Catalog wordが存在しない
- `failure(source, error)`: primary Catalog、conjugation read、English row/data、guide/be asset

candidate 0件はQuiz Searchの `QueryEmpty` であり、game resultに混ぜない。auxiliary asset failureは今回fatal/retryableとする。degraded successへ変える場合は別product decisionが必要。

判定順を固定する。primary Catalog detailが `NotFoundError` の時だけ `notFound`、その他のprimary errorは`failure(primaryCatalog, error)`。primary存在確認後、conjugation readerの正常nullだけを`noConjugation`、reader failureは`failure(conjugation, error)`とする。English row missingはgameの`notFound`ではなく`failure(englishRow, NotFoundError)`、guide/be asset errorもsource付きfailureとする。

### 変更対象

- A-QUIZ2 compatibility adapterを置換するtyped source reader/aggregate implementation。public query/result signatureは変えない
- game view model/model/DI/providers/fragment
- `data/repository_impl/drift_es_en_conjugacions_repository.dart`、`domain/repository/i_es_en_conjugacion_repository.dart`、`data/data_source/local/i_es_en_conjugacion_local_data_source.dart`、`es_en_conjugacion_drift_data_source.dart`
- `application/fetch_english_conj/{i_fetch_english_conj_usecase,fetch_english_conj_interactor}.dart` とQuiz internal DI
- CatalogReader/ConjugationReader利用contract
- final `QuizGameRoute(CatalogWordRef, displayHint)`

### tests

Application:

- catalog not found、catalog failure（candidate 0はB-QUIZ-SEARCHのowner testだけに置く）
- normal no-conjugation、conjugation failure
- English row missing/failure
- guide/be asset failure
- repository unitでrow missingがplaceholder mapでなく`NotFoundError`になるexact path

VM/widget:

- result variantごとのstate/page
- error/no-data/readyの表示差
- same route identity retry
- retry double tapは一request、same identity in-flight dedupe
- old initial failureとretry successを逆順completeしてもsuccessを上書きしない
- retry successでstale errorなし
- route key change/dispose後旧completionなし

Cross-layer:

- fake Catalog bridge + real/fake Drift English repository + asset fake

### 実装

1. primary Catalog detailでword存在を確定してからconjugationを読む。
2. A-QUIZ2のcompatibility adapterをtyped source reader/aggregate実装へ差し替え、分散FutureProviderを一つのaggregate lifecycleへ統合する。
3. source付きtyped failureをnull/map/placeholderへ潰さない。
4. route/load identityに `CatalogWordRef` を使う。
5. retryは同じidentityでrequired sourceを再評価し、generation/attempt tokenでdouble tapと旧completionを拒否する。

完了条件:

- normal no-conjugation以外のfailureがsuccess/nullにならない。
- source別error/retryに到達し、retry後stale error 0。

## 7. B-RANKING — account/filter/request fence

### 現在の欠陥

- VM/usecase DIがsession/usecaseをreadし、最初のaccount scopeを保持し得る。
- generation/account/filter identity、mounted/in-flight guardなし。
- filter resetと旧completionが競合し、old itemsがfinal stateを上書き。
- page0もappend、previous captureでlost update、duplicate。
- same-page retry testは一部あるがrequest fenceなし。

### identity

`RankingPageIdentity(sessionKey, normalizedFilter, page, pageSize)` を使う。row dedupeは `rankings.ranking_id` 由来のstable `rankingId` を使う。現行データ/testでは同じ `wordId` のranking rowが複数存在し得るため、`CatalogWordRef` や `(catalogId, wordId)` でdedupeしてはならない。A-RANKINGでDAO projection→`RankingQueryRow`→`RankingListItem`/port itemへ `rankingId` を通し、schemaは変更しない。rank順位はidentityに含めず、新responseの表示値として更新する。

`normalizedFilter` はincluded/excluded part-of-speech/feature-tagをunmodifiable setへcopyしたvalue objectとし、enum順に依存しないdeep equality/hashCodeを持つ。UIのmutable `Map<Enum, int>` をidentityへ保持しない。`multiLemma`等がword単位にまとめる既存repository filter semanticsと、pagination responseのrow identity dedupeは別契約とする。非group rowは物理`r.ranking_id`、`GROUP BY r.word_id` rowは `MIN(r.ranking_id) AS ranking_id` をdeterministic group identityとし、後者も返却された`rankingId`でdedupeする。

### 変更対象

- Ranking VM/model/fragment/effect provider/DI
- load rankings use case
- B-SCROLL済みcontroller
- A-RANKING final pathの `ranking_dao.dart`、`drift_ranking_query_repository.dart`、`ranking_query_row.dart`、`ranking_list_item.dart`、`ranking_page.dart`（`rankingId` read projectionのend-to-end確認）

### tests

- page0 double request
- widget初回mountでpage0を一度だけ要求
- F0 request中F1 change、両completion順
- guest→A→B→signed-out、同じA new epoch
- same identity retry、page0 replace/page1 append
- 200 rowsが同じ`wordId`でも異なる`rankingId`なら200件を維持し、同じ`rankingId`だけをdedupe
- filter Map/Setの挿入順や元Mapの後続mutationでidentityが変わらず、意味が違うfilterは不一致
- `multiLemma` grouping testとrow dedupe testを別に維持
- `multiLemma` groupはSQL入力/挿入順にかかわらず同じ`MIN(rankingId)`を返し、non-aggregate `r.ranking_id`を曖昧にselectしない
- dispose completion
- account別WordStatus rowを持つquery repositoryとのcross-layer test

### 実装

1. A-SESSION-SEAMがrekey済みのsession keyとimmutable filter snapshotをpage identityへ入れる。B-RANKINGで第二session provider/rekey mechanismを作らない。
2. filter changeをcurrent entry内のatomic resetにする。session changeのentry detach/rekeyはA-SESSION-SEAMを唯一のownerとし、本packageはnew entryのpage0 trigger/request fenceを実装する。
3. same identity in-flight dedupe、token check。
4. page0 replace、後続dedupe append。
5. failed identityをVMが唯一のretry sourceとして持ち、controllerはtriggerだけを委譲。

完了条件:

- old account/filter/epoch item publish 0。
- page0 duplicate、response reversal、retry pageずれ、dispose update 0。

## 8. B-GUEST — failure UX と session safety

### 維持する既存保証

transaction内session fence、rollback、成功後no-op idempotenceは既存testで概ねgreenである。workflow再設計でこのuse case保証を作り直さない。

### 現在の欠陥

- promptはdetection/migration/session cancellationをcatch/logするだけで通知/retryなし。
- global `_checking` 中のA→B Ready eventを捨て、Bを再評価しない。
- A dialog表示中account changeでstale dialogが残る。
- post-migration syncが開始時epochでなくnew epochを取り直す。
- post-sync failureとmigration failureを区別しない。

### controller state/effect

prompt local booleanをaccount/epoch付きcontroller state machineへ置換する。

failure分類とretry:

- detection failure:通知し、同じcurrent sessionならdetectionをretry
- migration failure:通知し、current epoch確認後に再detectしてからretry
- `GuestMigrationSessionChanged`: user errorにせずcancelし、latest pending sessionを評価
- post-sync `SyncRunOutcome.retryScheduled`: migration完了を維持し、「同期は再試行予定」と通知する。durable schedulerを唯一のretry ownerとし、UI Retryを出さない
- post-sync `SyncRunOutcome.nonRetryableFailure`: migrationを再実行せず、current original epochかつin-flight/durable retryなしを確認してpublic sync runnerだけを手動retryできる
- post-sync `cancelled`: session cancellationとして通知せず、latest pending sessionを評価

### 変更対象

- guest migration prompt/dialog
- 新controller/state/effect
- guest migration/session bootstrap composition
- session fence、A-SYNCで確定済みの `SyncRunOutcome` とpublic sync runner contract
- migrate use caseはtransaction保証を維持

### tests

Unit:

- 各failure分類、notice/retry
- A checking中B Readyをqueueし、run終了後Bを評価
- A処理中のB→C→signed-outはlatest eventだけを残し、A終了後signed-outを評価。中間B/C dialog 0
- double approve/notificationでexecute一回
- original epoch失効後post-syncなし
- 実 `SyncReport` のretryable failure→durable retry arm→`retryScheduled`を通し、raw exception fakeだけで代用しない
- scheduler retryがarm済みの時にmanual retry 0、non-retryable時だけmanual sync run一回

Widget:

- failure SnackBar/Retry
- account switchでowner dialogだけclose
- effect once、rebuild/dispose後表示なし

Cross-layer:

- real Drift transaction/fence/outboxでA→B/signed-out
- rollback→B retry success、duplicate outboxなし
- migration成功後のretryable/non-retryable Sync outcomeを実scheduler/report interpreter経由で確認

完了条件:

- 実failure通知/retry、session cancellation誤通知なし。
- Ready event取りこぼし、stale dialog/completion/post-sync 0。
- durable schedulerとUIの二重sync retry 0、post-syncはmigration再実行0。
- migration/outbox exactly-once相当を維持。

## 9. B-WORDDETAIL — 全UI状態

umbrellaを二つの直列sub-IDに分ける。

| sub-ID | owner/前提 | 成果 |
|---|---|---|
| B-WORDDETAIL1 | WordDetail feature owner。A-FINAL後 | final `features/word_detail` 上のrenderer/status mount意味matrix |
| B-WORDDETAIL2 | app routing integration owner。B-WORDDETAIL1後 | final router graphのinvalid/legacy acceptance |

Gate AがGate Bを待つ逆依存を作らないため、P0/A-WORDDETAILのcharacterizationだけをrename前に維持し、Bの修正/acceptanceはA-FINAL後のfinal pathで行う。umbrella `B-WORDDETAIL` は両sub-ID完了を表す。

### 既に維持すべき挙動

- aggregate VMのgeneration/mounted guard
- primary success + conjugation failureでbody + warning
- normal no-conjugationでtab/FABなし
- Jpn→Espでconjugation/Quiz UIなし
- legacy `hasConj`をroute parserが無視

### 現在の不足/欠陥

- widget testはEsp→Jpn happy path一件だけ。
- `QueryEmpty(warnings)` が一般emptyに吸収されwarning消失。
- Jpn directionにwarning表示経路なし。
- loading/failure/emptyでもstatus buttonsをmount。
- invalid routeはcontract unitだけでrouter widget acceptanceなし。
- legacy `hasConj`非影響をUIで未試験。

primary retryは`remaining-work.md`のB7受入にない新scopeなので本packageでは追加せず、failureを正しく表示するところまでとする。retryをproduct要件にする場合は別change IDで承認する。

### state renderer

top-levelで次を排他的に描画する。

- loading
- primary failure
- empty。warningがあればwarning + empty body
- data。valid primary data時だけstatus entry
- Esp data + conjugationあり: tab/FAB
- Esp data + normal no-conjugation: tab/FABなし
- Esp data + conjugation failure: body + warning、capability UIなし
- Jpn data: conjugation/Quiz UIなし

### tests

table-driven widget:

- Esp ready、partial failure、no-conjugation
- Jpn ready
- Esp/Jpn empty、`QueryEmpty(warnings)`
- primary failure
- status/FAB/tabの有無
- loading/failure/emptyでstatus provider call 0（非表示だけでなくprovider未構築をspyで確認）

invalid routeはfeature renderer stateに入れず、A-APP完成後のapp router cross-layer acceptanceとして分離する。

- invalid wordId/catalog/type/conflict→InvalidRoutePage
- legacy `hasConj=true/false/garbage` すべてでfetched resultだけがtab/FABを決定
- invalid routeでfeature VM/status provider call 0

### 実装

1. common warning rendererをEsp/Jpnで利用。
2. status entryをvalid primary data branch内へ。
3. empty warningをbodyと同時表示。
4. Search provider依存はGate Aでephemeral presentation input/local stateへ置換済みとする。

完了条件:

- 方向 × primary state × conjugation capability matrixが自動化。
- partial body、empty warningを失わない。
- invalid route/legacy `hasConj`/status mount条件がUI levelで保証。

B-WORDDETAIL1としてfinal owner rendererの意味testを実装し、B-WORDDETAIL2としてfinal app graph上のinvalid-route acceptanceを続けて実行する。rename前の意味保証はP0/A-WORDDETAIL characterizationが担い、B packageにpath追随changeを発生させない。

## 10. 統合順と並列化

```text
P0-BEHAVIOR → B-SCROLL
  ├─ A-SEARCH + A-SESSION-SEAM + A-FACADE → B-SEARCH
  ├─ A-QUIZ + A-SESSION-SEAM + A-FACADE → B-QUIZ-SEARCH
  ├─ A-SESSION-SEAM + A-MYWORD → B-MYWORD
  ├─ A-SESSION-SEAM + A-RANKING → B-RANKING
  ├─ A-FACADE + status owners → B-STATUS
  ├─ A-ROUTE + Quiz owner → B-QUIZ-GAME
  ├─ A-FINAL → B-GUEST
  └─ A-FINAL → B-WORDDETAIL

全B package + A-FINAL → B-FINAL
```

- B-SEARCH/B-QUIZ-SEARCHはshared controller完了後に並列可能。
- B-MYWORD/B-RANKINGはsession contractを共有するがowner filesは別なので並列可能。
- B-STATUSはMyWord/WordStatusでunit実装を分担できるが、facade listener統合は一人が行う。
- B-QUIZ-GAMEとB-WORDDETAILはroute contract/router testを共有するためintegrationは直列。
- B-GUESTはapp workflow/UserProfile rename/bootstrapと競合するためA-FINAL後、final app workflow pathを同じintegration ownerが変更する。

## 11. B-FINAL

次のcross-layer matrixを全てgreenにする。

- session: guest→A→B→signed-out、同じA relogin、intermediate phaseの旧data detach、旧completion破棄
- MyWord/Ranking: page0一度、replace/append、same-page retry、dedupe、dispose。Rankingは`rankingId`とimmutable filter deep equality
- Search/Quiz Search: query/session change、candidate empty、Data/Empty warning、stale banner、same-page retry、dispose後publish 0
- status mutation: aggregate single-flight/cross-operation dedupe、typed failure、FIFO effect once/stale consume、session/dispose fence
- Quiz game: not found、no-conjugation、source別failure、deduped retry
- guest migration: failure通知/retry、latest-wins session、stale dialogなし、post-sync original epoch、durable/manual二重retry 0
- WordDetail: direction/state/capability、invalid route、legacy `hasConj`非影響

最終実行は二段にする。まずGate B matrix、次にB-GUEST/B-WORDDETAIL等のproduction変更後HEADに対する `A-FINAL-RECHECK` を行う。先行A-FINALの古い証拠を流用しない。

```powershell
flutter test test/integration/gate_b
dart run tool/check_import_boundaries.dart --check --baseline tool/import_boundaries/baseline.json
dart analyze
flutter analyze
flutter test test/tool/import_boundaries/check_import_boundaries_test.dart
flutter test
flutter test --platform chrome test/integration/database/web_database_reuse_test.dart
npm --prefix firebase-tests ci
npx --yes firebase-tools@13.35.1 --config firebase-tests/firebase.json emulators:exec --project my-dic-sync --only auth,firestore "npm --prefix firebase-tests test"
npx --yes firebase-tools@13.35.1 --config firebase-tests/firebase.json emulators:exec --project my-dic-sync --only auth,firestore "flutter test --platform chrome test/integration/firebase/remote_mutation_transaction_contract_test.dart"
```

B-FINALは全B packageだけでなくA-FINALのevidence完了を開始条件とし、最後に上記A-FINAL-RECHECKを同じcommitで通す。generated source/pathをBで触れた場合はこの前にbuild runnerも再実行する。Gate Bだけgreenでもrelease-readyとはせず、[Gate A](./implementation-plan-gate-a.md) のmandatory DB/Web/Firebase suiteが最終HEADでgreenであることを確認する。
