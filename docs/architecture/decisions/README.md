# Architecture Decision Records

このディレクトリは、実装を長期に拘束するアーキテクチャ判断を記録する。current-state のファイル配置と目標 ownership は区別し、実装詳細ではなく後続作業が守るべき invariant と依存方向を残す。

## 運用

- ファイル名は `NNNN-kebab-case-title.md` とし、作成時に未使用の最小番号を採番する。
- Status は `Proposed`、`Accepted`、`Superseded`、`Deprecated` のいずれかとする。合意前は `Proposed`、採用済みは `Accepted` とする。
- 一度 `Accepted` になった判断は履歴として保持する。判断を変更するときは新しい ADR を作り、旧 ADR の `Superseded by` と新 ADR の `Supersedes` を相互にリンクする。
- `Deprecated` は判断が不要になった場合に使い、置換判断がある場合は `Superseded` を使う。
- Date は `YYYY-MM-DD` で記録する。Decision owners は人名ではなく、判断する論理 module を記録する。
- 必須 section は Status、Date、Decision owners、Context、Decision drivers、Decision、Ownership matrix、Allowed dependency direction、Compatibility constraints、Consequences、Rejected alternatives、Follow-up とする。

## Index

| ADR | Title | Status | Date | Replaces |
|---|---|---|---|---|
| [0001](./0001-catalog-word-status-my-word-ownership.md) | Catalog・WordStatus・MyWord の ownership | Accepted | 2026-08-08 | — |
