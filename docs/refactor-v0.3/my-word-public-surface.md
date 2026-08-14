# MyWord public surface

The sole business-facing import for MyWord is:

```dart
import 'package:my_dic/features/my_word/port/my_word.dart';
```

## Facade manifest

`my_word.dart` exports only these pure Dart business contracts:

- shared `Result<T>` and `FieldUpdate<T>`
- register, update, delete, and partial-status-update commands
- page-load and single-item-watch queries
- `MyWord`, `MyWordStatus`, and `MyWordItem` immutable snapshots
- `MyWordCommandPort`, `MyWordStatusCommandPort`, and `MyWordQueryPort`
- `MyWordGuestMigrationPort` and `MyWordGuestRowCounts`

The source of truth for exact Dart exports is
`lib/features/my_word/port/my_word.dart`. Consumers must not deep-import the
individual contract files.

## Technical seams

The following files are deliberately excluded from the business facade and are
for controlled technical wiring only:

- `port/composition.dart`
- `port/presentation_entry.dart`

`composition.dart` is an app-bootstrap seam and `presentation_entry.dart` is
an app-routing seam. They are not business imports and must not be used as
general-purpose public barrels.

The composition seam exposes immutable, SDK-free dependency bundles. Remote
reads use the core nested-account-document gateway and writes use Sync's
dataset SPI. The seam delegates only to the single owner factory
`internal/composition/my_word_composition_factory.dart`; Firestore concrete
types and operations remain in app bootstrap.

## Private surface

Everything below `features/my_word/internal/**` is private. This includes
entities, repository contracts and records, local stores, remote gateways,
Drift/Firebase implementations, providers, UI models, and presentation views.
None of those types is re-exported by a MyWord business contract.

The application boundary is implemented by one `MyWordApplicationService`.
The retired `I*UseCase`, `*InputData`, interactor, and dead watch-use-case graph
is not part of either the public or private supported surface.

Guest migration is an app-owned cross-feature workflow. The public migration
port owns only MyWord aggregate counts and migration; transactions and session
fencing remain with the app.
