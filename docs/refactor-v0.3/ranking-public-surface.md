# Ranking public surface

Business consumers import only:

```dart
import 'package:my_dic/features/ranking/port/ranking.dart';
```

## Facade manifest

The facade exports these pure-Dart contract groups:

- shared `Result<T>` and Catalog-owned `CatalogId` / `CatalogWordRef` identity
- `RankingPageReaderPort` and validated `RankingPageQuery`
- typed `RankingAccountScope`, `RankingFilter`, `RankingStatusFilter`, and
  `RankingPartOfSpeech`
- `RankingItemId`, `RankingItem`, and immutable `RankingPage`
- `RankingReadError` and `RankingReadFailureKind`
- consumer-owned `RankingCatalogGateway` contracts and typed gateway errors
- consumer-owned `RankingWordStatusGateway` contracts and typed gateway errors

The defining files below `port/**` are not supported external imports. The
source of truth for exact exports is `lib/features/ranking/port/ranking.dart`.

## Semantics

Pages are zero-based and size is positive. Filter collections are immutable
value snapshots. Status includes use OR, exclusions reject any selected status,
and the include/exclude groups combine with AND. Missing batch keys are initial
all-false status facts. Filtering and optional Catalog-word grouping happen
before offset paging; `hasMore` comes from one filtered look-ahead item.

`RankingItemId` preserves the serialized value of Catalog's opaque ranking-row
identity. Source order is rank followed by that identity. Duplicate words stay
as separate items unless `groupByCatalogWord` is selected.

## Technical seams and migration

The following are not facade exports:

- `port/composition.dart`: immutable `RankingDependencies` and the factory for
  completed `RankingPorts`
- `port/composition_contract.dart`: completed pure-Dart capability bundle
- `port/presentation_dependencies.dart`: app-owned Riverpod dependency for the
  completed ports
- `port/presentation_entry.dart`: controlled `RankingFragment` Flutter entry

The legacy query/repository DTOs, pass-through use cases, internal Riverpod DI,
and cross-owner Drift projection have been removed. Presentation consumes the
new reader and typed filter directly. App routing supplies the WordStatus
renderer through its controlled public entry and receives only
`CatalogWordRef` navigation callbacks.

Everything below `features/ranking/internal/**` is private. Pure adapters in
`lib/integration/catalog_ranking` and `lib/integration/word_status_ranking`
translate only between participating feature facades and contain no framework,
storage, filter, grouping, or paging policy.
