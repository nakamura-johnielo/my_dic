# Phase 0-4: Resultの誤判定と握りつぶしを修正する

- 状態: 完了
- 優先度: P1 / 信頼性
- 依存タスク: なし
- 関連タスク: [`5-fix-status-update-contract.md`](5-fix-status-update-contract.md)、[`../local_first/3-build-sync-queue.md`](../local_first/3-build-sync-queue.md)、[`../local_first/4-build-sync-engine.md`](../local_first/4-build-sync-engine.md)
- 元調査: [`FLUTTER_ARCHITECTURE_REVIEW.md`](../../FLUTTER_ARCHITECTURE_REVIEW.md) P1-2、P1-4
- 作業報告: [`4.report.md`](4.report.md)

## 目的

RepositoryやDataSourceが返した`Failure`を成功、NotFound、空データとして誤認せず、Interactor、ViewModel、同期呼出し元まで型安全に伝播させる。

## 現在の問題

同期コードでは`Result.runtimeType`を`AppError`や`NotFoundError`と比較している。しかしruntime typeは`Success<T>`または`Failure<T>`なので条件が成立しない。

主な対象:

- `lib/features/esp_jpn_word_status/domain/usecase/sync_esp_jpn_word_status/sync_esp_jpn_word_status_interactor.dart`
- `lib/features/my_word/domain/usecase/my_word/sync_my_word/sync_my_word_interactor copy.dart`
- `lib/features/my_word/domain/usecase/my_word_status/sync_myword_status/sync_myword_status_usecase.dart`

さらに`UpdateMyWordStatusInteractor`はRepositoryの`Result<void>`を`await`後に捨て、常にsuccessを返す。

## 対象範囲

- `Result.runtimeType`、`dataOrNull!`、空catch、結果未使用の全検索
- 同期UseCaseとMyWord status更新UseCase
- Repository failureの伝播test
- error分類の最小限の整理

## 対象外

- `Result<T>`型そのものの全面置換
- 全error hierarchyの再設計
- 同期ロジックの共通化。まず既存挙動をtestで固定する

## 実装方針

1. `Result`分岐を`when`またはpattern matchingに統一する。
2. データ不存在の表現はAPIの意味で使い分け、同一API内では統一する。
3. failure経路で`dataOrNull!`へ到達しない構造にする。
4. Repository結果を呼出している箇所で、戻り値が未使用になっていないか確認する。
5. best-effortで無視するfailureは、コメントだけでなく専用戻り値やwarningとして明示する。
6. catchする場合は、値として返った`Failure`とthrowされた予期しない例外を分ける。

### NotFoundのAPI契約

NotFoundは一律にerrorまたは`null`へ寄せず、Repository APIが表す操作の意味に合わせて次の2方式を使い分ける。

- 検索系の`find...`では、不存在を正常な検索結果として`Result.success(null)`で返す。戻り値は`Result<T?>`とする。
- 存在必須の`get...`または`require...`では、不存在を`Result.failure(NotFoundError(...))`で返す。戻り値は`Result<T>`とし、成功値をnullableにしない。
- 同一APIで`success(null)`と`NotFoundError`の両方を返してはならない。
- 呼出し側が不存在時にcreateする同期処理は、通常は`find...`を使用する。不在自体がユースケース上の失敗になる場合だけ`get...`または`require...`を使用する。
- 既存APIを修正する際は、名前、戻り値のnullability、Repository実装、Interactorの分岐、testを同じ契約に揃える。

検索系の推奨形:

```dart
return result.when(
  success: (value) {
    if (value == null) return handleNotFound();
    return handleSuccess(value);
  },
  failure: Result.failure,
);
```

存在必須APIの推奨形:

```dart
return result.when(
  success: (value) => handleSuccess(value),
  failure: (error) {
    if (error is NotFoundError) return handleNotFound();
    return Result.failure(error);
  },
);
```

## 必須テスト

- Repositoryが`Result.failure`を返すとInteractorもfailureになる
- `find...`が`success(null)`を返した場合だけ、意図したcreate経路へ進む
- `get...`または`require...`の`NotFoundError`が、API契約に応じた不存在経路へ進む
- 同一Repository APIが不存在を`success(null)`と`NotFoundError`の両方で返さない
- DatabaseErrorやNetworkErrorをNotFoundとして扱わない
- failure後に`dataOrNull!`でクラッシュしない
- status保存失敗をViewModelが成功表示しない

## 完了条件

- [x] error handlingに`runtimeType == AppError/NotFoundError`が残っていない
- [x] Repository APIごとに不存在の表現が一意で、名前と戻り値のnullabilityが契約に一致している
- [x] Repositoryの戻り値を意図せず捨てる箇所がない
- [x] `dataOrNull!`の前提がtestまたは型分岐で保証される
- [x] 主要failureがUIまたは同期結果まで伝播する
- [x] failure系testが追加されている

## LLMへの引き継ぎ事項

一括置換だけで終えない。各分岐が「NotFoundならcreate」「通信失敗ならretry」「DB失敗なら停止」など異なる意味を持つため、呼出し文脈ごとに期待動作を確認する。このタスクはSyncQueueのack/retry分類とSyncEngineのdataset結果を正しく扱う前提であり、未完了のままLocal-first 3・4へ進まない。
