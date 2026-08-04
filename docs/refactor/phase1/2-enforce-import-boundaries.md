# Phase 1-2: import境界を文書化しCIで強制する

- 状態: 未着手
- 優先度: 高 / 再発防止
- 依存タスク: [`1-create-composition-root.md`](1-create-composition-root.md)と並行可能
- 関連タスク: Phase 1-3〜1-6
- 元調査: [`FLUTTER_ARCHITECTURE_REVIEW.md`](../../FLUTTER_ARCHITECTURE_REVIEW.md) 7.1〜7.4

## 目的

Clean Architectureとfeature ownershipを人の注意だけに依存させず、禁止依存をCIで検出する。

## 現在の問題

調査時点で次が確認されている。

- feature間直接import: 70本、23方向
- 双方向feature依存: 4組
- domainからFlutter SDKへのimport: 19本
- `core`からfeatureへのimport: 23本
- 別featureのpresentation型をroute引数やUI部品として参照

フォルダ名はlayerを示すが、import規則がないため実際の依存方向と一致していない。

## 許可する基本依存

```text
feature/presentation -> feature/application -> feature/domain
feature/infrastructure ---------------------> feature/domain/application port
app/bootstrap ------------------------------> feature実装
app/routing --------------------------------> pure route contract
core ---------------------------------------> featureへ依存しない
```

feature間連携は、所有featureのapplication/domain port、または明示されたapp-level orchestrationを通す。別featureの`presentation/**` importは禁止する。

## 対象範囲

- architecture rule文書
- analyzer/lint/scriptによるimport検査
- CI workflow
- `analysis_options.yaml`の`test/**`除外解除
- 現在の違反一覧と段階的削減baseline

## 実装方針

1. package内で許可・禁止する依存表をリポジトリに明記する。
2. `rg`ベースscript、custom lint、dependency analyzerなど、CIで安定して動く方法を選ぶ。
3. 最低限次を禁止する。
   - `domain/**`からFlutter、Riverpod、Firebase、Drift、GoRouter
   - `core/**`から`features/**`
   - feature Aの`presentation/**`からfeature B内部
   - feature間の双方向依存
4. 既存違反はbaseline化してもよいが、新規違反を増やせない状態から開始する。
5. Phase 1完了時にbaselineを0へする。
6. testをanalyzer対象へ戻し、CIでanalyzeとtestを実行する。

## 推奨検証

- 意図的に禁止importを追加したfixtureでCIが失敗する
- relative import、package import、Windows separatorのすべてを検出する
- generated codeを必要に応じて除外する
- architecture check自体のtestを用意する

## 完了条件

- [ ] 許可・禁止依存が文書化されている
- [ ] CIが新規禁止importを検出する
- [ ] `test/**`がanalyzer対象である
- [ ] Phase 1終了時に対象違反baselineが0
- [ ] generated codeなどの除外理由が明記されている

## LLMへの引き継ぎ事項

違反を直すために型を無条件で`core`へ移さない。まずownershipを決め、所有featureのportまたはapp-level contractを利用する。
