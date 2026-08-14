# ADR 0009: Firebase account document namespace ownership

## Status

Accepted

## Date

2026-08-13

## Decision owners

- shared Firebase infrastructure
- dataset feature owners

## Context

UserProfile, MyWord, and WordStatus address account-owned remote data below the
top-level `Users/{accountId}` document. Existing consumers obtain `Users` from
UserProfile's public `UserDTO`, which exposes profile wire fields and makes a
profile DTO appear to own every feature's remote path.

## Decision drivers

- Preserve the existing Firestore path and Security Rules.
- Avoid sharing a feature wire DTO or an SDK object.
- Preserve each feature's ownership of its nested collections and payload.
- Allow a staged consumer migration without breaking the current build.

## Decision

The literal top-level collection name is a shared technical Firebase contract,
owned by `core/infrastructure/firebase/firebase_account_document_namespace.dart`.
It exposes only the stable `Users` collection segment. It does not expose a
`DocumentReference`, raw map, profile field, or nested collection.

The same core seam defines an SDK-free account-document reader. App bootstrap's
canonical Firebase provider owns its Firestore implementation and normalizes
Firestore timestamps to UTC `DateTime` values before returning a technical
document snapshot. Feature composition therefore does not expose
`FirebaseFirestore`.

MyWord, WordStatus, and UserProfile Firebase infrastructure use this contract
directly. UserProfile's wire interpretation remains internal and is not a
shared path contract.

## Ownership matrix

| Owner | Owns | Does not own |
|---|---|---|
| shared Firebase infrastructure | `Users` root collection segment | profile or nested-feature payloads |
| UserProfile | profile fields and profile remote mapping | MyWord/WordStatus nested paths |
| MyWord / WordStatus | own nested collections, fields, queries, mapping | profile DTO and root namespace meaning |
| app bootstrap | Firebase instance lifetime | remote path semantics |

## Allowed dependency direction

Firebase feature infrastructure may depend on the shared namespace constant.
Business ports and workflows must not depend on it. No feature may depend on
another feature's DTO to obtain the root account path after Phase 4.

## Compatibility constraints

This decision does not change `Users`, document IDs, nested collection names,
fields, queries, schema, Security Rules, dataset IDs/order, payloads, field
masks, routes, UI, or behavior.

## Consequences

The root path has one technical owner without merging feature payload
ownership. Feature-owned DTOs continue to define only their own payload and
nested collection semantics.

## Rejected alternatives

- Keeping `UserDTO` as the shared contract was rejected because it exposes
  UserProfile wire fields to unrelated features.
- Returning Firestore references was rejected because SDK types would cross
  business boundaries.
- Giving the root path to UserProfile was rejected because account namespace
  scope is broader than profile payload ownership.

## Follow-up

Phase 4 migrated MyWord and WordStatus path consumers without changing the
root or nested paths and removed the compatibility DTO after production and
test references reached zero.
