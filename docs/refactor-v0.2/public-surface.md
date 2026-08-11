# P0 public surface manifest

Status date: 2026-08-10.  This is the P0 decision baseline, not a claim that
the target architecture is already complete.  `Current` is based on the
checked-in source tree at the time of this update; an item marked `Gap` or
`Blocked` must not be treated as a completed feature move.

## Contract applied to every row

| Surface | Permitted signature | Forbidden from the surface |
|---|---|---|
| `port/model/**`, command, query, reader, route | Pure Dart values and interfaces | Flutter, Riverpod/Provider/Override, Drift/DatabaseProvider, Firebase, GoRouter, widgets |
| `port/composition.dart` | Pure-Dart interface/factory; it may delegate to an internal factory | Provider/Override and SDK/database/router/widget types in a public signature |
| `port/presentation_entry.dart` | The single Flutter entry, with pure input/callback/composition dependencies | Provider/Override exports; app routing and other feature routes |
| `internal/**` | Owner implementation, DI and presentation | Exposure as another feature's public dependency |
| `app/routing/**` | GoRouter and destination-route registration | Feature-internal imports; cross-feature UI imports (use callback + `CatalogWordRef`) |

All feature composition owns its own internal implementation.  App code may
consume only the named port factory/interface/entry below.  Framework instances
are created by app or owner infrastructure and are not public-composition
arguments.

## Manifest

