# Core Responsibility Map

最終更新: 2026-08-06

この文書では、`lib/core`配下を変更理由ごとにまとめる。`core`は現状、純粋な共有kernelだけでなく、旧DI、DB、catalog repository、shared UIも抱えている。

## `lib/core/application`

| file / directory | 責務 | 状態 |
| --- | --- | --- |
| `auth_lifecycle/auth_lifecycle_state.dart` | auth lifecycle phaseとderived flags | `ready`がsync開始条件になる |
| `auth_lifecycle/auth_lifecycle_controller.dart` | sign-in/up/out、email verification、profile provisioning、store更新 | 現在のAuth/User調停の中心。ただしfeature storeへ依存している |
| `auth_lifecycle/auth_lifecycle_provider.dart` | controller provider組み立て | Phase 1-4でCurrentSessionへつなぐ入口 |
| `effects/auth_effect_provider.dart` | Firebase Auth streamを監視しAuthLifecycleへ渡す | 横断effectとして`lifecycle_effects`から起動 |
| `coordinator/auth_user_coordinator.dart` | 旧Auth/User統合Coordinatorのコメントアウト実装 | 実質残骸。Phase 3で削除/ADR化候補 |

## `lib/core/di`

| file | 責務 | 状態 |
| --- | --- | --- |
| `di/data/data_di.dart` | `DatabaseProvider`、Drift DAO、Firebase status DAO、SharedPreferences sync DAOを組み立てる | coreからfeature DAO/tableをimportしており境界違反baselineあり |
| `di/data/datasource.dart` | catalog/status/checkpoint系datasource provider | 旧core data composition |
| `di/data/repository_di.dart` | catalog repositoryとsync status repository provider | ranking feature providerへの依存がbaselineにある |
| `di/usecase/usecase_di.dart` | core catalog usecase provider | WordPage/Searchから利用 |
| `di/router/router.dart` | entry point/tab index state provider | Router/tab source of truth整理の対象 |
| `di/ui/ui_di.dart` | bottom bar height state | shared UI state |
| `di/view_model/view_model.dart` | DB loading notifier provider | `DatabaseLoadingOverlay`用 |
| `di/coordinator/corrdinator.dart` | coordinator DIの旧入口 | typo含む。Phase 3 rename/delete候補 |
| `di/global.dart` | global DI placeholder | 中身は薄い。新global singletonを増やさない |

## `lib/core/domain`

| file / directory | 責務 | 状態 |
| --- | --- | --- |
| `entity/auth.dart` | 旧/共通の`AppAuth` | `features/auth/domain/entity/app_auth.dart`と重複。統一対象 |
| `entity/sync_checkpoint.dart` | legacy sync checkpoint key/value | Phase 0の安全契約 |
| `entity/dictionary/**` | 西和辞書aggregate、example/idiom/supplement | domainだがFlutter importあり。境界整理対象 |
| `entity/jpn_esp/**` | 和西辞書/word/example entity | domainだがFlutter importあり。境界整理対象 |
| `entity/verb/**` | スペイン語活用、時制、分詞、検索一致箇所 | Search/Quiz/WordPageで共有されるcatalog model |
| `entity/word/word.dart` | 西和word entity | Search/Ranking/WordPageで共有されるcatalog model |
| `i_repository/**` | catalog/conjugation/sync repository port | 一部feature型へ依存しbaseline違反あり |
| `usecase/fetch_dictionary/**` | 西和辞書詳細取得 | WordPage用catalog query |
| `usecase/fetch_jpn_esp_dictionary/**` | 和西辞書詳細取得 | WordPage用catalog query。interactorにDrift importあり |
| `usecase/fetch_conjugation/**` | 活用詳細取得 | WordPage/Quiz用catalog query |
| `usecase/i_sync_usecase.dart` | 旧SyncService用sync usecase contract | Local-first 8で削除対象になる旧同期port |

## `lib/core/infrastructure`

