# ADR 0004: Search public contract and Catalog requirement

## Status

Accepted

## Date

2026-08-13

## Decision owners

- Search
- Catalog
- `lib/integration/catalog_search`
- `app/bootstrap`
- app router

## Context

Search owns query interpretation, result projection, paging presentation, and
partial-failure policy. Catalog owns dictionary identity and facts. The current
Search implementation already preserves important behavior, but consumers deep
import individual Search port files and those files expose duplicate numeric IDs,
string failure sources, generic errors, and assertion-only validation.

Phase 0 found 27 existing Search tests: 6 port contract tests, 6 application and
legacy-use-case tests, 12 presentation tests, 2 Catalog adapter tests, and 1 Gate B
acceptance test. They remain characterization coverage while consumers migrate.

## Decision drivers

- Preserve current query, paging, warning, retry, route, and screen behavior.
- Make invalid public queries impossible in release builds.
- Keep `CatalogWordRef` as the single result identity.
- Distinguish empty data, optional metadata absence, primary failure, and partial
  enrichment failure.
- Keep Catalog conversion and runtime wiring outside Search business contracts.
- Allow a buildable migration without forcing application, integration,
  presentation, or composition consumers to switch in the same phase.

## Decision

`package:my_dic/features/search/port/search.dart` is the sole supported Search
business import. It explicitly exports pure Dart query, result, model, error,
reader, and required-gateway contracts. It does not export composition or
presentation seams.

`SearchQuery` and `SearchCatalogQuery` trim surrounding whitespace and reject
blank text, negative pages, and non-positive sizes with `ArgumentError` during
construction. Suggestion eligibility is Search-owned application policy and is
not a caller option in the new `SearchQuery`.

`SearchResultPage` always carries `SearchDirection` and Catalog's look-ahead fact
as `hasNext`, including for empty pages. Result and gateway collections are
defensively copied. `SearchResultItem` and conjugation suggestions carry only
`CatalogWordRef` as identity; Search does not duplicate `wordId` or map direction
to a `CatalogId`.

Primary page failures use `SearchReadError`. Recoverable enrichment failures use
`SearchIssue`, `SearchIssueSource`, and `SearchIssueError`. A missing optional
batch value remains `null` without a warning; a failed batch read is a typed
issue. Required gateway failures use
`SearchCatalogGatewayError` with `SearchCatalogOperation`, never a free-form
operation string.

The required `SearchCatalogGateway` keeps primary search, conjugation search,
meaning, frequency, and ranking as separate failure units. It returns only
Search-owned DTOs plus the shared Catalog-owned `CatalogWordRef`.

The existing application fetch limit of 4 conjugation suggestions and display
limit of 2 are retained as compatibility behavior. Changing either number is a
separate product decision, not part of the structural refactor.

Phase 2 fixes application characterization as follows:

- `[a-zA-Záéíóúñü]` selects Spanish-to-Japanese; otherwise direction is
  Japanese-to-Spanish;
- primary enrichment warnings are ordered meaning, ranking, frequency;
- a failed conjugation-page read follows primary warnings, while successful
  suggestion enrichment adds meaning, ranking, frequency in that order;
- a missing key in a successful optional-metadata batch stays `null` and does
  not produce a warning;
- `hasNext` is copied from `hasMore`, including exact-size terminal pages.

Phase 5 removed the old deep-import contracts after application, integration,
presentation, composition, and test consumers moved to the facade and a
repository-wide reference check reached zero.

## Ownership matrix

| Owner | Owns | Does not own |
|---|---|---|
| Catalog | `CatalogWordRef`, dictionary facts, source paging fact, persistence mapping | Search direction, warnings, suggestion and UI paging policy |
| Search | Query validation and direction, result projection, partial-failure policy, presentation paging and retry semantics | Catalog rows, SQL, serialization, dictionary fact precedence |
| `lib/integration/catalog_search` | Exhaustive value and error conversion between both public facades | Search warning policy, paging inference, Catalog storage access |
| `app/bootstrap` | Runtime instances, lifetime, Riverpod overrides | Query and failure semantics |
| app router | Navigation callback conversion | Search widget, provider, and view-model internals |

## Allowed dependency direction

```text
Search consumer --> search/port/search.dart <-- Search application adapter
                           |
                           +--> SearchCatalogGateway <-- lib/integration/catalog_search
                                                        |
                                                        +--> catalog/port/catalog.dart

app/bootstrap --> search/port/composition.dart                 (technical seam)
Search presentation wiring --> search/port/presentation_dependencies.dart
app router --> search/port/presentation_entry.dart
```

The Search facade may refer to `CatalogWordRef` but does not re-export it.
Consumers that name the shared identity import the Catalog facade separately.

## Compatibility constraints

This decision does not change direction detection, item ordering, `hasMore`
propagation, warning fallback, fetch/display limits, request fencing, retry
targets, route payloads, database schema, SQL, serialization, UI, or route paths.
Primary failure remains the only failure that discards the whole page.

The Phase 2 application characterization fixes direction boundaries, warning
order, missing-batch-key behavior, and exact-size paging before presentation and
integration consumers switch to the new service.

The 13 errors in the pre-refactor targeted Search analysis belonged to the
unreferenced legacy `judge_search_word/**` implementation. Phase 5 removed that
debt after the required zero-reference check; it is not an accepted analyzer
baseline for the completed Search slice.

## Consequences

Positive: new consumers have one pure Dart manifest, release-safe validation,
stable identity, explicit absence, and typed failures. Required gateway operations
remain independently recoverable.

Negative: consumers must migrate directly to the facade and cannot rely on old
deep-import compatibility definitions or typedef aliases.

## Rejected alternatives

1. Switching every existing consumer in this phase was rejected because it would
   combine public-contract work with application, presentation, integration, and
   composition behavior changes.
2. Keeping assertion-only validation was rejected because release builds would
   accept invalid query DTOs.
3. Re-exporting `CatalogWordRef` from Search was rejected because Catalog owns its
   identity and serialization.
4. Keeping a caller-controlled conjugation flag was rejected because eligibility
   is a Search application policy derived from direction and page.
5. Treating enrichment failures as primary failure was rejected because current
   behavior returns usable base results with warnings.

## Follow-up

- Keep application, Catalog adapter, presentation, and composition consumers on
  the Search facade; do not reintroduce deep-import or typedef compatibility paths.
- Keep Search covered by the generic canonical-facade and technical-seam
  boundary rules; do not add a Search-specific checker allowlist.
- Keep `docs/refactor-v0.3/search-public-surface.md` synchronized with the facade.
