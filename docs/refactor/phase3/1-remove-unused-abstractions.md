# Phase 3-1: 未使用・機械的な抽象を削除する

- 状態: 未着手
- 優先度: 中 / 保守性
- 依存タスク: Phase 0〜2で主要挙動と境界が固定されていること
- 関連タスク: [`2-consolidate-copy-files.md`](2-consolidate-copy-files.md)
- 元調査: [`FLUTTER_ARCHITECTURE_REVIEW.md`](../../FLUTTER_ARCHITECTURE_REVIEW.md) 10.1

## 目的

実装・利用のないPresenter、OutputData、RepositoryInputData、一対一転送interfaceを削除し、実際の変更点と依存関係を追いやすくする。

## 現在の問題

- Presenter interfaceが11ファイルあるが、実装・利用を確認できない
- 一部OutputData、RepositoryInputData、`ISyncRepository`は定義だけである
- 小さな値型までclass 1 fileを機械的に適用し、探索コストが高い
- DataSource interfaceがDAOと完全な一対一転送になっている箇所がある

## 対象範囲

- `I*Presenter`と実装候補
- 未参照InputData、OutputData、RepositoryInputData
- 未実装port/interface
- 一対一転送だけのDataSource interface
- 重複するAuth entityなど

## 削除判定

次をすべて確認してから削除する。

1. import、型参照、生成コード、reflection的登録が0
2. README、設計文書、testで将来契約として必要とされていない
3. plugin/API公開面ではない
4. 削除後もarchitecture boundaryが保たれる
5. 近い将来の実装予定ではなく、必要時に小さく再導入できる

## 実装方針

1. 候補一覧を作り、参照数と削除理由を記録する。
2. feature単位の小さな変更で削除する。
3. interfaceを削除する場合は具体実装のtest容易性が悪化しないか確認する。
4. 小さな関連value objectは意味が近ければ同一ファイルへ整理する。
5. 削除と機能変更を同じ変更へ混ぜない。

## 推奨検証

- `rg`で候補名の参照が0
- analyze/testが削除前後で同じ結果
- public exportとDI providerにdangling referenceがない
- architecture checkが悪化しない

## 完了条件

- [ ] 未使用Presenterが削除または利用理由を明記されている
- [ ] 未参照Input/Output型が削除されている
- [ ] 一対一転送interfaceの残存理由を説明できる
- [ ] 削除後にanalyze/testが通る
- [ ] 機能挙動を変更していない

## LLMへの引き継ぎ事項

ファイル名だけで未使用と判断しない。DI、generated code、文字列参照を含めて検索する。削除に確信がなければ候補一覧へ残し、利用箇所を先にtestする。
