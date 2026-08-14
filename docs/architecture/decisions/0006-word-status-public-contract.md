# ADR 0006: WordStatus public contract

Status: accepted

WordStatus exposes separate read, watch, batch-read, and command ports through
the sole pure-Dart facade. Query/command values contain typed guest/account
scope and `CatalogWordRef`. Caller timestamps are excluded; an injected clock
preserves the existing UTC persistence/outbox timestamp semantics.

Missing row means all flags false and no persisted timestamp. Batch reads
deduplicate by word in first-input order, return initial facts for missing rows,
and accept empty input. Infrastructure may chunk SQL, but the public contract
has no consumer policy or arbitrary maximum.

`CatalogRankingEntryRef` remains Catalog ranking-row identity. WordStatus status
identity is account scope × `CatalogWordRef`, so repeated ranking entries share
one status fact. Ranking retains filtering, paging, grouping, and warnings.

Repository abstractions are internal and DB rows/errors are normalized at the
provided port. The legacy repository/command libraries were removed after
references reached zero. Schema, wire, Sync stable IDs/order, cursor
comparisons, guest migration, routes, UI, and successful no-op behavior do not
change.

## Composition and presentation follow-up

Application and Sync assembly use immutable typed dependency bundles with
required named factories. Database, an SDK-free remote-document gateway, remote mutation executor,
outbox writer, clock, and Sync runtime are constructor dependencies. The former
generic dependency reader, opaque keys, and `as T` casts are not part of the
WordStatus composition path.

App bootstrap owns completed capability lifetime. Internal presentation
providers consume the completed ports passed by the controlled entry (or the
public presentation dependency seam during migration); app bootstrap no longer
overrides an internal repository Provider. Internal Providers and view models
are not part of `presentation_entry.dart`.

The Firestore implementation of the remote-document gateway is app-owned
integration code. WordStatus retains ownership of nested collection names,
wire fields, the inclusive cursor, and the document-ID tie-break. The public
composition seam exposes one canonical internal factory bridge.
