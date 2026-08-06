# Feature Responsibility Map

最終更新: 2026-08-06

この文書では、`lib/features`配下の責務をfeature単位でまとめる。

## `features/auth`

| area / file | 責務 | 状態 |
| --- | --- | --- |
| `domain/entity/app_auth.dart` | 認証identity entity | `core/domain/entity/auth.dart`と重複がある |
| `domain/I_repository/i_auth_repository.dart` | auth repository port | casingが`I_repository`で揺れている |
| `domain/usecase/**` | observe/reload/signin/signup/signout/verify/reset email usecase | AuthLifecycleから利用 |
| `data/data_source/remote/**` | Firebase Auth DAO/data source | Firebase boundaryとして妥当 |
| `data/dto/auth_dto.dart` | Firebase UserからAppAuthへの変換 | Firebase importあり |
| `data/repository_impl/firebase_auth_repository_impl.dart` | Firebase Auth repository実装 | 機密ログ削除済み。Auth failure変換境界 |
| `di/**` | auth data/usecase/store/viewmodel/coordinator provider | Riverpod composition |
| `presentation/view_model/auth_store.dart` | AppAuthの可変store | AuthLifecycleがwriter。identityの外部参照は`currentSessionProvider`へ移行済み（`profile.dart`など） |
| `presentation/view_model/sign_in_view_model.dart` | sign-in/up画面操作のVM | AuthLifecycleへ寄せる対象 |
| `presentation/ui_model/sign_in_model.dart` | sign-in UI state | presentation model |
| `presentation/view/sign_up.dart` | email/password login/signup UI | lifecycle状態表示の主UI |
| `auth_coordinator.dart` | 旧Auth coordinator facade | まだDIに残る。Phase 2/3で用途確認 |

## `features/user`

| area / file | 責務 | 状態 |
| --- | --- | --- |
| `domain/entity/user.dart` | app user profile entity | editable profileとremote authority情報が混在し得る |
| `domain/i_repository/i_user_repository.dart` | user repository port | AuthLifecycleのprofile provisioningで使用 |
| `domain/usecase/**` | get/create/update/ensure user usecase | ensureはAuthLifecycleに接続済み |
| `data/data_source/local/**` | SharedPreferences device/user local data | device ID保持。Local-first profileとは別物として扱う |
| `data/data_source/remote/**` | Firestore user profile DAO/data source | Local-first 7でremote adapter化対象 |
| `data/dto/**` | local/remote user DTO | Firestore timestamp/subscription変換 |
| `data/repository_impl/user_repository.dart` | local device ID + remote user profile操作 | まだremote直書き。Local-first 7移行対象 |
| `presentation/view_model/app_user_store.dart` | AppUser可変store | AuthLifecycleがwriter。profile表示用途のみ継続利用（identity解決には使わない） |
| `presentation/view_model/user_profile_view_model.dart` | profile UI VM | User usecaseへ接続 |
| `presentation/view/profile.dart` | profile画面 | Router redirect先 |
| `user_coodinator.dart` | 旧User coordinator | typo含む。Phase 2-4/3で整理対象 |

## `features/esp_jpn_word_status`

| area / file | 責務 | 状態 |
| --- | --- | --- |
| `domain/esp_word_status.dart` | 西和word status entity | Flutter importあり。domain純化対象 |
| `domain/i_word_status_repository.dart` | 西和status repository port | local/remote/watch/sync APIを含む旧port |
| `domain/usecase/update_status/**` | status部分更新 usecase/input/output | `FieldUpdate`契約を使用 |
| `domain/usecase/watch/**` | status watch usecase | UI button stateへ接続 |
| `domain/usecase/fetch_esp_jpn_status/**` | status fetch usecase | detail/status UI用 |
| `domain/usecase/sync_esp_jpn_word_status/**` | 旧status sync usecase | 429 lines。Local-first 5でhandlerへ置換対象 |
| `data/wordstatus_repository.dart` | local Drift + remote Firebase status repository | local/remoteを直接持つ。Local-first 5の中心対象 |
| `data/wordStatusEntity.dart` | Firebase status DTO | naming揺れあり |
| `di/di.dart` | status data/usecase/stream/UI state/command provider | Riverpod providerが集中 |
| `components/status_button/**` | status buttons、command、state、VM、jpn_esp/myword adapter | feature横断UI部品化しておりownership整理対象 |

