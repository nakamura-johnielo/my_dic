# Import boundaries

Feature境界の設計原則、portとintegrationの責務、移行・review手順は
[Feature設計ルール](./feature-design-rules.md)を参照する。この文書は、その原則を
import checkerでどう強制するかを説明する。

`tool/check_import_boundaries.dart` prevents architectural import regressions.
Rules are defined in `tool/import_boundaries/rules.json`; generated Dart sources
are excluded. Both `package:my_dic/...` and relative imports are recognized,
including Windows-style separators.

Run locally:

```powershell
dart run tool/check_import_boundaries.dart --baseline tool/import_boundaries/baseline.json --check
```

```powershell
dart run tool/check_feature_dependencies.dart 
```

The baseline contains each pre-existing violation together with its rule ID,
source, target, introduction date, owner, and tracking issue. CI fails when a
violation is added or a baseline entry disappears. Update it deliberately:

```powershell
dart run tool/check_import_boundaries.dart --baseline tool/import_boundaries/baseline.json --update-baseline
```

Use `--format=json` for machine-readable output and replace default ownership
metadata before committing new baseline entries.

## Catalog boundary

Business code outside `lib/features/catalog/**` imports Catalog only through:

```dart
import 'package:my_dic/features/catalog/port/catalog.dart';
```

The only direct public-port exceptions are technical wiring seams:

- `features/catalog/port/composition.dart` for application composition
- `features/catalog/port/presentation_dependencies.dart` for presentation wiring

External imports of `features/catalog/internal/**` are forbidden. Code under
`lib/integration/**` may import feature public ports, but not a feature's internal,
DAO, Drift row, or infrastructure implementation. Catalog's facade remains pure
Dart; Riverpod is limited to the two technical seam files above.

See [ADR 0002](./decisions/0002-catalog-read-ownership.md) and the
[Catalog public surface manifest](../refactor-v0.3/public-surface.md).

## Quiz boundary

Business code outside `lib/features/quiz/**` imports Quiz only through:

```dart
import 'package:my_dic/features/quiz/port/quiz.dart';
```

Bootstrap may use `composition.dart` and `presentation_dependencies.dart`;
routing may use `presentation_entry.dart`. The presentation dependency seam
may import Riverpod, but the business facade remains pure Dart. External Quiz
internal imports are forbidden. `lib/integration/catalog_quiz` imports the
Quiz facade only and must not import Quiz internal/DAO/Drift/Flutter APIs.
See [ADR 0003](./decisions/0003-quiz-public-facade.md) and the
[Quiz public surface manifest](../refactor-v0.3/quiz-public-surface.md).

## MyWord boundary

Business consumers outside `lib/features/my_word/**` import MyWord only through:

```dart
import 'package:my_dic/features/my_word/port/my_word.dart';
```

The only external technical seams are `port/composition.dart`, used by
`app/bootstrap`, and `port/presentation_entry.dart`, used by `app/routing`.
External imports of `features/my_word/internal/**` and deep business-port
imports are forbidden. The MyWord facade and its business contract files are
pure Dart; composition and presentation entry are deliberately controlled
wiring boundaries.
