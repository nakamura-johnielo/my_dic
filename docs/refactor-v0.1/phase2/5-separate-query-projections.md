# Phase 2-5: Query projectionとwrite domainを分離する

- 状態: 未着手
- 優先度: 中 / CQRS境界
- 依存タスク: [`../phase1/5-define-catalog-ownership.md`](../phase1/5-define-catalog-ownership.md)
- 関連タスク: [`1-move-usecases-to-application.md`](1-move-usecases-to-application.md)
- 元調査: [`FLUTTER_ARCHITECTURE_REVIEW.md`](../../FLUTTER_ARCHITECTURE_REVIEW.md) 7.8、7.9

## 目的

画面表示のためのJOIN・整形結果をapplication query modelとして明示し、書き込みdomain entityやRepositoryへUI都合を混在させない。

## 現在の問題

- Ranking domain entityがranking情報に加えてlearned、bookmark、hasNoteを持つ
- Ranking DAOがWordStatusをJOINし、Repositoryが画面用複合entityを作る
- coreのword RepositoryがRanking DataSourceを注入し、検索画面向け情報を組み立てる
- Drift Repositoryが`UIConsts.oneLineMeaningMaxLength`を使って意味を不可逆に切り詰める

JOIN自体は問題ではない。問題は、結果がwrite domain entityとして扱われ、画面ごとの変更理由がdomain Repositoryへ流入していることである。

## 目標モデル例

```text
SearchResultItem
  wordId, headword, meaningSnippet, starCount, statusSummary

RankingListItem
  rank, wordId, headword, score, statusSummary

WordDetailViewData
  fullMeaning, conjugations, status, ranking
```

これらはapplication query/read modelであり、write command用entityとは分ける。

## 実装方針

1. 各画面が必要とするfieldと更新責務を一覧化する。
2. Search、Ranking、WordPageごとにread modelを定義する。
3. JOIN/集約を専用Query RepositoryまたはDAOへ置く。
4. 書き込みRepositoryから画面専用DataSource依存を除く。
5. meaning省略などの純粋な表示処理はpresentationへ移す。
6. DB側でsnippetを作る必要がある場合、長さをapplication query契約として明示する。
7. query failureを空値に変換せず、必須fieldとoptional enrichmentを区別する。

## 推奨テスト

- Query Repositoryが期待するJOIN結果を返す
- write entity変更が不要なUI field追加であることを確認する
- full meaningがRepository内で切り詰められない
- optional enrichment失敗がwarningまたはpartial resultとして表現される
- query modelからwrite commandへ暗黙変換しない

## 完了条件

- [ ] Search/Ranking/WordPageのread modelが明示されている
- [ ] write domain entityに画面専用fieldが混在しない
- [ ] core word RepositoryからRanking DataSource依存が除かれている
- [ ] infrastructureがUI定数へ依存しない
- [ ] JOINとprojectionのtestがある

## LLMへの引き継ぎ事項

CQRSのために別DBを導入する必要はない。同じDrift DBを利用してよい。command modelとquery projectionの型・所有者・変更理由を分けることが目的である。
