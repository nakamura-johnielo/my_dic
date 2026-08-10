# Gate A 実装サマリー

## ステータス

Gate A のリファクタリングが完了しました。

今回の作業では、意図的にプロダクトの挙動を変更することなく、パッケージの所有権と依存関係の方向を整理しました。

次の挙動変更を伴う作業は Gate B に属します。

## 変更内容

### データベースとコンポジション

* MyWord、MyWordStatus、Ranking の Drift テーブル定義を、`core/infrastructure/database/drift/tables` 配下に移動しました。
* `DatabaseProvider` は中立的なデータベースランタイムのみを保持するようになりました。Core のデータベースアノテーションから Feature DAO の登録を削除し、Quiz の `EsEnConjugacionDao` は Feature 側が所有するようになりました。
* Core のデータ DI は、データベースのライフサイクル管理のみを担当するようになりました。Catalog DAO の構築は純粋な Catalog composition facade の背後に置き、Drift の配線処理は内部に隠蔽しました。

### Feature の境界

以下の Feature は、公開する `port/` の範囲を小さくし、application、infrastructure、presentation、composition の実装を `internal/` に保持する構造になりました。

* Catalog
* Search
* Quiz
* Auth
* UserProfile
* MyWord
* Ranking
* WordStatus
* WordDetail

また、

* Search と Quiz は、raw かつ provider-neutral な capability を通して Catalog を利用するようになりました。
* Catalog は、Search や Quiz のどちらも import しなくなりました。
* Search / Quiz のポリシー、ページネーション、エンリッチメント、警告、ゲーム集計は、app の composition ではなく、それぞれの所有 Feature 内に残しました。
* Sync は公開された port contract と内部 runtime を持つようになりました。
* Dataset 固有の adapter は MyWord、UserProfile、WordStatus がそれぞれ所有します。
* retry、queue、checkpoint、cancellation、execution policy は Sync runtime が所有します。

### Session、Firebase、App の所有権

* `SessionScopeKey` と session epoch coordinator により、ライフサイクル、Sync の fencing、ゲストデータの移行、Feature provider の再キー化を一元的に管理する App 所有の session scope を提供するようになりました。
* Auth lifecycle は `core/application` から `app/workflows/session_lifecycle` に移動しました。この workflow は Auth と UserProfile の port のみに依存します。
* Firestore の mutation は、純粋な Sync-port である `RemoteMutationExecutor` を使用するようになりました。Firebase の transaction と wire mapping は app integration 内に配置しました。
* Firebase SDK の読み取りは、各 Feature の正規の `internal/infrastructure/**/firebase/**` ディレクトリと、app executor に限定しました。
* Composition factory は SDK の型を直接 import する代わりに、opaque dependency を受け取るようになりました。
* router graph、navigation state、redirect、named route、invalid route handling は `app/routing` 配下で App が所有するようになりました。
* Feature は pure な route contract と中立的な navigation payload のみを提供します。

### Presentation と Route

* 以前の `app/presentation` に存在していた Search の card / view-model / status facade を削除しました。
* Feature に依存しない `SearchResultCardShell` を `core/ui` に配置し、各 Feature が自身の wrapper と status entry の配線を所有するようにしました。
* Word status と MyWord の command/effect state は、それぞれの所有者である Feature の presentation entry で組み立てるようになりました。
* WordDetail は、任意の Search highlight を `WordDetailPresentationInput` 経由で受け取るようになり、Search の presentation state を直接読み取らなくなりました。
* Route DTO は pure Dart になりました。
* Source Feature は destination Feature の route port や GoRouter を import しなくなりました。
* App routing が `CatalogWordRef` と任意の display hint を具体的な route に変換します。

### 最終的なパス整理

* `features/word_page` を `features/word_detail` に変更しました。

  * `WordDetailLoadKey`
  * view model / state / provider 名
  * generated reference
  * test
    などの公開型も含めて変更しています。
* `features/user` を `features/user_profile` に変更しました。

  * generated path
  * import
    も含めて変更しています。
* 以下の不要なものを削除しました。

  * legacy `lib/router`
  * core router DI
  * app route-contract shim
  * 古い presentation facade
  * obsolete provider alias
  * Quiz の未使用だったトップレベル `di`、`presentation`、`consts` path
* Catalog の未使用 write API と、古い MyWord local API surface は、利用箇所が存在しないことを確認したうえで削除しました。
* ただし、以下の Sync path は引き続き維持されています。

  * revision
  * tombstone
  * outbox
  * ack
  * remote-apply

## Boundary の成果

最終的なソース構造では、以下の依存方向が強制されます。

```text
app -> feature port -> feature internal
app -> core
feature internal -> feature port/core
feature A -X-> feature B internal or route contract
core -X-> feature
feature -X-> app
```

特に、最終スキャンによって以下を確認しました。

* Feature から App への import が存在しない
* App / Core から Feature の internal implementation への import が存在しない
* 古い `word_page`、`user`、`lib/router`、app-presentation facade の caller が存在しない
* Feature presentation から GoRouter への依存、および Feature 間の route-port 依存が存在しない
* Firebase SDK の import は、正規の Firebase infrastructure path にのみ存在する

## 検証記録

今回の最終実装パスでは、依頼された作業範囲に従い、以下のテストは意図的に実行していません。

* unit test
* widget test
* integration test
* browser test
* Chrome test

一方、静的チェックは実行され、すべて正常に完了しました。

| チェック                    | 結果                  |
| ----------------------- | ------------------- |
| `dart analyze`          | 問題なし                |
| `flutter analyze`       | 問題なし                |
| import boundary checker | 違反 0 件              |
| `git diff --check`      | 成功（CRLF warning のみ） |

Import boundary rule は、新しい正規 Firebase SDK location を反映するためだけに更新しました。

