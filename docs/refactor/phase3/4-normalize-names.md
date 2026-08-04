# Phase 3-4: typoとファイル命名を正規化する

- 状態: 未着手
- 優先度: 低〜中 / 探索性
- 依存タスク: Phase 1〜2の大規模移動完了後
- 関連タスク: [`5-clean-dependencies-and-imports.md`](5-clean-dependencies-and-imports.md)
- 元調査: [`FLUTTER_ARCHITECTURE_REVIEW.md`](../../FLUTTER_ARCHITECTURE_REVIEW.md) 10.2

## 目的

typo、大小文字、snake_case、interface命名の不統一を、挙動変更を含まないrename-only変更として整理する。

## 現在の候補

- `pagenation` -> `pagination`
- `corrdinator` / `coodinator` -> `coordinator`
- `studay` -> `study`
- `Destinatioin` -> `Destination`
- `Behaivor` -> `Behavior`
- `enviroment` -> `environment`
- `searh` -> `search`
- `wordStatusEntity.dart` -> snake_case
- `syncPriority.dart` -> snake_case
- `I_repository`、`native_API`などdirectory case/style

候補は調査時点の例であり、実施前に全ファイル・symbolを再検索する。

## 対象範囲

- ファイル・ディレクトリ名
- class、method、field、enum名
- import/export、生成設定、test、文書
- OS間でcase-only renameが失われる問題

## 実装方針

1. 命名規則をDart標準へ合わせて短く文書化する。
2. rename候補を機械的に一覧化する。
3. featureまたは語彙単位のrename-only commitに分ける。
4. Windowsでcase-only renameする場合は中間名を使い、Gitが変更を記録することを確認する。
5. 生成ファイルのsymbolは生成元を修正して再生成する。
6. typoを外部永続key、Firestore field、DB column、route pathへ波及させる場合は互換migrationを用意する。

## 推奨検証

- 旧綴りを`rg`で検索して0または互換箇所だけにする
- analyze/testを各rename単位で実行する
- Android、iOS、Webでcase-sensitive path問題がない
- route、DB、SharedPreferences、Firestoreの永続識別子が意図せず変わっていない

## 完了条件

- [ ] 命名規則が明記されている
- [ ] 主要typoが正規化されている
- [ ] rename変更にロジック変更が混在しない
- [ ] 永続key変更には互換処理がある
- [ ] analyze/testが通る

## LLMへの引き継ぎ事項

symbol名と永続データ名を同一視しない。Firestore field、DB column、SharedPreferences key、route pathは外部契約なので、単純renameせずmigrationまたは互換aliasを検討する。
