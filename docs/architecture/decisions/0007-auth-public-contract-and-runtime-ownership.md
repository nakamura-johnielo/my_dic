# ADR 0007: Auth public contract and runtime ownership

## Status

Accepted

## Date

2026-08-13

## Decision owners

Auth and app bootstrap.

## Context

Auth business consumers deep-imported individual contracts, while Auth's
factory discovered `FirebaseAuth.instance` and feature-owned Riverpod wiring
assembled its graph.

## Decision drivers

- One pure business facade
- Explicit Query/Command capabilities and typed identity
- App-owned SDK lifetime and overrides
- No authentication, session, route, UI, or error behavior change

## Decision

Auth exposes `features/auth/port/auth.dart` as its sole business facade.
`AuthDependencies` requires an SDK-free, app-owned `AuthRuntimeGateway`; the
internal factory injects that handle into Auth's repository, and `AuthPorts` is
the completed capability bundle. `lib/app/bootstrap/firebase_providers.dart`
owns the Firebase implementation and SDK lifetime, while
`auth_composition.dart` rebuilds the bundle through `ref.watch`.

The external-system adapter converts Firebase identities and exceptions only
into SDK-free transport facts. Auth remains the owner of provider-ID and
failure-code interpretation, including all existing user-facing errors.

## Ownership matrix

| Owner | Owns | Does not own |
|---|---|---|
| Auth | credentials, identity and verification facts, error mapping | usable-session phases, profiles, routes |
| app session workflow | session/profile composition | Firebase mapping |
| app bootstrap | SDK instance and completed-capability lifetime | Auth semantics |

## Allowed dependency direction

`app/bootstrap Firebase adapter -> auth/port/composition -> auth/internal
factory`, business consumers `-> auth/port/auth.dart`, and app routing
`-> auth/port/presentation_entry.dart`.

## Compatibility constraints

Validation, trimming, SDK order, error codes/messages, stream behavior,
session phases, routes, and UI remain unchanged.

## Consequences

Auth internal code has no SDK singleton discovery or Riverpod service locator.
Password reset uses the same Auth CommandPort and repository error mapping as
the other credential operations.

## Rejected alternatives

Keeping individual public ports or passing a generic dependency resolver would
retain deep imports and runtime casts.

## Enforcement

The shared checker has Auth-specific positive and negative fixtures for the
sole facade, pure composition, canonical internal factory, Firebase boundary,
and routing-owned presentation entry.
