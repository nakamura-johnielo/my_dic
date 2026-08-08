# Phase 2-1: orchestration UseCaseをapplication層へ整理する

- 状態: 未着手
- 優先度: 中 / layer責務
- 依存タスク: Phase 1のownershipとimport規則
- 関連タスク: [`../local_first/8-cut-over-and-remove-legacy-sync.md`](../local_first/8-cut-over-and-remove-legacy-sync.md)、[`4-remove-ref-from-coordinators.md`](4-remove-ref-from-coordinators.md)、[`5-separate-query-projections.md`](5-separate-query-projections.md)
- 元調査: [`FLUTTER_ARCHITECTURE_REVIEW.md`](../../FLUTTER_ARCHITECTURE_REVIEW.md) 7.3、7.4、12

## 目的

Repository、session、同期、UI要求を調停するUseCaseを`application`へ置き、`domain`をpureな業務概念・規則・portへ限定する。

## 現在の問題

- 多くのInteractorが`domain/usecase`配下にあるが、実際には複数RepositoryやAuthを調停するapplication serviceである
- domain Interactorが`DatabaseError`を生成する
- domain inputにUI callbackが含まれる
- 同期のlocal/remote保存戦略がdomain契約へ露出する
- 単純なRepository転送にもUseCase interface、InputData、OutputDataが作られている

## 分類規則

| 種類 | 配置 |
| --- | --- |
| Entity、Value Object、不変条件、純粋な業務計算 | `domain` |
| Repository port、domain service port | `domain` |
| 複数portの調停、session取得、transaction、command/query | `application` |
| Firebase、Drift、SharedPreferences実装 | `infrastructure` |
| UI callback、表示message、navigation | `presentation` |

すべてのUseCaseを機械的に移動するのではなく、責務で分類する。

## 実装方針

1. UseCase一覧を作り、依存先と責務を記録する。
2. Repository転送だけのUseCaseは削除またはViewModelからRepository利用を許可するか決める。
3. orchestration UseCaseを`feature/application`へ移す。
4. UI callbackをinputから除き、`Result`または明示的outputを返す。
5. `DatabaseError`など技術failureの生成をadapterへ移す。
6. 同期用Replica portはapplication側へ配置する。
7. Local-firstトラックで作成済みのSyncEngine、SyncQueue contract、dataset handlerを再移動・再設計しない。
8. production registryから外れた旧sync UseCaseはapplicationへ移さず、Local-first 8で削除する。
9. import移動はfeature単位で行い、各単位でanalyze/testを通す。

## 推奨テスト

- application UseCaseをfake portとfake CurrentSessionで単体テストできる
- domain packageのtestにFlutter bindingが不要
- UI callbackなしで成功・失敗が戻り値から判定できる
- architecture checkでdomainからFlutter/Firebase/Drift/Riverpod importが0
- 旧sync UseCaseを移動して延命せず、新SyncEngineだけがorchestrationを所有する

## 完了条件

- [ ] orchestration UseCaseがapplicationへ配置されている
- [ ] domain inputにUI callbackがない
- [ ] domainがinfrastructure errorを生成しない
- [ ] pure domain testがFlutterなしで動く
- [ ] 不要な一対一UseCaseを増やさない方針が明文化されている
- [ ] 旧同期orchestrationがapplication層へ再導入されていない

## LLMへの引き継ぎ事項

目的はフォルダ名の統一ではなく、domainを技術・UI・保存順序から独立させること。大量移動はfeature単位に分割し、renameと挙動変更を同じcommitへ混ぜない。
