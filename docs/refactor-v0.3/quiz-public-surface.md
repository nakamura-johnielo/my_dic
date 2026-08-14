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

`composition.dart` accepts an immutable `QuizDependencies` bundle containing
the two Catalog gateways, database runtime, and bundled-asset text loader, and
returns the completed `QuizPorts` contract. Quiz's internal factory owns the
DAO, typed infrastructure readers, and application services; bootstrap imports
no Quiz internals.

Asset and Drift wire keys are interpreted once inside Quiz infrastructure.
Their readers return `QuizEnglishPromptGuide`, `QuizBeConjugation`, and
`QuizEnglishConjugation`, never wire-keyed maps.

`lib/integration/catalog_quiz` adapts Catalog facade values to Quiz required
ports and imports `quiz.dart` only. It does not own candidate paging,
enrichment warnings, game policy, assets, persistence, DAO, Drift, or Flutter
presentation.

See [ADR 0003](../architecture/decisions/0003-quiz-public-facade.md).