## `features/jpn_esp_word_status`

| area / file | 責務 | 状態 |
| --- | --- | --- |
| `domain/jpn_esp_word_status.dart` | 和西word status entity | Flutter importあり。domain純化対象 |
| `domain/i_jpn_esp_word_status_repository.dart` | 和西status repository port | 西和status portとほぼ対称 |
| `domain/usecase/update_jpn_esp_status/**` | 和西status部分更新 usecase/input | `FieldUpdate`契約を使用 |
| `domain/usecase/watch/**` | 和西status watch usecase | UI adapterから利用 |
| `data/jpn_esp_word_status_repository.dart` | local Drift + remote Firebase status repository | Local-first 5の対象 |
| `data/jpn_esp_word_status_entity.dart` | Firebase DTO | remote adapter化対象 |
| `data/converter/jpn_esp_word_status_converter.dart` | Drift row/entity変換 | data層変換 |
| `di/di.dart` | data/usecase/stream/UI state/command provider | Riverpod providerが集中 |

## `features/my_word`

| area / file | 責務 | 状態 |
| --- | --- | --- |
| `domain/entity/my_word.dart`、`my_word_status.dart` | MyWordとMyWordStatus entity | Flutter importあり。domain純化対象 |
| `domain/i_repository/**` | MyWord/MyWordStatus repository port | local/remote/watch/sync APIを含む旧port |
| `domain/usecase/my_word/create/**` | MyWord登録と登録ハンドリング | local作成後にremote直書きが残る |
| `domain/usecase/my_word/update/**` | MyWord更新 | Local-first 6でoutbox化対象 |
| `domain/usecase/my_word/delete/**` | MyWord削除 | tombstone化対象 |
| `domain/usecase/my_word/load_my_word/**` | MyWord一覧取得 | local read |
| `domain/usecase/my_word/watch/**` | MyWord watch | local stream |
| `domain/usecase/my_word/sync_my_word/**` | 旧MyWord sync | `sync_my_word_interactor copy.dart`が残る。Phase 3統合候補 |
| `domain/usecase/my_word_status/**` | status update/watch/sync | Local-first 6対象 |
| `data/data_source/local/**` | MyWord/MyWordStatus Drift table/DAO/data source | v6 account scope列あり。現Repositoryは`legacy_unowned`使用箇所あり |
| `data/data_source/remote/myword/**` | Firebase MyWord DAO/data source/DTO | sync remote adapter化対象 |
| `data/data_source/remote/status/**` | Firebase MyWordStatus DAO/data source/DTO | sync remote adapter化対象 |
| `data/repository_impl/my_word_repository.dart` | MyWord local/remote repository | local更新後remote直書き。Local-first 6の中心対象 |
| `data/repository_impl/my_word_status_repository.dart` | MyWordStatus local/remote repository | local sync method未実装/空stream箇所あり。Local-first 6で補完 |
| `di/**` | data/usecase/viewmodel provider | provider集中。sync usecaseもここで組む |
| `presentation/ui_model/**` | MyWord list/status command event/state | UI state |
| `presentation/view_model/**` | list VM、item VM、command、status command | Viewからusecaseを呼ぶ層 |
| `presentation/view/**` | list、card、modal、create modal | 大型modalあり。Phase 3分割候補 |

## `features/search`

| area / file | 責務 | 状態 |
| --- | --- | --- |
| `domain/usecase/judge_search_word/**` | 入力語が西和/和西か判定 | Search VMで使用 |
| `domain/usecase/search_word/**` | 西和/和西/活用検索とranking/meaning/star付加 | Phase 1-5 slice 1でQuiz entity依存を解消し、`core/domain/entity/verb/conjugacion/conjugacion_search_result_item.dart`（catalog型）を利用するよう変更済み |
| `di/**` | Search usecase/viewmodel provider | Router/NavigatorServiceへ接続 |
| `presentation/ui_model/search_ui_model.dart` | SearchState | loading/data/errorは独自形 |
| `presentation/view_model/viewmodel.dart` | query更新、paging、検索、detail/quiz遷移 | AppNavigatorServiceに依存 |
| `presentation/view/search_fragment.dart` | 検索画面 | active版 |
| `presentation/view/search_fragment copy.dart` | copy残骸 | Phase 3-2統合/削除候補 |
| `presentation/components/**` | search card、jpn-esp card、conjugation card、card view | `card_view copy.dart`あり。大型UI分割候補 |

