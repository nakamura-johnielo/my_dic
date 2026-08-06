# Phase 1-5: Search・Quiz・WordPageの共有概念の所有者を決める

- 状態: 進行中（slice 1完了、詳細は[`../contexts/plans/phase1.5-define-catalog-ownership.plan.md`](../contexts/plans/phase1.5-define-catalog-ownership.plan.md)）
- 優先度: 高 / feature循環
- 依存タスク: [`2-enforce-import-boundaries.md`](2-enforce-import-boundaries.md)（`tool/import_boundaries`としてCI強制の基盤は導入済み。baseline運用中）
- 関連タスク: [`3-extract-route-contracts.md`](3-extract-route-contracts.md)、[`../phase2/5-separate-query-projections.md`](../phase2/5-separate-query-projections.md)
- 元調査: [`FLUTTER_ARCHITECTURE_REVIEW.md`](../../FLUTTER_ARCHITECTURE_REVIEW.md) 7.1、7.2、7.8

## 目的

辞書検索、単語詳細、Quiz出題が共有する概念と能力の所有者を明示し、Search、Quiz、WordPage間の双方向importを解消する。

## 現在の問題

- Search domainがQuiz entityを返す
- Quiz ViewModel/DIがSearch UseCaseを利用する
- Search ViewModelがWordPageのView入力型をimportする
- WordPage UIがSearch DIをimportする
- Quiz ViewとWordPage Viewが互いの型/providerを参照する
- `core`の辞書RepositoryがRanking DataSourceを注入して画面用データを組み立てる

## 先に決めること

次の候補を、名前ではなく変更理由で分類する。

| 概念 | 推奨所有候補 |
| --- | --- |
| 辞書語彙、見出し語、意味、活用 | `dictionary`または`catalog` domain |
| 検索条件と検索結果snippet | Search application query |
| 単語詳細表示model | WordPage application query |
| Quiz問題、回答、採点 | Quiz domain |
| 画面遷移用word ID | app routing contract |
| 学習status、ranking付き表示 | 専用read model/query repository |

Quizが検索能力を必要とする場合、Search featureのViewModelを使うのではなく、Quiz applicationが必要とする`WordCatalogQuery`などのportを定義する。

## 実装方針

1. 3 feature間のimport graphと利用理由を一覧化する。
2. 各共有型を「業務概念」「application query」「route contract」「UI部品」に分類する。
3. 業務概念の所有featureを一つ決める。
4. 他featureは所有featureの公開portだけに依存する。
5. UI共有が必要なら、意味が同じ汎用Widgetだけをdesign systemへ置く。feature固有Widgetは共有しない。
6. 循環を一方向ずつ切り、architecture checkで再発を防ぐ。
7. `core`へ移す場合は、全featureから独立した変更理由を持つことを説明できる型だけに限定する。

## 推奨テスト

- Search、Quiz、WordPageを個別にfake portでtestできる
- Quiz testがSearch providerやWidgetを構築しなくてよい
- WordPage testがSearch DIへ依存しない
- architecture checkで3 feature間の双方向依存が0

## 完了条件

- [x] 共有概念ごとのownerが文書化されている（活用検索結果item→core catalog、詳細は[feature-map.md](../contexts/feature-map.md)のCatalog ownership note）
- [x] Search、Quiz、WordPageの循環importが0（`feature:quiz`<->`feature:search`、`feature:*`<->`feature:word_page`のいずれも解消済み。実測は`dart run tool/check_import_boundaries.dart --check`で確認）
- [ ] 別featureのpresentation型をimportしない（WordPage→Quiz/Searchの`di`層直接依存3件、Quiz→Searchの`CardView`再利用1件が未解消。詳細はplan文書とnext-phase-guide.mdを参照）
- [x] Quizが必要な辞書能力をapplication/domain portで受ける（`ConjugacionSearchResultItem`をcore catalog domainのportとして利用する形に整理済み）
- [x] route引数がapp-level contractになっている（`app/routing/contracts/quiz_game_route.dart`、`word_detail_route.dart`を既存経路で利用済み）

## LLMへの引き継ぎ事項

ディレクトリ名より型の意味と変更理由を優先する。巨大な`shared`や`core/models`を新設して循環を隠さない。
