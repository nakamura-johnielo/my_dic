# Phase 0-4: Resultの誤判定と握りつぶしを修正する

- 状態: 未着手
- 優先度: P1 / 信頼性
- 依存タスク: なし
- 関連タスク: [`5-rebuild-status-sync.md`](5-rebuild-status-sync.md)、[`../phase2/6-return-sync-report.md`](../phase2/6-return-sync-report.md)
- 元調査: [`FLUTTER_ARCHITECTURE_REVIEW.md`](../../FLUTTER_ARCHITECTURE_REVIEW.md) P1-2、P1-4

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
2. `NotFoundError`は`Failure`内部のerrorに対して判定する。
3. failure経路で`dataOrNull!`へ到達しない構造にする。
4. Repository結果を呼出している箇所で、戻り値が未使用になっていないか確認する。
5. best-effortで無視するfailureは、コメントだけでなく専用戻り値やwarningとして明示する。
6. catchする場合は、値として返った`Failure`とthrowされた予期しない例外を分ける。

推奨形:

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
- NotFoundだけが意図したcreate経路へ進む
- DatabaseErrorやNetworkErrorをNotFoundとして扱わない
- failure後に`dataOrNull!`でクラッシュしない
- status保存失敗をViewModelが成功表示しない

## 完了条件

- [ ] error handlingに`runtimeType == AppError/NotFoundError`が残っていない
- [ ] Repositoryの戻り値を意図せず捨てる箇所がない
- [ ] `dataOrNull!`の前提がtestまたは型分岐で保証される
- [ ] 主要failureがUIまたは同期結果まで伝播する
- [ ] failure系testが追加されている

## LLMへの引き継ぎ事項

一括置換だけで終えない。各分岐が「NotFoundならcreate」「通信失敗ならretry」「DB失敗なら停止」など異なる意味を持つため、呼出し文脈ごとに期待動作を確認する。
