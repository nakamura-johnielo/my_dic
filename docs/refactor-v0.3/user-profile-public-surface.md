# UserProfile public surface manifest

Business consumers import only
`features/user_profile/port/user_profile.dart`. It exports the pure `AppUser`
profile model, UserProfile Query/Command ports, shared Result/error types, and
the completed guest migration capability.

App bootstrap and focused composition tests may import
`features/user_profile/port/composition.dart`. Its immutable normal and sync
dependency bundles accept app-owned runtime instances and return completed
capabilities; they contain no Provider, Ref, generic resolver, runtime cast,
or Firebase SDK type. The facade reaches internal assembly through the single
canonical `user_profile_composition_factory.dart` bridge.

Firestore account documents use the shared technical contract at
`core/infrastructure/firebase/firebase_account_document_namespace.dart`.
UserProfile wire DTOs and profile field mapping remain private under
`internal/infrastructure/firebase`; MyWord and WordStatus retain ownership of
their nested collection, payload, and query contracts.

`port/presentation_entry.dart` is the controlled Flutter surface. It accepts
the completed `UserProfileCommandPort`; Riverpod wiring and runtime lifetime
remain app-owned. The former lifecycle/live-profile shims and feature-owned DI
providers have been removed.

The migration preserves profile defaults, email-derived username, device ID,
local precedence, ensure/update/watch absence and error behavior, transaction
and outbox protocol, guest merge and deterministic mutation ID, dataset ID,
cursor/revision, Firestore path/fields, session, route, UI, and feature behavior.
