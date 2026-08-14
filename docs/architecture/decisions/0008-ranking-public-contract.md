# ADR 0008: Ranking public contract and read ownership

## Status

Accepted

## Date

2026-08-13

## Decision owners

- Ranking
- Catalog
- WordStatus

## Context

The legacy Ranking DAO joins Catalog and WordStatus tables and exposes raw
account strings, `FeatureTag`, physical integers, and database failures through
its query path. Ranking nevertheless owns the screen-specific interpretation
of filters, grouping, paging, and status absence. Catalog already provides a
ranked-entry feed and WordStatus already provides account-scoped batch reads.

## Decision drivers

- Keep source facts and persistence interpretation with their owner features.
- Preserve current item order, filtering, grouping, paging, and `hasMore`.
- Give Ranking one pure-Dart public import and typed failure boundary.
- Keep migration buildable while presentation and composition still use the
  legacy query path.

## Decision

`package:my_dic/features/ranking/port/ranking.dart` is the sole business-facing
Ranking import. It exposes a typed account scope, filter snapshot, page query,
item identity and projection, page result, read errors, sole page reader, and
the two consumer-owned required gateways.

Ranking owns part-of-speech and status include/exclude interpretation. Multiple
included statuses are OR conditions; include and exclude groups combine with
AND. Missing status facts use WordStatus's defined all-false absence semantics.
Part-of-speech and status filters are applied before offset paging. Grouping is
enabled only by `groupByCatalogWord`; otherwise distinct ranking rows for the
same word remain distinct.

Catalog source order is `rankingNo`, then `CatalogRankingEntryRef`. The
integration adapter copies that opaque serialized identity into
`RankingItemId` without interpreting it. Grouping keeps the first entry in this
deterministic order. Ranking scans source chunks from offset zero until it has
the requested filtered offset plus `size + 1` items, and derives `hasMore` only
from that filtered look-ahead.

Catalog and WordStatus integration adapters are pure value/error translators.
They import only the participating feature facades and contain no filter,
grouping, paging, SQL, framework, or warning policy. Provider failures become
Ranking-owned gateway errors and the application service normalizes them to
`RankingReadError`.

The legacy cross-owner Drift projection was retained only until presentation
and app composition migrated, then removed together with its duplicate
repository, pass-through use cases, DTOs, and internal Riverpod DI.

## Ownership matrix

| Owner | Owns | Does not own |
|---|---|---|
| Catalog | ranking source row, `CatalogRankingEntryRef`, word facts, feed order and source look-ahead | Ranking filter, grouping, page, warning, or UI policy |
| WordStatus | account/guest scoped learned, bookmarked, and note facts; missing-row semantics | Ranking candidate selection, paging, grouping, or warnings |
| Ranking | typed query, filter interpretation, grouping, page formation, projection, errors | provider persistence, schema, or sync lifecycle |
| `lib/integration` | public DTO, identity, scope, and error translation | business filtering, paging, SQL, provider internals |
| `app/bootstrap` | runtime adapter and service lifetime wiring | Ranking read semantics |

## Allowed dependency direction

```text
Ranking application --> ranking/port/ranking.dart
       ^                         ^
       |                         |
Catalog facade --> catalog_ranking adapter
WordStatus facade --> word_status_ranking adapter

app/bootstrap --> integration adapters --> Ranking composition (later phase)
```

No Ranking application/domain code imports Catalog or WordStatus internals.
Integration adapter bodies import only feature facades. The business facade is
pure Dart and does not export composition or presentation seams.

## Compatibility constraints

This decision changes no schema, asset/sync protocol, route, screen design, or
write behavior. Pages remain zero-based and sizes positive. Invalid source rows
are not converted to sentinels.

## Consequences

Positive: Ranking policy is testable without Drift, cross-feature ownership is
explicit, and public contracts no longer require raw `FeatureTag`, account
strings, `Object`, magic integers, or database errors.

Negative: deep pages scan from the first Catalog source chunk, and both read
paths coexist temporarily. A materialized projection or cursor requires a
separate ADR and schema/performance decision.

## Rejected alternatives

1. Keeping the cross-owner JOIN as the final implementation was rejected
   because it makes Ranking interpret other owners' storage.
2. Filtering inside integration adapters was rejected because adapters would
   acquire consumer policy.
3. Treating `items.length == size` as `hasMore` was rejected because exact-size
   final pages would be reported incorrectly.
4. Reusing `FeatureTag` and raw account strings was rejected because unrelated
   UI/storage vocabulary would remain in the public Ranking contract.

## Follow-up

- Keep presentation and app composition on `RankingPageReaderPort`.
- Keep legacy repository, DAO, DTO, generated-part, and deep-import references
  at zero.
- Keep Ranking covered by the generic strict-surface and integration checks.
- Measure deep-page scan cost against the shipped asset before considering a
  separate materialized-projection ADR.
