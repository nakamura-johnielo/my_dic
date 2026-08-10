# DB runtime decision — P0 / A-DB1

## Decision

Adopt P0 option 1: retain `lib/core/infrastructure/database/drift/` as the
neutral physical database runtime and move only physical Drift table
declarations into its `tables/` directory. A-DB1 is deliberately limited to
annotation/table ownership; feature DAO registration, generated getter removal,
feature DI, and feature DAO path moves remain with A-DB2/A-DB3 and their
respective owners.

## Options considered

| Option | Minimal patch considered | Result |
|---|---|---|
| 1. Neutral core runtime | Move `MyWords`, `MyWordStatus`, and `Rankings` table declarations into core; retain names and schema; feature DAOs construct directly from `DatabaseProvider`. | Adopted for A-DB1. |
| 2. Feature descriptor | Keep the static Drift annotation but introduce feature descriptors for registration. | Rejected: it does not remove the core-to-feature schema declaration edge and adds a registration abstraction before it is needed. |
| 3. App registration | Make app the schema registration adapter and inject pure factories. | Rejected: requires an exact app/internal exception and expands the A-DB1 scope into composition work. |

## Applied A-DB1 patch

- Added core table declarations:
  - `lib/core/infrastructure/database/drift/tables/my_words.dart`
  - `lib/core/infrastructure/database/drift/tables/my_word_status.dart`
  - `lib/core/infrastructure/database/drift/tables/rankings.dart`
- Deleted the equivalent feature-owned declarations:
  - `lib/features/my_word/data/data_source/local/my_words.dart`
  - `lib/features/my_word/data/data_source/local/my_word_status.dart`
  - `lib/features/ranking/data/data_source/local/rankings_entity.dart`
- Updated `DatabaseProvider`, `MyWordDao`, `MyWordStatusDao`, and `RankingDao`
  to import the core declarations.

No schema version, migration, seed, executor, table SQL, Dart table class,
data class, companion, primary key, foreign key, or constraint was changed.
`@DriftDatabase.daos` is intentionally unchanged: removing feature DAO getters
is A-DB3 work, not A-DB1 work.

## Import graph

Before this patch the neutral runtime imported physical table declarations from
the MyWord and Ranking features:

```text
core DatabaseProvider -> feature MyWords / MyWordStatus / Rankings declarations
feature MyWordDao / RankingDao -> same feature declarations
```

After this patch the physical declarations are core-owned:

```text
core DatabaseProvider -> core MyWords / MyWordStatus / Rankings declarations
feature MyWordDao / RankingDao -> core declarations
```

The remaining core-to-feature DAO imports in `database_provider.dart` are the
pre-existing generated-DAO registration edge. They are explicitly reserved for
A-DB3; this change adds no new core-to-feature import edge.

## Generated type and SQL evidence

`dart run build_runner build --delete-conflicting-outputs` completed
successfully. Drift regenerated its outputs, but the resulting Git diff contains
no generated-file change for this move. This is expected because the three Dart
table class names, `@DataClassName` values, columns, constraints, and
`@DriftDatabase(tables:)` membership are unchanged. Therefore there is no
emitted SQL/type rename or schema diff attributable to A-DB1.

## Baseline evidence

| Baseline | Command / test | Result |
|---|---|---|
| fresh-native | `flutter test test/unit/core/infrastructure/database/drift/local_first_schema_test.dart` | Passed: fresh in-memory v7 creation, composite account key, CHECK rejection, and tombstone persistence. |
| migration-native | `flutter test test/unit/core/infrastructure/database/drift/database_provider_migration_test.dart` | Passed: v1–v6 fixture upgrade cases, rollback, and v6 outbox value migration. |
| feature schema consumers | MyWord schema-sync and Ranking Drift query tests in the same targeted command | Passed (20 tests total with the two core suites). |
| asset-upgrade-native | `flutter test test/integration/database/native_database_reuse_test.dart` | Passed. The test copies the real `assets/kotobank.db`, opens it as v3, invokes the production `copyAssetDbOnce` → `ATTACH` → insert path against the real `assets/es_en_conjugacions.db`, verifies 6517 rows, verifies the temporary attached file is deleted, and reopens the upgraded database without duplicate seed data. The application-support directory is a test-only temporary MethodChannel result. |
| fresh-web / existing-web | `flutter test --platform chrome test/integration/database/web_database_reuse_test.dart` | Test added: it removes `my_dic_db`, opens the production Wasm/IndexedDB runtime for a fresh seed, writes a sentinel, then reopens and reads it. The first run exposed and fixed a test-helper `dart:html` API compile error. A later 15-minute command attempt reached the runner's 12-minute test heartbeat timeout while the first fresh-seed test was still running (`TimeoutException after 0:12:00.000000`); no legacy case started. It remains unverified. |

## Adoption and rejection rationale

Option 1 removes the A-DB1 schema declaration imports from core to MyWord and
Ranking while preserving the current Drift static schema and runtime behaviour.
It is the smallest change that is independently testable. Options 2 and 3 are
rejected for this slice because they require registration/composition changes
that belong to later A-DB work and would obscure whether the table move itself
preserved the schema.

## Checker exceptions

No checker exception was added by A-DB1. The deleted schema-declaration edges
were exact paths listed above. The remaining pre-existing DAO registration
imports are not waived here; their removal is tracked by A-DB3.

## Baseline test additions and remaining Web limitation

`test/integration/database/native_database_reuse_test.dart` is the real native
asset reuse baseline described above. `test/integration/database/web_database_reuse_test.dart`
is a browser-only fresh/created-existing IndexedDB baseline; its helper deletes
only the test database name before and after the test.

The Web test now includes an independent v1–v7 legacy-schema creator in
`test/support/database/web_legacy_schema_creator.dart`. It uses `WasmDatabase`
and raw SQL only; it does not import `DatabaseProvider` or production table
declarations. v2/v3 are explicitly v1-schema aliases because no separate
historical schema exists in this repository. Each case creates a sentinel,
opens the current production runtime, asserts migration to v7 and no Web
`es_en_conjugacions` duplicate seed, then reopens it. The cases are compiled
and statically analyzed, but were not reached in Chrome because the preceding
fresh seed hit the runner heartbeat timeout. No production schema/migration
code was changed to create a test seam.

### Legacy-only Chrome attempt

To exclude the fresh seed, the legacy cases were run directly with:

```powershell
flutter test --platform chrome --name "opens v" test/integration/database/web_database_reuse_test.dart
```

The command produced no runner test output and exceeded the five-minute command
timeout (`Exit code 124`, `command timed out after 304043 milliseconds`). Thus
the filtered v1–v7 cases did not produce a pass/fail result in this environment.
This is distinct from the fresh-seed 12-minute heartbeat timeout, but it leaves
the same Web migration/reopen baseline unverified. The test source is analyzer
clean; diagnosing the browser/Wasm startup hang requires a Chrome test
environment with observable runner output.
