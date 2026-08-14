# ADR 0005: Sync runtime ownership and public surface

## Status

Accepted

## Date

2026-08-13

## Decision owners

- Sync
- Dataset feature owners
- app/bootstrap

## Context

Sync contracts were consumed through individual `port/**` files and composition
used an opaque generic lookup. Feature-specific payload and remote semantics are
still present and cannot be relocated safely in the same structural phase.

## Decision drivers

- Keep the synchronization protocol and observable behavior unchanged.
- Make workflow, dataset SPI, and composition consumers explicit.
- Make runtime dependencies compiler-checked and visible in factory signatures.
- Preserve dataset feature ownership of payload and conflict semantics.

## Decision

`sync.dart` is the sole business facade. `dataset_contract.dart` is the limited
pure-Dart SPI for dataset owners and technical tests. `composition.dart` is the
app-bootstrap-only typed seam. Sync composition uses immutable
`SyncDependencies` and returns a completed `SyncComposition` capability bundle;
it does not accept an Object-keyed generic resolver.

`DatasetSyncRecord` contains generic metadata plus an owner-supplied typed apply
operation; it contains no `Object` payload. Dataset owners build the generic
remote document plan, including document path, identity fields, and encoded
field values. The Firebase executor owns only transaction and acknowledgement
mechanics. UserProfile owns its provisioning transaction and DTO mapping.

## Ownership matrix

| Owner | Owns | Does not own |
|---|---|---|
| Sync | execution plan, queue, checkpoint, retry, cancellation, scheduling, telemetry, generic outcomes | feature payload, field masks, conflicts, provisioning |
| Dataset feature | payload/mapper, remote/local adapter, conflict and ack meaning | generic retry, queue, checkpoint, scheduler |
| app/bootstrap | database/session runtime, Provider lifetime, completed handler registry, runner disposal | sync algorithm and dataset semantics |

## Allowed dependency direction

```text
app workflow -> sync.dart
dataset owner internal/composition -> dataset_contract.dart
app/bootstrap -> composition.dart -> sync internal composition factory
```

Sync feature code must not import app/Riverpod. App bootstrap must not import
Sync internal implementation.

## Compatibility constraints

This decision does not change dataset ID/order, queue lease/coalesce/ack/retry,
checkpoint/cursor boundaries, retry/backoff, session cancellation, report
precedence, telemetry values, Firestore/schema/wire data, manual sync, guest
migration, routes, or UI.

## Consequences

Dependencies become explicit and external import intent is reviewable. During
the staged migration, individual definition files remain in place even though
new consumers use only the facade or SPI.

## Rejected alternatives

- A catch-all business barrel was rejected because it would expose technical
  dataset and composition contracts to workflows.
- Keeping the Object-keyed resolver was rejected because key/type agreement was
  only checked by runtime casts.
- Moving payload and remote semantics now was rejected because it belongs to
  protocol-sensitive later phases.

## Follow-up

- `DatasetSyncGateway` is the dataset operation contract; owner implementations
  use the `*DatasetSyncService` name.
- `sync.dart`, `dataset_contract.dart`, and `composition.dart` remain the only
  allowed external Sync surfaces for their respective consumer roles.
