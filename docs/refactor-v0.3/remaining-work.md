# Catalog and MyWord refactor remaining work

## Quiz Phase 8 result

Quiz now has one pure-Dart business facade, documented technical seams, and
checker coverage for external/internal imports and Catalog-to-Quiz integration.
The legacy candidate source/query/gateway/game-loader contracts, compatibility
adapter, old game data/repository/use-case graph, obsolete DI, and their
dedicated tests were removed after reference checks.

Repository-wide checker findings outside Quiz remain separate debt and are not
fixed in this phase. Record them by checker rule ID and source path when
reviewing the full gates; do not baseline them as Quiz exceptions.

Current non-Quiz checker sources after the MyWord Composition DI migration are:

- `business_port_no_framework`: Auth and UserProfile Firebase dependency
  providers, and Search presentation dependencies
- `composition_exact_facade`: Auth, Quiz, Ranking, Search, Sync, UserProfile,
  and WordStatus composition files
- `internal_clean_architecture` (feature dependency checker):
  `lib/features/catalog/internal/domain/repository/conjugation_repository.dart`
  and `lib/features/ranking/internal/presentation/provider/view_model_di.dart`

## MyWord Phase 8 result

MyWord now has a single business facade, documented public surface, and
checker coverage in both import-boundary gates. The checker permits only the
bootstrap composition seam and routing presentation-entry seam outside the
feature; all external `internal/**` and deep business-port imports are rejected.

Repository-wide non-MyWord violations remain separate architecture debt and
must not be treated as a failure of the MyWord facade migration.

## MyWord Composition DI result

MyWord now uses immutable typed dependency bundles and required named factory
parameters. `MyWordPorts` is a framework-free composition contract. Internal
factories use explicit constructor DI, and app bootstrap owns the completed
ports and dataset-handler Providers consumed by the sync registry.

The opaque MyWord dependency readers, enum keys, and runtime casts are removed.
The unreferenced feature-owned Firebase Provider shim was deleted after a
zero-reference check. The migration did not change database schema, Firestore
wire format, sync protocol, dataset ordering, or business behavior.

Targeted MyWord factory, Provider composition, and boundary fixture tests are
green. Repository-wide boundary checks remain non-green only because of the
non-MyWord debt listed above.

## Phase 8 result

The Catalog business facade, deep-import migration, ADR, public-surface manifest,
and import-boundary documentation are complete. Boundary checkers enforce the
facade and integration rules.

Targeted validation is green:

- `dart analyze` for the Catalog facade and both boundary checker sources
- the import-boundary and feature-dependency checker fixture tests
- the Catalog public contract and port contract tests
- the application Catalog composition test through public reader interfaces

Repository-wide boundary checks are not green yet, but report no Catalog facade,
Catalog internal, Catalog integration, or MyWord Composition DI violations. The
remaining failures are outside these refactors' ownership:

- `check_import_boundaries.dart` reports the non-MyWord Riverpod and composition
  seam findings listed above.
- `check_feature_dependencies.dart` reports two Catalog domain-to-application
  imports and one Ranking presentation-to-composition import.

Therefore the repository-wide checker and full-suite completion criteria must
not be recorded as green.

## Intentional compatibility surface

`CatalogReader` and `ConjugationReader` remain active and are exported through the
facade. Their presence is not a deep-import exception. Remove these exports only
after all detail/conjugation consumers use the focused reader ports and their
tests no longer require the legacy contracts.

`composition.dart`, `presentation_dependencies.dart`, and
`presentation_entry.dart` remain explicit technical seams rather than business
facades. New feature composition work follows
[`docs/architecture/composition-rule.md`](../architecture/composition-rule.md).

## Out of scope for v0.3

- Database schema or migration changes
- Sync or serialization protocol changes
- Route and screen behavior changes
- Resolving the non-MyWord boundary debt listed above
