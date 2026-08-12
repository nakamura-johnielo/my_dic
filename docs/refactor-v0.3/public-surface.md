# Catalog public surface

The sole business-facing import is:

```dart
import 'package:my_dic/features/catalog/port/catalog.dart';
```

## Facade manifest

`catalog.dart` exports these contract groups:

- shared `Result<T>`
- identity: `CatalogId`, `CatalogWordRef`
- reader bundle and focused reader ports
- search and conjugation queries, hits, matches, and paged results
- entry detail, direction-specific entry models, frequency, part of speech,
  ranking metadata, and read errors
- active compatibility contracts: `CatalogReader`, `ConjugationReader`

The source of truth for exact Dart exports is
`lib/features/catalog/port/catalog.dart`. Public types must be added there before
external use; consumers must not deep-import their defining files.

## Technical seams

The following are deliberately separate and may be imported only for their stated
wiring role:

- `port/composition.dart`: Riverpod application composition
- `port/presentation_dependencies.dart`: Riverpod presentation dependencies

They are not business APIs and are not exported by `catalog.dart`.

## Private surface

Everything below `features/catalog/internal/**` is private, including domain
entities, repositories, Drift DAO/query/reader implementations, mappers, data
sources, and composition factories. `lib/integration` translates only between
public feature contracts.
