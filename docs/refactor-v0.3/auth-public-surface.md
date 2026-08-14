# Auth public surface manifest

Auth owns credential operations and the authenticated identity facts reported
by Firebase Auth. Session readiness, profile provisioning, routing, and UI
policy remain owned by the app session workflow.

## Sole business facade

Business consumers import only:

```dart
import 'package:my_dic/features/auth/port/auth.dart';
```

The facade exports `AuthIdentity`, `AuthProvider`, `AuthQueryPort`,
`AuthCommandPort`, credential command DTOs, `Result`, and the typed errors
already produced by Auth. It does not export composition or presentation
seams and remains free of Flutter, Riverpod, and Firebase types.

## Composition-only surface

Only `app/bootstrap` and focused composition tests import
`features/auth/port/composition.dart`. `AuthDependencies` requires the pure
`AuthRuntimeGateway` technical handle, and `AuthPorts` is the immutable
completed bundle of query and command capabilities. The Firebase-backed data
source and its SDK lifetime stay in app bootstrap's external-system boundary;
the Auth feature still owns provider-ID and failure-code interpretation.

## Presentation surface

`presentation_entry.dart` exposes only the controlled Widget, state, and
callback contracts. Presentation-only Riverpod wiring receives the completed
`AuthCommandPort` through `presentation_dependencies.dart`; no Provider is
re-exported by the business facade or presentation entry.

## Behavior constraints

The migration does not change trimming, validation, error code/message,
Firebase SDK operation order, auth-state stream errors, verification/reload,
sign-out, password reset, session phases, routes, or UI behavior.

## Automated enforcement

The shared boundary checkers include Auth-specific fixtures for sole-facade
imports, pure composition, canonical factory delegation, and routing-owned use
of the controlled presentation entry.
