# Import boundaries

`tool/check_import_boundaries.dart` prevents architectural import regressions.
Rules are defined in `tool/import_boundaries/rules.json`; generated Dart sources
are excluded. Both `package:my_dic/...` and relative imports are recognized,
including Windows-style separators.

Run locally:

```powershell
dart run tool/check_import_boundaries.dart --baseline tool/import_boundaries/baseline.json --check
```

The baseline contains each pre-existing violation together with its rule ID,
source, target, introduction date, owner, and tracking issue. CI fails when a
violation is added or a baseline entry disappears. Update it deliberately:

```powershell
dart run tool/check_import_boundaries.dart --baseline tool/import_boundaries/baseline.json --update-baseline
```

Use `--format=json` for machine-readable output and replace default ownership
metadata before committing new baseline entries.
