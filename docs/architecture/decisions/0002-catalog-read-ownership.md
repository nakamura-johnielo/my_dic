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
Catalog import. It exports Catalog identity, focused read contracts, errors,
queries, results, and models. Legacy detail and conjugation contracts were
removed after every consumer migrated to the focused QueryPorts.

Riverpod composition is outside Catalog. Code that performs application wiring
may directly import the framework-free `port/composition.dart` technical seam.
It is not re-exported by the pure-Dart facade. Catalog no longer publishes a
presentation dependency seam because no Catalog presentation consumer exists.

Catalog internals are private. `lib/integration` adapters depend on feature public
ports only and translate between consumer-owned and Catalog-owned contracts.

Catalog also owns the identity and lifecycle of each ranking source row.
`CatalogRankingEntryRef` is the opaque public value object for the positive
`rankings.ranking_id` persisted in a shipped Catalog dataset. It serializes as
that integer, identifies a ranking entry rather than a word, and remains stable
for the lifetime of the dataset row. Renumbering it during an asset replacement
is an identity migration and requires a separate compatibility decision. Feed
order is `ranking_no`, then `CatalogRankingEntryRef`; duplicate word rows remain
distinct.

Raw dictionary markup remains an internal storage/source format. The focused
semantic detail reader converts it to Catalog-owned content nodes that preserve
hierarchy, semantic roles, emphasis, line breaks, links, and images. Consumers
receive this structured contract and do not parse or render raw HTML strings.
The semantic detail reader is the contract for semantic consumers; the focused
entry-detail QueryPort remains available for consumers that need the typed
direction-specific entry model.

## Ownership matrix

| Owner | Owns | Does not own |
|---|---|---|
| Catalog | Dictionary facts, word and ranking-entry identity, semantic content, read contracts, persistence mapping | Search/Quiz/Ranking/WordDetail policy, screen projection |
| Consumer feature | Query interpretation, warnings, paging/presentation policy | Catalog storage and internal models |
| `lib/integration` | Contract translation | Feature domain truth, DAO/Drift implementation |
| `app/bootstrap` | Runtime wiring | Catalog business semantics |

## Allowed dependency direction

```text
consumer feature --> catalog/port/catalog.dart <-- Catalog internal adapter
       |                         ^
       +--> consumer port <------|-- lib/integration adapter

app/bootstrap --> catalog/port/composition.dart       (technical seam)
```

No production source outside Catalog may import `catalog/internal/**`. No
business consumer may import an individual file below `catalog/port/**`.

## Compatibility constraints

This decision does not change database schema, routes, sync protocol, or screen
behavior. The ranking feed reads the existing
source rows in ranking order with a stable identity tie-break and one-row
look-ahead.

## Consequences

Positive: consumers compile against one manifest, internal movement is hidden,
and automated checks can reject regressions.

Negative: consumers must select a focused QueryPort rather than rely on one
catch-all reader. The composition seam remains an explicit technical entry.

## Rejected alternatives

1. Exporting Catalog internals was rejected because it would turn implementation
   details into supported API.
2. Re-exporting Riverpod wiring from `catalog.dart` was rejected because it would
   make every business consumer depend on Flutter/Riverpod.
3. Keeping unrestricted deep imports was rejected because code review alone did
   not reliably preserve the boundary.

## Follow-up

- Apply the generalized [Feature design rules](../feature-design-rules.md) when
  migrating other features; Catalog remains the reference implementation.
- Keep the public manifest in `docs/refactor-v0.3/public-surface.md` synchronized
  with `port/catalog.dart`.
- Run both import-boundary checkers in CI and keep their baselines at zero for
  these rules.
