# Sync public surface manifest

Sync owns the generic execution runtime. Dataset payload meaning, mapping,
conflict rules, and provisioning remain owned by each dataset feature.

## Sole business facade

Business workflows import only:

```dart
import 'package:my_dic/features/sync/port/sync.dart';
```

The facade exports `CancellationToken`, `SyncContext`, `SyncRunner`,
`SyncRunOutcome`, `SyncReasonCodes`, `SessionFence`, and the stable outbox
write contract (`OutboxWriter`, `SyncMutation`). It does not export dataset or
composition seams.

## Dataset SPI

Dataset owner composition/infrastructure and technical contract tests may
import `features/sync/port/dataset_contract.dart`. It exports the existing
dataset gateway/handler/runtime, queue/checkpoint/outbox, remote-mutation,
telemetry, cursor, mutation, lease, result, and report contracts without
changing their protocol. App workflow and presentation code must not use this
SPI.

`DatasetSyncRecord` carries only generic ordering/checkpoint metadata and an
owner-supplied typed apply operation. Feature DTOs never cross this SPI as
`Object`, and the runtime performs no payload cast.

## Composition-only surface

Only `app/bootstrap` and focused composition tests may import
`features/sync/port/composition.dart`. `SyncDependencies` explicitly requires a
database and session fence. `SyncComposition` is the immutable completed bundle
of queue, checkpoint store, outbox writer, and handler runtime capabilities.

## Private/internal candidates

Everything under `features/sync/internal/**` is Sync-private. The individual
definition files below `port/**` remain source files during the staged import
migration; external consumers must use the facade or allowed SPI above.

## Compatibility constraints and deletion conditions

- Do not change dataset stable IDs/order, dependency plan, queue semantics,
  checkpoint/cursor boundaries, retry classification/backoff, cancellation,
  report/outcome precedence, telemetry allowlist, schema, wire values, session,
  route, or UI behavior.
- Remove an individual external deep import only after its consumer compiles
  through `sync.dart` or `dataset_contract.dart`.
- The dataset operation contract is `DatasetSyncGateway`; implementations are
  named `*DatasetSyncService`.
- Dataset owners encode their own document path, identity fields, and wire
  values into a generic `RemoteMutationDocument`. The Firebase executor owns
  only transaction and acknowledgement mechanics.
- UserProfile owns its provisioning transaction and DTO interpretation.
