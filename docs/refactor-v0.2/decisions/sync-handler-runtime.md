# Sync handler runtime — P0 / A-SYNC

## Decision

`DatasetSyncAdapter` remains the feature-owned wire/local mapping seam, while
`SyncHandlerRuntimeAdapter` owns leasing, acknowledgement, retry/backoff,
error classification, execution fencing, remote apply, and checkpoints. A
feature handler is only `AdapterDatasetSyncHandler(adapter, runtime)`.

The public workflow result is the framework-free `SyncRunOutcome`: `success`,
`retryScheduled`, `nonRetryableFailure`, or `cancelled`. Report interpretation remains
inside Sync internal.

## Evidence

`sync_handler_runtime_contract_test.dart` runs a MyWord-dataset shaped fake
adapter through the real runtime. It fixes:

- handler-to-runtime delegation without policy objects entering the adapter;
- retryable remote failure becoming a durable queue retry with backoff while
  its checkpoint remains unchanged;
- remote records being applied with pending field masks and the greatest cursor
  checkpointed atomically through the adapter transaction seam;
- epoch cancellation preventing queue, remote, and checkpoint side effects.

The test uses only Sync port/internal types. It neither imports nor changes a
MyWord owner file. Existing queue, classifier, backoff, execution-guard, and
workflow/report tests continue to own their narrower contracts.
