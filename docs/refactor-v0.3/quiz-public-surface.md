# Quiz public surface

Business consumers import only:

```dart
import 'package:my_dic/features/quiz/port/quiz.dart';
```

The facade contains pure-Dart candidate and game contracts, typed errors,
focused reader ports, Quiz-owned Catalog required ports, and routing inputs.
It never exports Flutter, Riverpod, Drift, internal implementation types, or
wire-keyed maps.

Technical seams are deliberately separate: bootstrap may import
`composition.dart` and `presentation_dependencies.dart`; routing may import
`presentation_entry.dart`. Riverpod is permitted only in
`presentation_dependencies.dart` for focused-reader wiring.

`lib/integration/catalog_quiz` adapts Catalog facade values to Quiz required
ports and imports `quiz.dart` only. It does not own candidate paging,
enrichment warnings, game policy, assets, persistence, DAO, Drift, or Flutter
presentation.

See [ADR 0003](../architecture/decisions/0003-quiz-public-facade.md).

