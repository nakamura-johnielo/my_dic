# Phase 1-5: Search・Quiz・WordPageの共有概念の所有者を決める（Slice 1）

状態: 完了（slice 1。CardView design system化のみ見送り）
作成日: 2026-08-06

## 目的

`docs/refactor/phase1/5-define-catalog-ownership.md` の実装。ただし現状のimport境界チェッカーの実測結果に基づき、今回のセッションでは安全に閉じられる範囲だけを実装する。

## 実測（`dart run tool/check_import_boundaries.dart --check --format=json`）

`tool/import_boundaries/baseline.json` は一部stale（過去に解消済みの違反が多数残っている）。実測した現在の違反のうちSearch/Quiz/WordPage関連は次の通り。

- `core_no_feature`: `i_conjugation_repository.dart` / `conjugacion_converter.dart` / `drift_conjugacion_repository.dart` → `features/quiz/domain/entity/quiz_searched_item.dart`
- `no_cross_feature_presentation`: `quiz/presentation/view/quiz_search_fragment.dart` → `features/search/presentation/components/card/card_view.dart`
- `no_cross_feature_presentation`: `word_page/presentation/view/esp_jpn/conjugacion_fragment.dart` → `features/search/di/view_model_di.dart`
- `no_cross_feature_presentation`: `word_page/presentation/view/esp_jpn/dictionary_fragment.dart` → `features/quiz/di/view_model_di.dart`
- `no_cross_feature_presentation`: `word_page/presentation/view/word_page_fragment.dart` → `features/quiz/di/view_model_di.dart`
- `no_feature_cycle`: `feature:quiz` <-> `feature:search`

## 実装スコープ（このセッション）

1. `QuizSearchedItem`（word/wordId/simpleMeaningのみを持つ活用検索結果）をcatalog概念として`core/domain/entity/verb/conjugacion`へ移し、`ConjugacionSearchResultItem`にrenameする。Quiz featureはcoreのcatalog型を利用する側に回る。
   - 対象: `core/domain/i_repository/i_conjugation_repository.dart`、`core/infrastructure/repositories/converters/conjugacion_converter.dart`、`core/infrastructure/repositories/drift_conjugacion_repository.dart`、`features/search/domain/usecase/search_word/search_word_interactor.dart`、`features/search/domain/usecase/search_word/search_word_output_data.dart`、`features/quiz/presentation/ui_model/quiz_search_model.dart`、`features/quiz/presentation/view_model/quiz_search_view_model.dart`、`features/quiz/presentation/view/quiz_search_fragment.dart`
   - 削除: `features/quiz/domain/entity/quiz_searched_item.dart`
2. `CardView`（word/meaning/ranking/status表示のcard widget）を`core/presentation/components/card/`へ移すことを試みたが、`CardView`自体が`features/esp_jpn_word_status/components/status_button`のstatus button widgetへ依存しており、移設すると新たな`core_no_feature`違反（core→feature）が発生することを実測で確認した。一方の違反を他方の違反へ付け替えるだけで実質的なownership解決にならないため、この移設は見送り、元の場所へ戻した。`CardView`のdesign system化は、Phase 1-6でstatus button widgetのownershipを決めた後に再検討する。
3. import境界チェッカーを再実行し、`tool/import_boundaries/baseline.json`を実態に合わせて更新する（stale entryの除去、新規解消分の反映）。

## スコープ外（未対応・future note化）

- `word_page/presentation/view/esp_jpn/conjugacion_fragment.dart`が`searchViewModelProvider`のqueryを直接参照している（検索語ハイライト用）。
- `word_page/presentation/view/esp_jpn/dictionary_fragment.dart`が`quiz/di/view_model_di.dart`の`quizWordProvider`へ書き込んでいる（quiz検索欄への現在語の受け渡し）。
- `word_page_fragment.dart`が`quiz/di/view_model_di.dart`の`quizGameViewModelProvider`を直接初期化している（WordPage内Quizタブの埋め込み）。
- `features/quiz/presentation/view/quiz_search_fragment.dart`が`features/search/presentation/components/card/card_view.dart`（`CardView`）を再利用している。`CardView`は`esp_jpn_word_status`のstatus button widgetへ依存しており、design systemへ移す前にPhase 1-6のstatus button ownership整理が必要（実測で確認済み、上記参照）。
- `ranking/presentation/view/ranking_card.dart`が`esp_jpn_word_status/di/di.dart`と`quiz/di/view_model_di.dart`をimportしている（Rankingの表示、Phase 1-5関連だが対象feature外）。

これらはWordPage/Quiz/Searchの実際のUI埋め込み・状態共有であり、route contractまたはapp-level portの新規設計判断が必要なため、このセッションでは変更しない。`docs/refactor/contexts/next-phase-guide.md`と`feature-map.md`に次フェーズ入り口として記録する。

## 実装手順

1. `core/domain/entity/verb/conjugacion/conjugacion_search_result_item.dart`を新設。
2. core側3ファイルのimport/型参照を更新。
3. search側2ファイルのimport/型参照を更新。
4. quiz側3ファイルのimport/型参照を更新（クラス名のみ変更、フィールドアクセスは変わらないため呼び出し側の大部分は無変更）。
5. `features/quiz/domain/entity/quiz_searched_item.dart`を削除。
6. `card_view.dart`と`reverse_curve.dart`を`core/presentation/components/card/`へ移動し、2つの参照元のimportを更新。
7. `dart analyze`（対象ファイル中心）で型エラーが無いことを確認。
8. `dart run tool/check_import_boundaries.dart --check`で対象違反が消えていることを確認し、`--update-baseline`でbaselineを実態に合わせる。

## 検証

- `dart analyze lib/core/domain/entity/verb/conjugacion lib/core/infrastructure/repositories lib/features/search lib/features/quiz lib/core/presentation/components/card`
- `dart run tool/check_import_boundaries.dart --baseline tool/import_boundaries/baseline.json --check`

## contexts更新方針

- `feature-map.md`の"Catalog ownership note"を更新し、解消済み部分と残タスクを分離する。
- `next-phase-guide.md`の"Phase 1-5/1-6: ownership整理"に、残るWordPage<->Quiz/Search embedding課題を次の作業単位として明記する。
- `current.md`は全体結論に影響する場合のみ更新する。

## 完了条件（このスライス）

- [x] `core`から`features/quiz`への型依存が0（`ConjugacionSearchResultItem`移設分）
- [x] Search domainがQuiz entityをimportしない
- [x] `feature:quiz` <-> `feature:search`の双方向importが0
- [ ] `CardView`がdesign system配下にあり、Search/Quizどちらのfeatureにも属さない（見送り。Phase 1-6のstatus button ownership整理後に再検討）
- [x] baselineが実態と一致する（`dart run tool/check_import_boundaries.dart --check`がexit code 0）
