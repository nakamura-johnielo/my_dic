# Phase 1-3: route contractをView実装から分離する

- 状態: 未着手
- 優先度: 中〜高 / 境界・routing
- 依存タスク: [`2-enforce-import-boundaries.md`](2-enforce-import-boundaries.md)の規則確定を推奨
- 関連タスク: [`1-create-composition-root.md`](1-create-composition-root.md)
- 元調査: [`FLUTTER_ARCHITECTURE_REVIEW.md`](../../FLUTTER_ARCHITECTURE_REVIEW.md) 7.2、8.4、8.5

## 目的

画面遷移の契約をWidget/Viewファイルから切り離し、別featureがpresentation実装をimportせず、URLから復元可能なroutingにする。

## 現在の問題

- `WordPageInput`と`QuizGameFragmentInput`がViewファイル内に定義される
- Navigator serviceや別featureがそれらのView型をimportする
- route builderが`state.extra as ...`で強制castする
- Web refreshやdeep linkでは`extra`が失われ、runtime errorになり得る
- `/search`配下で再び`search/...`を追加し、`/search/search/...`になる経路がある
- Bottom navigationにRouterと独自providerの二重状態がある

## 目標構造

```text
lib/app/routing/
├── app_route.dart
├── contracts/
│   ├── word_detail_route.dart
│   └── quiz_game_route.dart
├── parser/
└── router_provider.dart
```

route contractはpure Dartで、primitive/value objectからserialize・parseできることを基本とする。

## 実装方針

1. 全route、path、name、引数、redirect条件を一覧化する。
2. route引数型をViewファイルから`app/routing/contracts`へ移す。
3. 永続可能なIDやmodeはpath/query parameterで表現する。
4. 大きな一時objectを`extra`で渡す場合も、欠損時にIDから再取得できるfallbackを持つ。
5. 強制castをparse Resultとerror routeへ置き換える。
6. nested pathを親からの相対pathとして正規化する。
7. tab indexのsource of truthをGoRouter側へ統一し、`+2`などのmagic numberをenum/route mappingへ置換する。

## 必須テスト

- 各URLを直接開いて正しい画面を構築できる
- browser refresh後も画面を復元できる
- invalid/missing parameterでerror pageへ遷移する
- back、deep link、tab切替で選択状態がずれない
- route contractがFlutter Widget型をimportしない

## 完了条件

- [ ] route引数がView実装ファイルに定義されていない
- [ ] 別featureのpresentation importがroutingから消えている
- [ ] `state.extra`欠損で強制cast errorにならない
- [ ] URLの重複segmentがない
- [ ] tab位置のsource of truthが1つ
- [ ] deep linkとrefresh testが通る

## LLMへの引き継ぎ事項

Viewクラス名を別ファイルへ移すだけでは不十分。route contractはUI実装を知らないpure dataであり、URLから再構築できることを優先する。
