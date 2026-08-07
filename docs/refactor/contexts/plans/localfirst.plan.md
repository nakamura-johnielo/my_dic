## Plan: MyWord/MyWordStatus account scoping + guest統合(Local-first 7 Stage4)

word statusで確立したaccountId scopingパターンをMyWord/MyWordStatusへ適用し（Phase A）、その後guest→account transactional移管機能を新規構築する（Phase B）。3つの設計判断はユーザー回答済み: 競合解決=boolean ORマージ、通知=sign-in直後モーダル、cancel後=毎回再通知。

**Steps**

### Phase A: MyWord/MyWordStatus real accountId scoping
1. drift_my_word_dao.dart — `getMyWordById`、`getFilteredMyWordByPage`、`getIdsFilteredMyWordByPage`、`insertMyWordWithRevision`、`updateMyWordWithRevision`、`tombstoneMyWord`（子`myWordStatus`削除も同accountId）、`streamMyWordById`、`applyRemoteFields`に`accountId`引数追加。`insertMyWord`/`updateMyWord`/`deleteMyword`/`getMyWordsAfter`/`watchMyWordIdsAfter`は旧sync専用（`sync_my_word_interactor copy.dart`のみ消費）のため触らない。
2. [`drift_my_word_status_dao.dart`](lib/features/my_word/data/data_source/local/drift_my_word_status_dao.dart) — `watchWordStatus`、`getWordStatus`、`applyStatusPatch`、`applyRemoteFields`に`accountId`追加。`updateStatus`/`exist`/`insertStatus`は旧sync_myword_status_usecase.dart専用のため触らない。
3. *(depends on 1-2)* datasource interface/実装（i_my_word_local_data_source.dart、my_word_drift_data_source.dart、status側同様）へ同じ引数を通す。
4. *(depends on 3)* Repository層 — `IMyWordRepository`/`MyWordRepository`の`getById`/`getFilteredByPage`/`getIdsFilteredByPage`/`watchMyWord`に`required String accountId`追加。`registerWord`/`updateWord`/`deleteWord`は既存の`input.userId`（nullable）シグネチャを維持し、内部で`accountId ?? guestAccountScope`をDAO呼び出し用に解決（outbox enqueue可否は従来どおり`userId != null`）。`IMyWordStatusRepository.watchStatus`も同様に`accountId`追加。
5. *(depends on 4)* Usecase — `LoadMyWordInteractor`/`WatchMyWordInteractor`/`WatchMyWordStatusInteractor`に`CurrentSession`注入し、`accountIdOrNull ?? guestAccountScope`を解決。
6. *(depends on 5)* DI — usecase_di.dartの該当providerへ`ref.watch(currentSessionProvider)`注入。view_model_di.dartの`_myWordStatusStreamProvider`/`_myWordStreamProviderNEW`を`ref.read`→`ref.watch`に修正（account切替時の再購読、word status側と同パターンへ揃える）。
7. Sync handler — my_word_sync_handler.dart/my_word_status_sync_handler.dartのpullループの`applyRemoteFields`呼び出しに`accountId: context.accountId`追加。
8. Test — 既存my_word_sync_handler_test.dart/my_word_status_sync_handler_test.dartの直接DAO呼び出しにaccountId追加。新規`my_word_account_scope_test.dart`（word status版と同構成: 2 account分離・guest分離・interactor scope解決）。

### Phase B: Guest検出・transactional移管・UI（*depends on Phase A完了*）
新規`lib/app/guest_migration/`モジュール（`app/session`/`app/bootstrap`と同じcomposition-root配置、feature間import境界を汚さない）。

1. `GuestDataSummary`モデル（esp_jpn/jpn_esp word status・myWords・myWordStatusの有無。User Profileはguestスコープが構造上存在しないため対象外）。
2. `DetectGuestDataUseCase` — 4 datasourceへ`guestAccountScope`で問い合わせ。
3. `MigrateGuestDataUseCase` — target accountIdを受け1つのDrift transactionで: word status系はguest/account両rowがあればboolean ORマージ+outbox upsert、なければre-key；MyWordはre-key（myWordIdはUUIDのため実質衝突なし、衝突時はaccount側を残しguestをskip）；MyWordStatusはMyWord後に同様のORマージ。全mutationは既存`OutboxWriter`/`SyncMutation`契約を再利用。
4. *(depends on 3)* DI — `lib/app/bootstrap/guest_migration_composition.dart`で各feature既存datasource provider + `driftOutboxWriterProvider` + `databaseProvider`から合成。
5. *(depends on 4)* UI — `GuestDataMigrationDialog`（承認/cancel）+ `ref.listen(appSessionProvider)`で`AppSessionReady`検知→`DetectGuestDataUseCase`→非空ならdialog表示。app.dartの既存`builder`Stack（`DatabaseLoadingOverlay`と同じ場所）にフック。root navigator context確保のため`app/routing/router.dart`のnavigatorKey有無を要確認。
6. 承認時: `MigrateGuestDataUseCase`実行→`syncSchedulerProvider.foreground(...)`即時push。cancel時: 何もしない（次回また聞く）。
7. Test — detect/migrate usecaseの単体test（ORマージ、MyWord re-key、outbox enqueue、二重実行no-op）。

**Relevant files**
- drift_my_word_dao.dart / drift_my_word_status_dao.dart — accountId引数追加の中心
- my_word_repository.dart / my_word_status_repository.dart — scope解決ロジック
- usecase_di.dart / view_model_di.dart — CurrentSession注入・watch化
- my_word_sync_handler.dart / my_word_status_sync_handler.dart — pullのaccountId引き渡し
- account_scope.dart — 既存`guestAccountScope`を再利用（新規定数不要）
- `lib/app/guest_migration/**`（新規）、`lib/app/bootstrap/guest_migration_composition.dart`（新規）、app.dart — Phase B新規モジュール

**Verification**
1. Phase A: `flutter test test/unit/features/my_word/ test/unit/features/sync/`、`dart run check_import_boundaries.dart --baseline baseline.json --check`、`flutter analyze`対象dir
2. Phase B: 新規`test/unit/app/guest_migration/`一式、import境界チェック再実行

**Decisions**
- 競合解決: boolean field(isLearned/isBookmarked/hasNote)はOR結合。MyWord本体はUUID entityIdのため実質衝突なし→単純re-key。
- 通知: `AppSessionReady`直後モーダルダイアログ。cancel後も毎回再通知（dismiss記録なし）。
- migration IDレジャーは設けない: migration成功後はguest rowが物理的に残らないため再実行は自然にno-op。UIの二重タップは確認ボタンの実行中disableでガード。
- MyWord/MyWordStatusの**旧sync専用メソッド**（`insertMyWord`/`updateMyWord`/`deleteMyword`/`updateStatus`/`exist`等）はLocal-first 6 Stage1の前例に倣い変更しない。

**Further Considerations**
1. OR結合後のeditAtは「移行実行時刻(now)」を使う想定です（outbox payloadのタイムスタンプ整合のため）。guest/account元のeditAtのmaxを使うべきという要望があれば教えてください。
2. User Profileはguestスコープの行が構造上存在しない（`ensureUserProfile`はsigned-in専用）ためPhase Bの移管対象外、という理解で進めます。異なる認識があれば教えてください。

