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

Current non-Quiz checker sources are:

- `business_port_no_framework`:
  `lib/features/search/port/presentation_dependencies.dart`
- `composition_exact_facade` / `composition_no_provider_types`: Auth, MyWord,
  Ranking, Search, Sync, UserProfile, and WordStatus composition files
- `firebase_canonical_infrastructure_only`:
  `lib/integration/sync/firebase_remote_mutation_executor.dart`
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
Catalog internal, or Catalog integration violations. The remaining failures are
outside this refactor's ownership:

- `check_import_boundaries.dart` reports existing MyWord public-port/framework
  leaks, several feature composition-to-internal dependencies, Quiz/Search
  presentation dependency bridge framework imports, one Firebase integration
  placement violation, and other non-Catalog presentation facade violations.
- `check_feature_dependencies.dart` reports four MyWord
  presentation-to-composition dependencies, one Quiz
  application-to-infrastructure dependency, and one Ranking
  presentation-to-composition dependency.

Therefore the repository-wide checker and full-suite completion criteria in the
plan must not be recorded as green from this Phase 8 slice.

## Intentional compatibility surface

`CatalogReader` and `ConjugationReader` remain active and are exported through the
facade. Their presence is not a deep-import exception. Remove these exports only
after all detail/conjugation consumers use the focused reader ports and their
tests no longer require the legacy contracts.

`composition.dart` and `presentation_dependencies.dart` remain explicit technical
seams while the current Riverpod resolver/composition design is in use.

## Out of scope for v0.3

- Database schema or migration changes
- Sync or serialization protocol changes
- Route and screen behavior changes
- Replacing the current Riverpod dependency resolver