| Feature / owner | Exact public target path(s) | Public signature to preserve | Consumer | Framework prohibition | Current status |
|---|---|---|---|---|---|
| Catalog | `lib/features/catalog/port/catalog_id.dart`; `catalog_word_ref.dart`; `catalog_reader.dart`; `conjugation_reader.dart`; `raw_search_reader.dart`; `raw_quiz_candidate_reader.dart`; `composition.dart`; `composition_contract.dart`; `model/catalog_entry_detail.dart`; `model/catalog_conjugation.dart`; `model/{esp_jpn_entry,jpn_esp_entry,catalog_part_of_speech}.dart` | `CatalogId`, `CatalogWordRef`, `CatalogReaderPort`, `ConjugationReaderPort`, `CatalogRawSearchReaderPort`, `CatalogRawQuizCandidateReaderPort`, `CatalogComposition`, `createCatalogComposition(CatalogDependencyReaderPort)` | Search and Quiz bridges; WordDetail/routes; app composition | All listed ports/models and factory signature are Flutter/Riverpod/Drift/Firebase-free. | **Current.** Factory delegates to owner internal composition. `presentation_dependencies.dart` exists but is not part of this public target and imports Riverpod; it must not become a public contract. |
| Search | `lib/features/search/port/{query,reader,catalog_gateway,composition,presentation_entry}.dart`; `model/{search_query,search_direction,search_result_item,search_result_page,conjugation_search_item,search_conjugation_match_key,search_catalog_word_ref}.dart` | `SearchQuery`, `SearchDirection`, `SearchResultItem/Page`, `SearchCatalogGateway`, `SearchReaderPort`, `createSearchComposition(SearchCatalogGateway)` and one presentation entry | app/integration adapts Catalog raw reader; app screen | Models/gateway/reader/composition cannot expose Catalog internals, DB, Riverpod, Flutter or routing. Entry may expose only widget/pure callbacks. | **Gap.** Pure query/gateway/reader/factory exist. `presentation_entry.dart` exports an internal fragment rather than declaring a controlled entry signature; `presentation_dependencies.dart` imports Riverpod. P0 composition proof remains unverified. |
| Quiz | `lib/features/quiz/port/{candidate_query,candidate_source,game_loader,route,presentation_input,composition,presentation_entry}.dart`; `model/{quiz_candidate,quiz_candidate_issue,quiz_candidate_page,quiz_candidate_query,quiz_game_query,quiz_game_data,quiz_game_load_result,quiz_game_load_source}.dart` | `QuizCandidateQuery/Page`, `QuizCandidateSource`, `LoadQuizGame`, `QuizGameQuery(CatalogWordRef)`, sealed `QuizGameLoadResult` (`Ready`, `NotFound`, `NoConjugation`, `LoadFailure`), `QuizGameRoute`, `QuizGamePresentationInput`, `createQuizCandidateSource(...)` | app routing; Quiz presentation; Catalog adapter | No Catalog raw DTO outside the bridge, and no Riverpod/GoRouter in route/model/source/loader signatures. | **Partial.** Candidate bridge and sealed load result exist. Route is **not plan-canonical**: current `QuizGameRoute.path` is `quiz-game/:wordId` and stores catalog in query parameters, whereas §2.7 requires `quiz-game/:catalog/:wordId` plus legacy parsing. Presentation entry directly exports internal widgets. |
| Sync | `lib/features/sync/port/{sync_dataset,dataset_sync_adapter,dataset_sync_handler,sync_handler_runtime,sync_runner,sync_queue,sync_checkpoint_store,outbox_writer,session_fence,remote_mutation_executor,cancellation_token,sync_run_outcome,composition,composition_contract}.dart`; `model/{sync_context,sync_cursor,sync_mutation,dataset_sync_result,sync_report,remote_mutation,mutation_lease}.dart` | `DatasetSyncAdapter`, `DatasetSyncHandler`, `SyncHandlerRuntime.run(context, adapter)`, queue/checkpoint/outbox/fence ports, `SyncRunner`, pure `SyncRunOutcome` | feature dataset contributions; app session/sync workflow | No retry/backoff/classifier/guard concrete types, DB, Firebase or Provider in public signatures. | **Partial.** Core port/factories are present and composition is framework-free. The outcome enum uses `nonRetryableFailure`; runtime/proof and handler ownership tests are not established by this manifest. |
| Auth | `lib/features/auth/port/{app_auth,auth_commands,auth_readers,composition,presentation_entry}.dart` | `AppAuth`; observe/reload readers; sign-in/up/out/verification commands; `AuthLifecyclePorts` | app session lifecycle and auth screen | Lifecycle ports and composition must be pure; presentation may be Flutter-only but must not export providers/overrides. | **Current.** `composition.dart` is a pure public factory delegating to the owner-only `internal/factory` seam; canonical Firebase construction remains in Auth infrastructure. `presentation_entry.dart` exposes only the controlled Flutter page with injected state/actions, while the app owns Riverpod adaptation. Focused Auth widget and import-boundary fixture validation passed (21 tests). |
| UserProfile | `lib/features/user_profile/port/{user_profile,user_dto,auth_lifecycle,live_user_profile,guest_migration,composition,presentation_entry}.dart` | `AppUser`, `UserDTO`, `EnsureUserProfilePort`, `LiveUserProfilePort`, `UserProfileGuestMigrationPort`, `UserProfilePorts`, `createUserProfilePorts(UserProfileDependencyReader)`, sync contribution factory, and `UserProfilePresentationPage` with `UserProfilePresentationSession`/callbacks | app session lifecycle; Sync; profile screen | `composition.dart` is a pure public factory facade delegating only to `internal/factory/**`; app-owned Riverpod lifetime is in `app/workflows/session_lifecycle/user_profile_composition.dart`. The sole Flutter entry accepts explicit session state and actions and exports no Provider/Override. | **Current.** Owner factories assemble lifecycle, live-profile, guest-migration, update, and sync capabilities; routing renders the controlled entry through an app-owned adapter. Focused validation passed: `flutter test test/unit/app/session/app_session_test.dart test/unit/features/user_profile/presentation/view_model/user_profile_view_model_test.dart` (12 tests); the import-boundary checker reported no UserProfile violation (unrelated feature debt remains). |
| MyWord | `lib/features/my_word/port/{command,query,result,guest_migration,composition,presentation_entry}.dart` | MyWord commands/query/result, `MyWordGuestMigrationPort`, two `DatasetSyncHandler` factories, status entry | app composition; Sync; shared card/status shell | Command/query/result/migration and composition cannot expose Provider, DB/Firebase or internal DI; entry owns status command/effect boundary. | **Gap.** Port files exist, but `composition.dart` imports Riverpod and exports internal DI providers; `presentation_entry.dart` exports internal view-model/DI symbols. This is not the intended facade. |
| WordStatus | `lib/features/word_status/port/{word_status,commands,repository,guest_migration,composition,presentation_entry}.dart` | `WordStatus`, `UpdateWordStatusCommand`, `WordStatusRepository`, guest migration and dataset-handler factories, status entry | MyWord/shared card shell; Sync; app composition | No `DatabaseProvider`, Drift DAO/store or Firebase types in composition signature; presentation cannot export providers. | **Gap.** Public composition directly imports and accepts `DatabaseProvider`, constructs Drift stores/DAOs, and imports owner infrastructure. Presentation exports internal providers. This violates §2.1 and needs an owner pure factory seam. |
| Ranking | `lib/features/ranking/port/{filter,query,reader,result,ranking_query_repository,composition,presentation_entry}.dart`; `model/{ranking_query,ranking_page,ranking_list_item,load_rankings_input_data,update_ranking_filter_input_data,update_ranking_filter_output_data}.dart` | filter/query/page/result with table `rankingId`; `RankingReaderPort`; `createRankingComposition(IRankingQueryRepository)`; one entry | app composition; ranking screen; navigation callback to WordDetail | No database/framework/router imports in port models, reader or factory; presentation uses callback + `CatalogWordRef`. | **Gap.** Reader/factory and models exist. Presentation is an internal widget re-export; route/callback contract and exact `rankingId` characterization still need evidence. |
| WordDetail (`word_page`) | `lib/features/word_detail/port/{query,word_detail_query,word_detail_query_result,word_detail_view_data,i_load_word_detail_query,route,presentation_input,presentation_entry}.dart` | query/result/view data, `ILoadWordDetailQuery`, `WordDetailRoute`, `WordDetailPresentationInput` with optional ephemeral highlight | app routing; destination presentation | Models/routes pure; no GoRouter in feature. Navigation data is `CatalogWordRef` plus optional display/highlight hint. | **Partial.** Pure route/input/query types exist and route supports catalog + legacy `type` parsing. Presentation is an internal-widget re-export, so the planned controlled entry seam is still missing. |

