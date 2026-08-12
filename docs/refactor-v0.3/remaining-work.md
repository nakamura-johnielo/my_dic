# Catalog refactor remaining work

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
