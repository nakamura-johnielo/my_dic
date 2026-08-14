# WordDetail public surface

The sole business-facing import is:

```dart
import 'package:my_dic/features/word_detail/port/word_detail.dart';
```

It exports the shared `CatalogId`/`CatalogWordRef` identity, typed query and
result, direction-specific immutable detail values, semantic content,
conjugation values, typed issues/errors, `WordDetailReaderPort`, the
consumer-owned `WordDetailCatalogGateway`, route serialization, and the pure
presentation input. It exports no Flutter, Riverpod, GoRouter, Catalog DTO,
raw HTML, internal implementation, or compatibility alias.

Technical seams are deliberately separate:

- `port/composition.dart` accepts `WordDetailDependencies` and returns the
  framework-free `WordDetailPorts` bundle.
- `port/presentation_dependencies.dart` is the reader injection point.
- `port/presentation_entry.dart` exposes the controlled `WordDetailEntry`
  widget, typed WordStatus renderer callback, and Quiz callback without
  exporting an internal widget or provider.

`CatalogBackedWordDetailGateway` is a pure adapter. It imports the Catalog and
WordDetail facades only and translates owner-provided semantic nodes and typed
errors. Primary dictionary and optional conjugation remain separate failure
units. Missing conjugation is successful `null`; conjugation failure becomes a
typed issue while preserving primary detail.

`WordDetailRoute` owns canonical `catalog` serialization and supported legacy
`type=espJpn|jpnEsp` parsing. `hasConj` remains ignored and highlight remains
ephemeral presentation input.

The removed legacy surface has no compatibility shim: `ILoadWordDetailQuery`,
`WordDetailQueryResult`, `WordDetailViewData`, the old query barrel and loader,
Catalog-backed presentation DI, raw HTML renderer, and duplicate old tests.
