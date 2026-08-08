# Phase 3-6: 大型DAO・Seeder・同期処理を責務単位に分割する

- 状態: 未着手
- 優先度: 中 / 長期保守性
- 依存タスク: [`../local_first/8-cut-over-and-remove-legacy-sync.md`](../local_first/8-cut-over-and-remove-legacy-sync.md)、Phase 1〜2の境界整理、Phase 3-1〜3-5を推奨
- 元調査: [`FLUTTER_ARCHITECTURE_REVIEW.md`](../../FLUTTER_ARCHITECTURE_REVIEW.md) 10.3、10.4

## 目的

大型クラスを、変更理由・transaction境界・query責務・同期段階に沿って分割し、局所的に理解・テスト・変更できるようにする。

## 現在の候補

- Web database seeder: 約794行
- Conjugation DAO: 約558行
- Search card View: 約469行
- MyWord Repository: 約398行
- DatabaseProvider: 約371行
- Local-first移行後に残る大型local DAO・remote adapter
- Ranking DAOの動的SQL文字列連結

行数だけで分割せず、変更理由が複数ある箇所を優先する。

## 分割候補

| 現在の責務 | 分割例 |
| --- | --- |
| DatabaseProvider | connection factory、schema、migration、lifecycle |
| Web Seeder | asset reader、parser、batch writer、progress reporter |
| Conjugation DAO | lookup query、mapping、pattern別query |
| MyWord local infrastructure | command DAO、query DAO、transaction boundary |
| Sync remote adapter | DTO mapping、page query、Firebase batch/transaction |
| Search card | layout、status actions、meaning view、navigation adapter |

## 実装方針

1. 分割前にpublic behaviorとfailureをcharacterization testで固定する。
2. class内のfield、method、依存を変更理由でgroup化する。
3. transaction境界を跨ぐ処理はcoordinatorを残し、内部componentへ委譲する。
4. SQL文字列連結をparameter binding、Drift expression、typed queryへ置換する。
5. input collectionを破壊的変更する副作用を除去する。
6. 一度に一componentだけ抽出し、各段階でtestを通す。
7. 抽出後に一対一転送だけのwrapperが残る場合は統合を検討する。

## 必須テスト

- Seederの件数、順序、rollback、progress
- migrationを含むDatabase lifecycle
- DAO queryの境界値、filter、pagination、SQL injection耐性
- MyWord command/query contract
- Local-first handlerとserver cursor contract
- Search cardの主要interaction

## 完了条件

- [ ] 大型componentの変更理由が分離されている
- [ ] transaction境界が維持されている
- [ ] 動的値をSQL文字列へ直接埋め込まない
- [ ] input collectionを意図せず変更しない
- [ ] 抽出componentを個別にtestできる
- [ ] 分割後に不要な転送wrapperを残していない

## LLMへの引き継ぎ事項

目標行数を設定して機械的にclassを割らない。高凝集な長いparserは一つでもよい。SyncEngine基盤の責務分割はLocal-firstトラックで完了済みとし、このPhaseでは残ったDAO、adapter、parserの複数変更理由から分割する。
