# Phase 3-5: package依存とunused importを整理する

- 状態: 未着手
- 優先度: 中 / build再現性
- 依存タスク: Phase 1〜2の移動完了、[`4-normalize-names.md`](4-normalize-names.md)と並行可能
- 元調査: [`FLUTTER_ARCHITECTURE_REVIEW.md`](../../FLUTTER_ARCHITECTURE_REVIEW.md) 10.5、10.6、11

## 目的

`pubspec.yaml`と実際のimportを一致させ、runtime、development、code generation依存を正しく分類し、clean checkoutから再現可能にする。

## 現在の問題

- 多くのpackageにversion constraintがない
- `logging`を直接importしているがdirect dependencyではない
- `get_it`はdependencyにあるが利用を確認できない
- `mocktail`がruntime dependencyにあるが利用を確認できない
- codegen/tool packageのdependency/dev_dependency分類が不明確
- `firebase_options.dart`がimportされる一方でignoreされ、生成手順がない
- `test/**`がanalyzer対象外
- CI workflowがない

## 対象範囲

- `pubspec.yaml`、`pubspec.lock`
- 全Dart import
- `analysis_options.yaml`
- Firebase設定生成手順
- CIのanalyze/test/codegen check

## 実装方針

1. packageごとにdirect import、transitive利用、tool利用を一覧化する。
2. 直接importするpackageをdirect dependencyへ追加する。
3. test/build/codegen専用packageを`dev_dependencies`へ移す。
4. 未使用packageを一つずつ削除し、pub get/analyze/testで確認する。
5. applicationとして適切なcompatible version constraintを明記し、lockfileを維持する。
6. `flutterfire configure`などFirebase設定の生成手順と必要環境をREADMEへ記載する。
7. `test/**`のanalyzer除外を解除する。
8. clean checkout CIでdependency取得、必要な生成、analyze、testを実行する。

## 推奨検証

- clean checkout相当の環境でsetup手順が完走する
- undeclared transitive dependencyへ依存していない
- `dart pub deps`とimport一覧が一致する
- code generation後に意図しないdiffが出ない
- analyze/testがCIで完走する

## 完了条件

- [ ] direct importとpubspec宣言が一致する
- [ ] 未使用dependencyが削除されている
- [ ] tool/test packageがdev_dependenciesにある
- [ ] Firebase設定の再生成手順がある
- [ ] testがanalyzer対象である
- [ ] clean checkout CIが成功する

## LLMへの引き継ぎ事項

version更新とarchitecture refactorを同時に行わない。まず宣言と実利用を一致させ、その後のupgradeはpackageごとにrelease noteと回帰testを確認して別タスクで行う。
