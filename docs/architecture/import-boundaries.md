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

The checkers discover strict features from the canonical
`features/<feature>/port/<feature>.dart` facade. A feature does not need to
create composition or presentation seams it does not use. When one of
`composition.dart`, `presentation_dependencies.dart`, or
`presentation_entry.dart` exists, its caller and purity rules are enforced
independently. Composition files are always checked for Provider types, opaque
generic resolvers, and `as T` casts, even before a feature has every optional
seam.

Both commands are production architecture gates and deliberately scan
`lib/**`, not every file below `test/**`. The public-surface manifests describe
production consumers. Tests follow the separate policy in
`feature-design-rules.md`: public contract and cross-feature tests use the
manifested facade/seams, while focused same-feature tests may use white-box
internal imports. Scanning all tests as production consumers would reject that
documented characterization strategy and is therefore not used as a shortcut
for enforcing the manifests.

## Sync dataset SPI

`features/sync/port/sync.dart` is Sync's sole business facade.
`features/sync/port/dataset_contract.dart` is a separate, limited technical SPI:
dataset-owner composition/infrastructure may implement it, and app/bootstrap,
`lib/app/infrastructure` external-system executors, plus `lib/integration/sync`
may register or execute the completed capability. Application, domain,
presentation, arbitrary app business code, unrelated
integration code, and arbitrary Sync deep ports may not consume it. This
exception is structural and does not enumerate dataset feature names.

## Catalog boundary

Business code outside `lib/features/catalog/**` imports Catalog only through:

```dart
import 'package:my_dic/features/catalog/port/catalog.dart';
```

The only direct public-port exceptions are technical wiring seams:

- `features/catalog/port/composition.dart` for application composition

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

## Ranking boundary

Business consumers import Ranking only through
`features/ranking/port/ranking.dart`. App bootstrap may import
`composition.dart` and `presentation_dependencies.dart`; app routing and
acceptance tests may import `presentation_entry.dart`. External Ranking
internal and deep business-port imports are forbidden.

The pure adapters under `lib/integration/catalog_ranking` and
`lib/integration/word_status_ranking` import only participating feature
facades. Their `*_providers.dart` files own Riverpod wiring; filter, grouping,
paging, warnings, SQL, and provider internals remain excluded. See
[ADR 0008](./decisions/0008-ranking-public-contract.md) and the
[Ranking public surface manifest](../refactor-v0.3/ranking-public-surface.md).

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

## Search boundary

Business consumers import Search only through
`features/search/port/search.dart`. The generic strict-surface rules discover
the canonical facade and its three technical seams from the feature layout;
they do not use a Search-specific allowlist.

- `composition.dart`: app bootstrap or an integration `*_providers.dart` /
  `*_composition.dart` wiring file
- `presentation_dependencies.dart`: app bootstrap and same-feature
  presentation
- `presentation_entry.dart`: app routing and acceptance tests

External Search internal and deep business-port imports are forbidden. Pure
integration adapters import only the participating feature facades and cannot
import framework or storage SDK packages. Search composition may reach only its
same-feature canonical composition factory and may not expose Provider types,
runtime casts, or Object-based dependency resolvers. This is feature-generic:
the only feature-internal composition target is
`internal/composition/<feature>_composition_factory.dart`. SDK-free shared
technical contracts belong under `core/port/**`; Firebase SDK imports belong
only to external-system `infrastructure/firebase/**` paths (plus the explicit
Firebase bootstrap setup files).

## WordDetail boundary

Business consumers import WordDetail only through
`features/word_detail/port/word_detail.dart`. App bootstrap may use
`composition.dart` and `presentation_dependencies.dart`; app routing may use
`presentation_entry.dart`. External internal imports and deep business-port
imports are forbidden.

`lib/integration/catalog_word_detail` imports only the Catalog and WordDetail
facades and remains framework-free. Catalog owns source-markup interpretation;
WordDetail receives semantic content and must not import Catalog DTO/readers or
WordStatus/Quiz internals. See [ADR 0010](./decisions/0010-word-detail-public-contract.md)
and the [WordDetail public surface manifest](../refactor-v0.3/word-detail-public-surface.md).
