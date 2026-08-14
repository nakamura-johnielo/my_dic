# Search public surface

The sole business-facing import for Search is:

```dart
import 'package:my_dic/features/search/port/search.dart';
```

## Facade manifest

`search.dart` exports only these pure Dart contracts:

- shared `Result<T>`, `Success<T>`, and `Failure<T>`
- `SearchReaderPort` and validated `SearchQuery`
- `SearchDirection`
- `SearchResultPage`, `SearchResultItem`, and
  `SearchConjugationSuggestion`
- `SearchConjugationMatchKey`, `SearchMoodTense`, and `SearchSubject`
- `SearchReadError` variants and typed `SearchIssue` values
- `SearchCatalogGateway` and its validated query, pages, hits, focused metadata,
  typed operation, and gateway error

`CatalogWordRef` is the only cross-feature identity admitted to these contracts.
Search deliberately does not re-export it; consumers that name it import
`package:my_dic/features/catalog/port/catalog.dart`.

The source of truth for exact exports is
`lib/features/search/port/search.dart`. A business type must be added there before
external use. New consumers must not deep-import the defining files.

## Contract semantics

- query text is trimmed and blank text fails synchronously
- pages are zero-based and sizes are positive
- `SearchResultPage.direction` is present even when `items` is empty
- `hasNext` preserves Catalog's look-ahead fact and is not inferred from item count
- optional metadata absence and missing batch keys are `null`; failed batch reads
  are typed issues
- only a typed `SearchReadError` represents failure of the primary Search page
- result and gateway lists/maps are immutable defensive copies
- result identity is `CatalogWordRef`; no duplicate raw `wordId` is exposed

## Technical seams

These files are excluded from the business facade:

- `port/composition.dart`: app composition only
- `port/presentation_dependencies.dart`: Search presentation wiring only
- `port/presentation_entry.dart`: app routing and acceptance entry only

They may expose framework types only for their controlled wiring role.

## Removed compatibility surface

Phase 5 completed the application, integration, presentation, and composition
switches. The old `port/query.dart`, `port/reader.dart`,
`port/catalog_gateway.dart`, duplicate model/error definitions, legacy use cases,
and legacy Catalog adapter are removed after a repository-wide reference check.
Consumers use `search.dart`; app wiring uses only the technical composition and
presentation seams listed above.

## Automated boundary status

Both boundary checkers discover Search through its canonical facade and three
technical seams. Fixtures cover external internal/deep-port imports,
integration facade-only use, exact composition and presentation bridges,
technical-seam caller restrictions, framework leakage, and opaque dependency
resolvers. The completed production Search paths have zero findings under these
generic rules; no baseline entry or Search-specific allowlist is used.

## Private surface

Everything below `features/search/internal/**` is private. Search consumers and
`lib/integration/catalog_search` must not import it. Catalog-to-Search translation
uses the Catalog and Search facades only after the Phase 3 adapter switch.
