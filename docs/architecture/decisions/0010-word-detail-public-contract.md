# ADR 0010: WordDetail public contract and aggregation ownership

## Status

Accepted

## Date

2026-08-13

## Decision owners

- WordDetail
- Catalog
- WordStatus
- Quiz

## Context

WordDetail previously exposed Catalog DTO and raw HTML, assembled its reader
through presentation DI, represented optional failures with a generic issue,
and delegated legacy route interpretation to app routing. This coupled screen
aggregation to provider storage and leaked internal contracts to callers.

## Decision drivers

- Keep dictionary facts and source markup interpretation with Catalog.
- Keep aggregation, partial-failure, capability, and route policy with WordDetail.
- Preserve the shipped route, screen, tab, status, Quiz, and failure behavior.
- Provide one pure-Dart business import and narrow technical seams.

## Decision

`features/word_detail/port/word_detail.dart` is the sole business facade.
WordDetail owns its typed query/result/data/issues/errors and its required
`WordDetailCatalogGateway`. The gateway keeps dictionary and conjugation reads
separate. Dictionary failure is primary failure; conjugation failure is a typed
issue attached to usable primary data.

Catalog owns source HTML interpretation and exposes semantic content. The pure
`catalog_word_detail` adapter performs value and typed-error translation only.
WordDetail presentation renders semantic blocks and receives WordStatus as an
injected widget capability. It passes only `CatalogWordRef` and an optional
display hint to the Quiz navigation callback.

`WordDetailRoute` owns canonical and legacy serialization. App routing parses
the typed route and builds the controlled `WordDetailEntry`; it does not
interpret legacy direction strings.

## Ownership matrix

| Owner | Owns | Does not own |
|---|---|---|
| Catalog | dictionary identity/facts, conjugation facts, source-to-semantic mapping | WordDetail warnings, tabs, route, status/Quiz capability |
| WordDetail | aggregation, typed failures/issues, empty policy, route and presentation capability policy | Catalog persistence/source format, WordStatus mutation, Quiz game |
| `lib/integration` | facade-to-facade value/error translation | HTML parsing, warning, empty, tab, FAB, route policy |
| `app/bootstrap` | adapter/service lifetime and presentation capability wiring | WordDetail read or display semantics |
| `app/routing` | GoRouter registration and callbacks | legacy type interpretation or detail aggregation |

## Allowed dependency direction

```text
Catalog facade --> catalog_word_detail adapter --> WordDetail gateway
                                                    |
app/bootstrap --> WordDetail composition -----------+
                                                    v
app/routing --> WordDetail controlled entry --> WordDetail presentation
                                              --> injected WordStatus entry
                                              --> pure Quiz callback
```

## Compatibility constraints

The canonical `word/:wordId?catalog=...` route, supported legacy `type`, ignored
`hasConj`, ephemeral highlight, primary/optional failure split, UI text, tab
order, status mount condition, Quiz condition, schema, assets, and sync protocol
remain unchanged.

## Consequences

WordDetail can be tested without Catalog storage or Riverpod, and provider
models no longer leak into its public contract. The adapter contains explicit
semantic value mapping, which must evolve when either public contract changes.

## Rejected alternatives

1. Copying raw HTML into the WordDetail contract was rejected because source
   interpretation belongs to Catalog.
2. Combining dictionary and conjugation into one gateway operation was
   rejected because it would erase the established partial-failure boundary.
3. Importing WordStatus or Quiz internals was rejected because controlled
   entries and callbacks express the required capabilities.

## Follow-up

- Keep legacy WordDetail contracts and deep imports at zero.
- Keep the generic strict-facade, technical-seam, and pure-integration checker
  fixtures green without adding baseline exceptions.