## `features/word_page`

| area / file | 責務 | 状態 |
| --- | --- | --- |
| `di/view_model_di.dart` | WordPageViewModel provider | route contractからVMへ接続 |
| `presentation/view_model/word_page_view_model.dart` | 辞書/活用詳細取得、quiz遷移 | core catalog usecaseとNavigatorServiceに依存 |
| `presentation/ui_model/jpn_esp_state.dart` | WordPageState | 名前はjpn_espだが西和も持つ |
| `presentation/view/word_page_fragment.dart` | word detail画面、tab/single入力、keep alive | 旧input型が一部残る。route contractへ寄せる対象 |
| `presentation/view/esp_jpn/**` | 西和辞書/活用fragment | detail UI |
| `presentation/view/jpn_esp/**` | 和西辞書fragment | `JpnEspDictionaryFragmentInputData`がView内に残る |
| `presentation/components/conjugacion_card.dart` | 活用カード | Quiz/WordPageで似たUIあり |
| `presentation/view/html_style_kotobank.dart` | HTML style定義 | flutter_html表示補助 |

## `features/quiz`

| area / file | 責務 | 状態 |
| --- | --- | --- |
| `consts/card_state.dart` | quiz card question/answer state | presentation寄りenum |
| （削除済み: `domain/entity/quiz_searched_item.dart`） | quiz検索結果item | Phase 1-5 slice 1で`core/domain/entity/verb/conjugacion/conjugacion_search_result_item.dart`へ統合。Quiz presentation層はcore catalog型を利用する側に整理済み |
| `domain/usecase/fetch_english_conj.dart/**` | 英語活用取得 | directory名に`.dart`が含まれる。Phase 3 rename候補 |
| `domain/usecase/english_conj_sub/**` | 英語例文template取得 | JSON asset datasourceから取得 |
| `data/data_source/local/**` | quiz JSON DAO、英語活用Drift datasource | Quiz data read |
| `data/repository_impl/**` | quiz/英語活用 repository | local/asset read |
| `di/**` | quiz data/provider/usecase/viewmodel provider | `be_conj`等JSON providerあり |
| `presentation/ui_model/**` | QuizSearchState、QuizGameState/InternalState | game stateを保持 |
| `presentation/view_model/quiz_game_viewmodel.dart` | quiz出題順、回答表示、英語文生成、detail遷移 | ロジックが大きい。Phase 3分割候補 |
| `presentation/view_model/quiz_search_view_model.dart` | quiz検索VM | Searchに近い責務 |
| `presentation/view/**` | quiz search/game画面 | `QuizGameRoute`接続済み |
| `presentation/components/**` | quiz card/search card | UI component |

## `features/ranking`

| area / file | 責務 | 状態 |
| --- | --- | --- |
| `domain/entity/ranking.dart` | ranking entity | Flutter importあり。domain純化対象 |
| `domain/i_repository/i_esp_ranking_repository.dart` | ranking repository port | catalog read |
| `domain/usecase/load_rankings/**` | ranking一覧取得 | presenter抽象あり。Phase 3未使用確認 |
| `domain/usecase/update_ranking_filter/**` | filter変更 | UI state変換寄り |
| `domain/usecase/locate_ranking_pagenation/**` | pagination位置決定 | spelling `pagenation`揺れあり |
| `data/data_source/local/**` | ranking Drift table/DAO/data source | DAO 323 lines。Phase 3分割候補 |
| `data/repository_impl/wiki_esp_ranking_repository.dart` | ranking repository実装 | namingはwikiだがlocal ranking read |
| `di/**` | data/usecase/viewmodel provider | provider小規模 |
| `presentation/view_model/new_ranking_view_model.dart` | ranking paging/filter/detail/quiz遷移 | `new_`命名はPhase 3整理候補 |
| `presentation/ui_model/ranking_ui_model.dart` | RankingState | Flutter importあり |
| `presentation/effect_provider.dart` | ranking filter side effect | UI effect provider |
| `presentation/view/**` | ranking画面、card、filter modal | filter modal大型。分割候補 |