| file / directory | 責務 | 状態 |
| --- | --- | --- |
| `database/drift/database_provider.dart` | Drift DB定義、schema v6、migration、web/native executor、asset DB copy | DB正本。coreからfeature table/DAOをimportする移行途中 |
| `database/drift/tables/esp_jpn/**` | 西和catalog/status Drift table | status tableはaccount scope列追加済み |
| `database/drift/tables/jpn-esp/**` | 和西catalog/status Drift table | directory名にhyphenあり。renameはPhase 3で慎重に |
| `database/drift/tables/sync/**` | `sync_outbox`、`sync_checkpoints`、`user_profiles` | Local-first基盤。未接続でも削除しない |
| `database/drift/daos/esp_jpn/**` | 西和catalog/status DAO | 大型DAOあり。Phase 3分割候補 |
| `database/drift/daos/jpn_esp/**` | 和西catalog/status DAO | catalog queryの実体 |
| `database/drift/daos/es_en_conjugacion_dao.dart` | 英語活用補助DB DAO | Quiz用 |
| `database/drift/_WEB/**` | Web IndexedDB executorとJSON seed | `web_database_seeder.dart`は大型。Phase 3分割候補 |
| `database/drift/_NATIVE/**` | native SQLite executor helper | platform分岐境界 |
| `database/firebase/**` | 旧Firebase status DAO/provider | Local-first移行後はsync remote adapterへ寄せる |
| `database/shared_preferences/**` | SharedPreferences providerとlegacy sync checkpoint DAO | checkpointはaccount/dataset scoped済み |
| `datasource/conjugacion/**` | 活用local datasource | Drift DAOをrepositoryから隠す層 |
| `datasource/esj/**` | 西和辞書/word local datasource | Search/WordPage/Ranking系catalog read |
| `datasource/jpn_esp/**` | 和西辞書/word local datasource | Search/WordPage系catalog read |
| `datasource/word_status/**` | 西和status local/remote datasource | 旧同期/旧Repositoryが使用。remoteはFirebase直 |
| `datasource/jpn_esp_word_status/**` | 和西status local/remote datasource | 旧同期/旧Repositoryが使用。remoteはFirebase直 |
| `datasource/sync/**` | SharedPreferences sync status datasource | legacy sync checkpoint用 |
| `repositories/converters/**` | Drift row/DTOからdomain entityへの変換 | coreからfeature型へ依存するconverterあり |
| `repositories/drift_*_repository.dart` | catalog repository実装 | core catalog read modelの現役実装 |
| `repositories/sync_status_repository.dart` | legacy sync checkpoint repository | 旧SyncService/usecaseで使用 |

## `lib/core/presentation` and `lib/core/section`

| file / directory | 責務 | 状態 |
| --- | --- | --- |
| `presentation/components/auto_focus_text_field.dart` | focus制御付きTextField | shared UI component |
| `presentation/components/button/my_icon_button.dart` | icon button component | shared UI component |
| `presentation/components/icons/rotating_icon.dart` | 回転icon animation | shared UI component |
| `presentation/components/infinityscroll.dart` | infinite scroll controller/list | Search/Ranking/MyWord系で利用される汎用UI |
| `presentation/components/nav_bar/**` | custom bottom nav bar | Router/tab整理対象 |
| `presentation/custom_floating_button_location.dart` | nav bar上にFABを置くlocation/animator | shared UI |
| `presentation/theme/**` | app color/theme定義 | `app_theme.dart`は空に近い |
| `section/db_loading/**` | DB loading state/notifier/overlay | `MyApp` builderで全画面overlayとして表示 |

## `lib/core/shared`

| file / directory | 責務 | 状態 |
| --- | --- | --- |
| `consts/**` | app name、DB名、Firebase keys、UI定数、tab定義、default user等 | typo混在あり。renameはPhase 3向き |
| `enums/auth/**` | provider/subscription status enum | Auth/User domainで使用 |
| `enums/conjugacion/**` | スペイン語/英語の時制・主語 enumと変換 | Quizの中核ロジックで使用 |
| `enums/direct-written-db/**` | 旧DB column/table enum | seed/converter/DAO周辺の補助。必要性を確認して整理 |
| `enums/dictionary/**` | dictionary type | Searchの入力判定で使用 |
| `enums/entry_point.dart` | bottom nav / branch entry point | NavigatorServiceとtab stateで使用 |
| `enums/feature_tag.dart`、`enums/word/**` | Ranking/Search/WordPageのcatalog分類 | feature ownership整理対象 |
| `enums/sync_dataset.dart` | Local-first dataset stable ID | 永続化ID。削除/rename禁止に近い |
| `errors/**` | `AppError`、domain/infrastructure/unexpected failure | `Result`で伝播するerror契約 |
| `utils/result.dart` | `Result<T>` | failureを潰さない安全契約 |
| `utils/logger.dart` | redaction付きlogger | Phase 0安全契約 |
| `utils/json.dart`、`screen_size.dart`、`uuid.dart` | JSON/debug、responsive helper、UUID生成 | shared utility |
| `value_objects/field_update.dart` | 部分更新値object | status/profile patchで再利用する契約 |