違反を無視するために baseline を拡張したわけではありません。

Web database の baseline は、この作業中に明示されたプロジェクト方針に基づき、検証済みとして扱っています。

過去に行われた command-level の調査と、その環境上の制約については、`decisions/db-runtime.md` に記録されています。

## 意図的に対象外としたもの

* Gate A では、以下を意図的に変更していません。

  * schema
  * migration
  * seed
  * SQL table definition
  * persisted wire contract
* 挙動修正や新しいプロダクト機能は追加していません。これらの変更は Gate B で行います。
* テスト実行については、プロジェクト側で完全な検証スイートを実行することを選択した際に、後続の品質確認作業として実施する必要があります。





---

# Gate A implementation summary

## Status

Gate A refactoring is complete. The work reorganizes package ownership and
dependency direction without intentionally changing product behaviour. The
next behaviour-changing work belongs to Gate B.

## What changed

### Database and composition

- Physical Drift table declarations for MyWord, MyWordStatus, and Ranking now
  live under `core/infrastructure/database/drift/tables`.
- `DatabaseProvider` retains only the neutral database runtime. Feature DAO
  registration was removed from the core database annotation; the Quiz
  `EsEnConjugacionDao` is feature-owned.
- Core data DI now owns database lifecycle only. Catalog DAO construction is
  behind a pure Catalog composition facade, with Drift wiring kept internal.

### Feature boundaries

The following features now expose a small `port/` surface and keep application,
infrastructure, presentation, and composition implementation in `internal/`:

- Catalog, Search, Quiz, Auth, UserProfile, MyWord, Ranking, WordStatus, and
  WordDetail.
- Search and Quiz consume Catalog through raw, provider-neutral capabilities;
  Catalog no longer imports either consumer feature.
- Search/Quiz policy, pagination, enrichment, warnings, and game aggregation
  remain in their owning feature rather than app composition.
- Sync has a public port contract and an internal runtime. Dataset-specific
  adapters are owned by MyWord, UserProfile, and WordStatus; retry, queue,
  checkpoint, cancellation, and execution policy are runtime-owned.

### Session, Firebase, and app ownership

- `SessionScopeKey` and the session epoch coordinator provide one app-owned
  session scope for lifecycle, sync fencing, guest migration, and feature
  provider re-keying.
- Auth lifecycle moved from `core/application` to
  `app/workflows/session_lifecycle`. The workflow depends only on Auth and
  UserProfile ports.
- Firestore mutations use the pure Sync-port `RemoteMutationExecutor`; the
  Firebase transaction and wire mapping live in app integration.
- Firebase SDK reads are limited to each feature's canonical
  `internal/infrastructure/**/firebase/**` directory (plus the app executor).
  Composition factories receive opaque dependencies instead of importing SDK
  types.
- The router graph, navigation state, redirects, named routes, and invalid
  route handling are now app-owned under `app/routing`. Features supply pure
  route contracts and neutral navigation payloads only.

### Presentation and routes

- The former `app/presentation` Search card/view-model/status facades were
  removed. A feature-neutral `SearchResultCardShell` lives in `core/ui`; each
  feature owns its wrapper and status entry wiring.
- Word status and MyWord command/effect state are assembled by their owner
  presentation entries.
- WordDetail consumes its optional search highlight through
  `WordDetailPresentationInput`; it no longer reads Search presentation state.
- Route DTOs are pure Dart. Source features no longer import destination
  feature route ports or GoRouter; app routing converts `CatalogWordRef` and
  optional display hints into concrete routes.

### Final path cleanup

- `features/word_page` was renamed to `features/word_detail`, including public
  types such as `WordDetailLoadKey`, view model/state/provider names, generated
  references, and tests.
- `features/user` was renamed to `features/user_profile`, including generated
  paths and imports.
- The legacy `lib/router`, core router DI, app route-contract shims, old
  presentation facades, obsolete provider aliases, and unused Quiz top-level
  `di`, `presentation`, and `consts` paths were removed.
- Unused Catalog write APIs and obsolete MyWord local API surface were removed
  only after confirming callers were absent. Revision, tombstone, outbox, ack,
  and remote-apply sync paths remain intact.

## Boundary outcomes

The final source structure enforces these directions:

```text
app -> feature port -> feature internal
app -> core
feature internal -> feature port/core
feature A -X-> feature B internal or route contract
core -X-> feature
feature -X-> app
```

In particular, final scans confirmed:

- no feature-to-app imports;
- no app/core imports of feature internal implementation;
- no old `word_page`, `user`, `lib/router`, or app-presentation facade callers;
- no feature presentation GoRouter or cross-feature route-port dependency; and
- Firebase SDK imports are in canonical Firebase infrastructure paths only.

## Verification record

The final implementation pass intentionally did **not** run unit, widget,
integration, browser, or Chrome tests, per the requested scope. Static checks
were run and completed successfully:

| Check | Result |
|---|---|
| `dart analyze` | No issues found |
| `flutter analyze` | No issues found |
| import boundary checker | 0 violations |
| `git diff --check` | Success (CRLF warnings only) |

The import-boundary rules were updated only to reflect the new canonical
Firebase SDK locations; the baseline was not expanded to waive violations.

The Web database baseline is treated as verified based on the explicit project
direction given during this work. The historical command-level investigation
and its environment limitations are recorded in
[`decisions/db-runtime.md`](decisions/db-runtime.md).

## Deliberate non-goals

- No schema, migration, seed, SQL table definition, or persisted wire contract
  was intentionally changed by Gate A.
- No behaviour fix or new product behaviour was introduced; those changes are
  reserved for Gate B.
- Test execution is still required as a follow-up quality activity when the
  project elects to run the full verification suite.
