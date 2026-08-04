# リファクタ文書インデックス

このディレクトリは、[`FLUTTER_ARCHITECTURE_REVIEW.md`](../FLUTTER_ARCHITECTURE_REVIEW.md) の調査結果を、LLMまたは開発者が必要な作業だけ読み込める単位へ分割したものである。

## 最初に読む文書

| 文書 | 内容 | 読むタイミング |
| --- | --- | --- |
| [`summary.md`](summary.md) | 現状、目標アーキテクチャ、全フェーズ共通の設計原則、進め方 | 新しい作業セッションの開始時 |
| [`FLUTTER_ARCHITECTURE_REVIEW.md`](../FLUTTER_ARCHITECTURE_REVIEW.md) | 調査根拠、依存関係、問題箇所の詳細を含む原本 | 判断根拠や追加調査が必要な時、量が膨大なため必須ではない。phaseごとのmdの方が詳細に書かれている。 |

## Phase 0: データと認証情報を守る

Phase 0は機能追加や大規模移動より先に実施する。データ消失、認証情報漏えい、同期欠落、失敗の誤認を止めるフェーズである。

| 順序 | 文書 | 内容 |
| --- | --- | --- |
| 1 | [`phase0/1-remove-sensitive-auth-logging.md`](phase0/1-remove-sensitive-auth-logging.md) | refresh tokenを含む機密情報ログを削除し、再混入を防ぐ |
| 2 | [`phase0/2-repair-v5-migration.md`](phase0/2-repair-v5-migration.md) | DB v5 migrationのMyWord status消失を修正し、fixture testを作る |
| 3 | [`phase0/3-scope-sync-checkpoints.md`](phase0/3-scope-sync-checkpoints.md) | 同期checkpointをaccount・dataset単位に分離する |
| 4 | [`phase0/4-fix-result-propagation.md`](phase0/4-fix-result-propagation.md) | `Result`の誤判定と握りつぶしを修正する |
| 5 | [`phase0/5-rebuild-status-sync.md`](phase0/5-rebuild-status-sync.md) | statusの部分更新、dirty/outbox、両辞書方向の同期を修正する |
| 6 | [`phase0/6-complete-auth-user-lifecycle.md`](phase0/6-complete-auth-user-lifecycle.md) | Sign Up、メール確認、User profile作成のライフサイクルを成立させる |

## Phase 1: 境界を固定する

Phase 1では、今後の変更で依存関係が再び崩れないよう、composition、import、route、session、feature ownershipを固定する。

| 順序 | 文書 | 内容 |
| --- | --- | --- |
| 1 | [`phase1/1-create-composition-root.md`](phase1/1-create-composition-root.md) | DB、Router、横断effectを`app/bootstrap`へ集約する |
| 2 | [`phase1/2-enforce-import-boundaries.md`](phase1/2-enforce-import-boundaries.md) | 依存規則を文書化し、CIで禁止importを検出する |
| 3 | [`phase1/3-extract-route-contracts.md`](phase1/3-extract-route-contracts.md) | route引数をView実装から分離し、deep link可能にする |
| 4 | [`phase1/4-introduce-current-session.md`](phase1/4-introduce-current-session.md) | 認証状態の単一source of truthと`CurrentSession` portを導入する |
| 5 | [`phase1/5-define-catalog-ownership.md`](phase1/5-define-catalog-ownership.md) | Search、Quiz、WordPage間の共有概念の所有者を決める |
| 6 | [`phase1/6-unify-word-status.md`](phase1/6-unify-word-status.md) | 西和・和西のword status featureを統合する |

## Phase 2: ApplicationとPresentationを整理する

Phase 2では、Phase 1で決めた境界に沿ってUseCase、UI state、副作用、query model、同期結果を整理する。

| 順序 | 文書 | 内容 |
| --- | --- | --- |
| 1 | [`phase2/1-move-usecases-to-application.md`](phase2/1-move-usecases-to-application.md) | orchestration UseCaseをdomainからapplicationへ移す |
| 2 | [`phase2/2-standardize-viewmodel-state.md`](phase2/2-standardize-viewmodel-state.md) | loading、data、empty、failureのUI stateを統一する |
| 3 | [`phase2/3-remove-build-time-io.md`](phase2/3-remove-build-time-io.md) | Widgetの`build()`からDB・fetch副作用を除去する |
| 4 | [`phase2/4-remove-ref-from-coordinators.md`](phase2/4-remove-ref-from-coordinators.md) | Coordinatorから`Ref`を除き、依存を明示する |
| 5 | [`phase2/5-separate-query-projections.md`](phase2/5-separate-query-projections.md) | 画面用read modelとwrite domain entityを分離する |
| 6 | [`phase2/6-return-sync-report.md`](phase2/6-return-sync-report.md) | `SyncService`からdataset別の`SyncReport`を返す |

## Phase 3: 残骸と重複を削除する

Phase 3は挙動と境界がテストで固定された後に行う。削除・rename・大型クラス分割を安全に進めるフェーズである。

| 順序 | 文書 | 内容 |
| --- | --- | --- |
| 1 | [`phase3/1-remove-unused-abstractions.md`](phase3/1-remove-unused-abstractions.md) | 未使用Presenterや機械的な入出力型を削除する |
| 2 | [`phase3/2-consolidate-copy-files.md`](phase3/2-consolidate-copy-files.md) | `copy.dart`を正規実装へ統合する |
| 3 | [`phase3/3-remove-obsolete-coordinators.md`](phase3/3-remove-obsolete-coordinators.md) | コメントアウトされた旧Coordinatorを削除またはADR化する |
| 4 | [`phase3/4-normalize-names.md`](phase3/4-normalize-names.md) | typoとファイル命名をrename-onlyで修正する |
| 5 | [`phase3/5-clean-dependencies-and-imports.md`](phase3/5-clean-dependencies-and-imports.md) | package宣言、unused dependency、unused importを整理する |
| 6 | [`phase3/6-split-large-components.md`](phase3/6-split-large-components.md) | 大型DAO、Seeder、同期処理を責務単位に分割する |

## 文書の使い方

1. 新しいセッションでは`summary.md`を読み、全体原則を確認する。
2. 実行対象フェーズのタスク文書だけを追加で読み込む。
3. タスク文書の「依存タスク」が未完了なら、先にその文書を確認する。
4. 実装前に対象パスが現状と一致するか再検索する。行番号は調査時点の参考値である。
5. 完了時はタスク文書のチェックリストとテストを満たし、必要なら文書の状態を更新する。

## 状態表記

各タスク文書の初期状態は`未着手`である。作業管理に利用する場合は、`未着手`、`進行中`、`完了`、`保留`のいずれかへ更新する。
