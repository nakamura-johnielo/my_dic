# Word status feature の統合

状態: 完了（presentation slice）
作成日: 2026-08-06

## 目的

Esp-Jpn と Jpn-Esp の status UI を単一の `features/word_status` feature に集約し、呼び出し側が辞書別の presentation 実装へ依存しないようにする。

## 実装スコープ

- `features/word_status/presentation` に direction を受け取る status button と UI adapter を配置する。
- 既存の Esp-Jpn/Jpn-Esp/MyWord status button と adapter を移し、利用箇所を新featureへ切り替える。
- 両辞書featureの DI から旧 presentation ownership を外す。

## スコープ外

- Drift/Firebase datasource、repository、sync handler の統合。
- Esp-Jpn/Jpn-Esp entity と update/watch usecase の共通化。
- import boundary CI の導入（Phase 1-2）。

## 参照する計画書とcontexts

- `docs/refactor/phase1/6-unify-word-status.md`
- `docs/refactor/local_first/5-migrate-word-status.md`
- `docs/refactor/contexts/feature-map.md`

## 実装手順

1. direction enum と共通 status button を `features/word_status` に作成する。
2. 辞書別 command/state/view model と MyWord adapter を同featureへ移す。
3. DI と既存の UI 呼び出しを新featureへ接続する。
4. 旧 component を削除し、対象テストと解析を実行する。

## 検証

- `flutter test test/unit/features/word_status`
- `dart analyze lib/features/word_status lib/features/esp_jpn_word_status lib/features/jpn_esp_word_status`

## contexts更新方針

feature-map と current に完了した presentation 集約と、残る data/application 統合を記録する。

## 完了条件

- 辞書と MyWord の status button が `features/word_status` から提供される。
- Jpn-Esp DI が Esp-Jpn の presentation 実装を import しない。
- 既存の status 契約テストが通る。

## 実施結果

- `features/word_status` に共通button、direction、dictionary command/state/ViewModel、MyWord adapterを配置し、旧`esp_jpn_word_status/components/status_button/**`を削除した。
- WordPage、Search、Quiz、Rankingは共通buttonを利用する。Jpn-Esp DIはEsp-Jpn presentationをimportしない。
- `flutter test test/unit/features/word_status` は33件成功。`dart analyze`はerror 0で、既存のwarning/infoのみ残る。
- 未対応: entity/usecase/repository/datasource/sync handlerの単一契約化。`features/word_status/presentation/word_status_di.dart`は移行adapterとして両directionのDIを参照するため、Phase 1-2の境界強制と合わせて次スライスでapplication portへ置換する。