## `features/sync`

| area / file | 責務 | 状態 |
| --- | --- | --- |
| `sync_service.dart` | 旧`ISyncUseCase`群をpriority順に実行し、remote changed streamをmerge | 現在のactive auto sync |
| `di.dart` | legacy sync service/auto sync provider | `authLifecycle.isReady`で起動 |
| `application/cancellation_token.dart` | SyncEngine用cancel token | 新基盤 |
| `application/dataset_handler_registry.dart` | dataset handler registry | registry重複検出の正本 |
| `application/sync_engine.dart` | dataset orchestration | production handler未接続 |
| `application/sync_scheduler.dart` | lifecycleからSyncEngineへ入る薄い口 | まだ具体的trigger未接続 |
| `application/single_flight_coordinator.dart` | account別single-flight/rerun管理 | 新基盤 |
| `application/in_memory_session_fence.dart` | account/session epoch fence | CurrentSession接続待ち |
| `application/model/**` | sync context/report/mutation/cursor/result/lease | Local-first contract |
| `application/port/**` | handler/queue/outbox/checkpoint/session port | 実装依存を外へ出す境界 |
| `application/policy/**` | dataset order、retry、backoff、error classification | handlerからpolicyを分離 |
| `infrastructure/persistence/drift/**` | Drift queue/outbox/checkpoint実装 | Local-first 5〜7で接続する |
| `description.md` | feature説明 | 実装ではないが文脈メモ |

## Catalog ownership note

Search、Ranking、Quiz、WordPageは、辞書catalog、活用、ranking metadata、word detail routeを横断的に共有している。

Phase 1-5 slice 1（完了）: 活用検索結果item（旧`features/quiz/domain/entity/quiz_searched_item.dart`）をcatalog概念として`core/domain/entity/verb/conjugacion/conjugacion_search_result_item.dart`（`ConjugacionSearchResultItem`）へ移設した。これによりSearch domainがQuiz entityをimportする問題と、core repository/converterがQuiz entityへ依存する`core_no_feature`違反3件、および`feature:quiz` <-> `feature:search`の双方向importが解消済み（`tool/import_boundaries/baseline.json`更新済み）。詳細は[`plans/phase1.5-define-catalog-ownership.plan.md`](plans/phase1.5-define-catalog-ownership.plan.md)。

未対応（次スライス向け、`no_cross_feature_presentation`として現存）:

- `word_page/presentation/view/esp_jpn/conjugacion_fragment.dart`が`features/search/di/view_model_di.dart`の`searchViewModelProvider`から検索queryを直接参照している（活用表示のハイライト用）。
- `word_page/presentation/view/esp_jpn/dictionary_fragment.dart`が`features/quiz/di/view_model_di.dart`の`quizWordProvider`へ現在表示中の単語を書き込んでいる。
- `word_page_fragment.dart`が`features/quiz/di/view_model_di.dart`の`quizGameViewModelProvider`をWordPage内Quizタブ表示のため直接初期化している。
- `features/quiz/presentation/view/quiz_search_fragment.dart`が`features/search/presentation/components/card/card_view.dart`（`CardView`）を再利用している。`CardView`自体は`features/esp_jpn_word_status/components/status_button`のstatus button widgetへ依存しており、Phase 1-6のstatus button ownership整理が先に必要なため、design systemへの移設は見送った。

これらはWordPage/Quiz/Searchの実際のUI埋め込み・状態共有であり、route contractまたはapp-level portの新規設計判断が必要。次に着手する場合は`next-phase-guide.md`の該当節を参照する。

## Status button ownership note

`features/esp_jpn_word_status/components/status_button`配下は、西和status feature名の中に、和西status adapterとMyWordStatus adapterも置かれている。UI再利用としては動くが、feature ownershipとしては曖昧。Phase 1-6でstatus統合、または共通presentation componentへの移動を判断する。