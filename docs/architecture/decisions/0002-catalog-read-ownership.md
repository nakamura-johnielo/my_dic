# ADR 0002: Catalog read ownership and public surface

## Status

Accepted

## Date

2026-08-11

## Decision owners

- Catalog
- Search
- Quiz
- WordDetail
- Ranking

## Context

Catalog owns dictionary facts, but consumers historically imported individual
Catalog port files and implementation details. That made a file move observable
outside Catalog and allowed consumer policy to become coupled to Drift and Catalog
internals.

## Decision drivers

- Keep dictionary read semantics owned by Catalog.
- Let consumers own their query interpretation and presentation policy.
- Make the supported dependency direction mechanically checkable.
- Preserve current routes, schema, protocol, and user-visible behavior.

## Decision

`package:my_dic/features/catalog/port/catalog.dart` is the sole business-facing
Catalog import. It exports Catalog identity, read contracts, errors, queries,
results, and models. The still-active legacy detail and conjugation read contracts
are included until their consumers migrate; this is API compatibility, not
permission to deep-import their defining files.

Riverpod composition is a technical seam. Code that performs application wiring
may directly import `port/composition.dart`; presentation wiring may directly
import `port/presentation_dependencies.dart`. These files are not re-exported by
the pure-Dart facade.

Catalog internals are private. `lib/integration` adapters depend on feature public
ports only and translate between consumer-owned and Catalog-owned contracts.

## Ownership matrix

| Owner | Owns | Does not own |
|---|---|---|
| Catalog | Dictionary facts, identity, read contracts, persistence mapping | Search/Quiz policy, screen projection |
| Consumer feature | Query interpretation, warnings, paging/presentation policy | Catalog storage and internal models |
| `lib/integration` | Contract translation | Feature domain truth, DAO/Drift implementation |
| `app/bootstrap` | Runtime wiring | Catalog business semantics |

## Allowed dependency direction

```text
consumer feature --> catalog/port/catalog.dart <-- Catalog internal adapter
       |                         ^
       +--> consumer port <------|-- lib/integration adapter

app/bootstrap --> catalog/port/composition.dart       (technical seam)
presentation wiring --> catalog/port/presentation_dependencies.dart (technical seam)
```

No production source outside Catalog may import `catalog/internal/**`. No
business consumer may import an individual file below `catalog/port/**`.

## Compatibility constraints

This decision does not change database schema, SQL results, routes, serialization,
sync protocol, screen behavior, or error semantics. Import migration is mechanical.
The legacy `CatalogReader` and `ConjugationReader` remain exported while active.

## Consequences

Positive: consumers compile against one manifest, internal movement is hidden,
and automated checks can reject regressions.

Negative: the facade temporarily exposes both the newer focused reader ports and
two legacy contracts. Technical Riverpod seams remain explicit exceptions.

## Rejected alternatives

1. Exporting Catalog internals was rejected because it would turn implementation
   details into supported API.
2. Re-exporting Riverpod wiring from `catalog.dart` was rejected because it would
   make every business consumer depend on Flutter/Riverpod.
3. Keeping unrestricted deep imports was rejected because code review alone did
   not reliably preserve the boundary.

## Follow-up

- Keep the public manifest in `docs/refactor-v0.3/public-surface.md` synchronized
  with `port/catalog.dart`.
- Remove the legacy detail/conjugation exports only after their consumers migrate.
- Run both import-boundary checkers in CI and keep their baselines at zero for
  these rules.
