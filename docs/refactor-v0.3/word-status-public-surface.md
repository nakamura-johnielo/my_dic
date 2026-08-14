# WordStatus public surface

Business consumers import only `features/word_status/port/word_status.dart`.
It exports pure-Dart status/scope models, single and batch queries, scoped
update command, read/watch/batch ports, command port, batch result, typed
errors, `Result`, `FieldUpdate`, Catalog identity, and guest migration.

Missing rows are successful all-false statuses with `updatedAt == null`.
Unchanged commands succeed without clock or persistence access. Changed
commands receive one UTC application-clock timestamp. Empty batches succeed;
duplicates collapse in first-input order; all requested words are returned and
missing rows become initial statuses. Batch identity is `CatalogWordRef`; no
Ranking filter, paging, warning, or candidate policy is included.

The legacy public repository, command library, and use-case shims have been
removed after their references reached zero. Guest migration is exposed by the
facade as `WordStatusGuestMigrationPort`. Schema, wire values, Sync IDs/order,
the Esp-Jpn `>=` boundary, and Jpn-Esp `>` boundary remain unchanged.

## Technical seams

- `port/composition.dart` accepts immutable `WordStatusDependencies` and
  `WordStatusSyncDependencies`, and returns completed `WordStatusPorts` or
  direction-specific Sync handlers. It contains no opaque resolver or Firebase
  SDK type. Remote reads use an SDK-free nested-document gateway.
- `port/composition_contract.dart` defines the completed reader, watcher,
  batch-reader, command, guest-migration bundle and its clock contract.
- `port/presentation_dependencies.dart` is the app-owned Riverpod dependency
  seam for the completed bundle.
- `port/presentation_entry.dart` exports the controlled buttons entry, but not
  internal components, Providers, or view-model declarations.

The app registry watches completed WordStatus Sync handler providers; it does
not construct WordStatus DAOs, stores, remote adapters, or dataset services.
Ranking uses the WordStatus batch port through a pure integration adapter;
WordDetail, Quiz, and Ranking receive the controlled status renderer from app
routing rather than importing WordStatus presentation internals.