## Cross-feature decisions and explicit blockers

1. Search and Quiz may receive Catalog data only through their owner gateway/source
   contracts.  They must not import Catalog Drift rows, SQL, or Catalog internal
   types.  Current Search uses `SearchCatalogGateway`; Quiz uses
   `CatalogRawQuizCandidateReaderPort`, which is the intended direction.
2. `CatalogWordRef` is the navigation identity shared by Search, Ranking,
   WordDetail, and Quiz.  Source features invoke a callback with that value and
   an optional display hint; they do not import destination routes.
3. Public composition must be pure.  The existing Auth, UserProfile, MyWord,
   and WordStatus composition files are recorded as non-conforming rather than
   grandfathered.  Their Provider/DatabaseProvider/imported-internal seams are
   P0 work, not accepted baseline.
4. The plan's canonical Quiz URL is `quiz-game/:catalog/:wordId?word=<hint>`;
   legacy is `quiz-game/:wordId?word=<hint>` with `CatalogId.espJpnMain`.
   Current implementation instead requires `catalog` as a query parameter and
   therefore cannot be claimed compliant.
5. The session key contract is owned by
   `lib/core/session/session_scope_key.dart`, not by a feature.  Its pure value
   (`accountScope`, `epoch`, value equality/hash) is present.  App workflow owns
   epoch activation and session fences; no feature port may expose `CurrentSession`
   or app workflow internals.

## P0 completion gate for this deliverable

- [x] Every planned feature has an owner, exact target paths, public signatures,
  consumer, and framework prohibition recorded above.
- [ ] Every recorded public surface conforms.  The rows marked `Gap`/`Partial`
  are the current P0 blockers; this manifest intentionally does not hide them.
- [ ] Composition and Sync proof tests, checker rules, and per-feature contract
  tests must be added before changing a `Gap`/`Partial` status to `Current`.
