# ADR 0003: Quiz public facade ownership

## Decision

Quiz consumers use `package:my_dic/features/quiz/port/quiz.dart` as their sole
business import. It exports Quiz-owned queries, results, typed errors, focused
reader ports, Catalog-required gateway ports, and route/presentation input
values. The facade is pure Dart.

The only external technical seams are:

- `port/composition.dart` and `port/presentation_dependencies.dart` from app
  bootstrap;
- `port/presentation_entry.dart` from app routing.

Bootstrap also owns the runtime construction of Quiz's asset and Drift
infrastructure adapters. That narrowly scoped infrastructure import is not a
business dependency and is checker-allowlisted only below `app/bootstrap`.

`presentation_dependencies.dart` may use Riverpod only to bridge focused
reader ports. It is not a business facade and cannot expose provider types
through `quiz.dart`.

Catalog-to-Quiz conversion belongs in `lib/integration/catalog_quiz`. That
layer may import only the Quiz facade: it must not import Quiz internals, DAO,
Drift, or Flutter APIs. Candidate policy, game policy, warning projection,
fallbacks, assets, and database readers remain Quiz-owned.

## Consequences

The compatibility candidate source, legacy Catalog gateway, game loader,
legacy game values, old repository/use-case/data-source graph, and old DI are
removed. Boundary checkers protect the facade and the integration seam.
