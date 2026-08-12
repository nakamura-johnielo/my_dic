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
- `MyWordCommandPort`, `MyWordStatusCommandPort`, and `MyWordReaderPort`
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

## Private surface

Everything below `features/my_word/internal/**` is private. This includes
entities, repositories, use-case interfaces and input data, data sources,
Drift/Firebase implementations, providers, UI models, and presentation views.
None of those types is re-exported by a MyWord business contract.

Guest migration is an app-owned cross-feature workflow. The public migration
port owns only MyWord aggregate counts and migration; transactions and session
fencing remain with the app.
