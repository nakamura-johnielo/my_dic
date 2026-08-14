# Catalog and MyWord refactor remaining work

## Sync Phase 4-6 result

Sync records now carry generic execution metadata and an owner-supplied typed
apply operation; the former `Object` payload and feature-side runtime casts are
removed. The heterogeneous registry, dataset IDs/order, cursor/checkpoint,
queue/retry/ack, session, and UI behavior are unchanged.

`RemoteMutationTarget` and UserProfile provisioning contracts no longer belong
to Sync. MyWord, WordStatus, and UserProfile encode their own document paths,
identity fields, and wire values. The shared Firebase executor performs only
generic transaction and acknowledgement mechanics, while UserProfile owns its
provisioning transaction and DTO interpretation. The raw dataset contract is
named `DatasetSyncGateway`; implementations remain `*DatasetSyncService`.

Static reference scans and `git diff --check` are the subtask gate. Focused
Dart analysis and Flutter contract tests remain for the coordinating thread.

The Phase 6 checker gate now discovers every canonical feature facade without
requiring all three optional technical seams. Existing seams are checked
independently, and every feature composition is scanned for Provider types,
opaque generic resolvers, and runtime `as T` lookup casts. Sync's
`dataset_contract.dart` has a narrow structural allowance for dataset-owner
composition/infrastructure and the Sync runtime wiring roots; negative fixtures
reject application, presentation, arbitrary app, and unrelated integration
consumers. No feature-name allowlist or new baseline entry was added.

The checker remains a `lib/**` production gate. Public-surface manifests govern
production consumers, while the documented same-feature white-box test policy
continues to permit focused internal characterization tests; an indiscriminate
`test/**` scan is intentionally not used.

## Auth Phase 4 result

Auth now exposes one pure business facade, an SDK-free typed composition
contract, and a routing-owned controlled presentation entry. Firebase Auth is
confined to the app bootstrap external-system adapter; Auth still owns provider
and failure interpretation. The old feature-owned Firebase DAO/data-source/DTO
graph is removed. Auth-specific positive and negative fixtures cover both
boundary checkers without a baseline exception. Focused Dart/Flutter validation
remains to be run by the coordinating thread.

## WordDetail Phase 8 result

WordDetail now uses one pure business facade, a consumer-owned Catalog gateway,
a pure Catalog adapter, typed composition, controlled presentation entry, and a
feature-owned typed route. Presentation consumes semantic content and an
injected WordStatus renderer; Quiz navigation remains a pure callback.

The legacy loader/query result/view data, old query barrel, Catalog presentation
DI, raw HTML style renderer, mismatched state filename, and duplicate old tests
were removed after static reference checks. Generic strict-surface and
integration checker rules cover WordDetail without a feature-specific baseline
exception. Focused Dart/Flutter validation remains to be run by the coordinating
thread.

## Search Phase 6 result

Search now has a sole business facade, controlled composition and presentation
seams, and generic coverage in both boundary checkers. Legacy deep ports,
application shims, adapters, and unused presentation code were removed after
reference checks. Search production paths have no generic facade, internal,
technical-seam, integration, composition-factory, or framework-leak findings.
No baseline entry was added; unrelated feature debt remains independently owned.

## Quiz Phase 8 result

Quiz now has one pure-Dart business facade, documented technical seams, and
checker coverage for external/internal imports and Catalog-to-Quiz integration.
The legacy candidate source/query/gateway/game-loader contracts, compatibility
adapter, old game data/repository/use-case graph, obsolete DI, and their
dedicated tests were removed after reference checks.

Quiz Phase 4-6 follow-up moved asset and English-table wire interpretation into
Quiz infrastructure and made both readers return typed Quiz models. Candidate
policy is implemented by `QuizCandidateQueryService`. Composition now uses
immutable `QuizDependencies`, a pure `QuizPorts` contract, and one internal
factory; app bootstrap imports only the Quiz composition seam.

Repository-wide checker findings outside Quiz remain separate debt and are not
fixed in this phase. Record them by checker rule ID and source path when
reviewing the full gates; do not baseline them as Quiz exceptions.

Current non-Quiz checker sources after the MyWord Composition DI migration are:

- `business_port_no_framework`: UserProfile Firebase dependency
  providers, and Search presentation dependencies
- `composition_exact_facade`: Ranking, Search, Sync, UserProfile,
  and WordStatus composition files
- `internal_clean_architecture` (feature dependency checker):
  `lib/features/catalog/internal/domain/repository/conjugation_repository.dart`
  and `lib/features/ranking/internal/presentation/provider/view_model_di.dart`

The temporary app-bootstrap-to-Quiz-internal checker allowance has been
removed. Negative fixtures in both boundary checkers now require bootstrap
imports of Quiz internals to fail.

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

## Catalog Phase 7-8 result

The Catalog business facade, deep-import migration, legacy cleanup, ADR,
public-surface manifest, and import-boundary documentation are complete.
`CatalogQueryPort`, `ConjugationQueryPort`, their compatibility providers, and
the unused legacy word/search repository graph were removed after reference
checks. Focused QueryPort implementations now follow the `*QueryService` naming
rule; internal persistence contracts no longer use `I*` names.

The Phase 7-8 follow-up passed static reference scans, local-import existence
checks, and `git diff --check`. Focused Dart analysis, checker execution,
Catalog contract tests, and the real-asset smoke test remain for the
coordinating thread.

Previously completed targeted validation is green:

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

`composition.dart` remains the sole Catalog technical seam rather than a
business facade. Catalog has no presentation-specific dependency seam. New
feature composition work follows
[`docs/architecture/composition-rule.md`](../architecture/composition-rule.md).

## Out of scope for v0.3

- Database schema or migration changes
- Sync or serialization protocol changes
- Route and screen behavior changes
- Resolving the non-MyWord boundary debt listed above
