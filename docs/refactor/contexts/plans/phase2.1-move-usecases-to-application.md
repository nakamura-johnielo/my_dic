# Phase 2-1: orchestration UseCase の application 層移行計画

## まとめ

- `CurrentSession`、複数 Repository、保存順序、command/query を扱う処理を各 feature の `application` へ移す。
- domain は entity、value object、純粋な判定規則、Repository port に限定する。
- 単純転送、未使用 Presenter、UI callback 専用 UseCase は削除し、旧同期 UseCase は Local-first 8 まで移動せず凍結する。
- feature ごとに「挙動を変えない移動」と「契約簡素化」を分け、各単位でテストする。

## 実装変更

### 1. 境界ルールと domain 純化

- import checker に以下を追加する。
  - domain から `app/**`、`application/**`、infrastructure error への依存を禁止する。
  - 既存の Flutter/Firebase/Drift/Riverpod/GoRouter 禁止を維持する。
- domain entity 19件の `flutter/foundation.dart`・`flutter/material.dart` を `meta` の `@immutable` に置換し、`meta` を直接依存へ追加する。
- domain source に `void Function` callback、`DatabaseError` 生成、application import が存在しないことを architecture test で固定する。
- 現在 baseline で許容されている7件の `core_no_feature` 違反は本タスクの対象外とし、新規違反だけを禁止する。

### 2. application へ移す UseCase

最終配置は `lib/features/<feature>/application/**` とし、移動コミットでは既存クラス名と戻り値を維持する。

- Word status
  - Esp-Jpn/Jpn-Esp の update、fetch、watch。
  - `CurrentSession` から account scope を決定し、guest は `guestAccountScope` を使う現行仕様を維持する。
  - Phase 1-6 の両方向統合は行わず、それぞれの Repository port と `FieldUpdate<bool>` 契約を維持する。
- MyWord
  - register、update、delete、load、watch、status update/watch。
  - account scope、入力検証、UTC timestamp 生成、Repository 呼び出しを application の責務とする。
  - MyWordStatus の公開 command を `int?` から `FieldUpdate<bool>` に変更する。Repository port も同じ型を受け、`0/1/null` 変換は Drift datasource adapter の直前だけで行う。
- User
  - get、create、update を移し、session 解決、device ID 取得、既存 profile 判定を application に置く。
- Auth
  - 入力検証を持つ sign-in/sign-up を移す。
- Search/Ranking
  - 複数 Repository を調停する検索と、filter/page specification を組み立てる ranking load を移す。
  - application から presentation callback、UI state、navigation を参照しない。
- request/input/output 型は利用する UseCase と一緒に application へ移す。
- Repository port が必要とする patch/filter/page 型は application を逆参照させず、feature の `domain/model` に置く。

### 3. 冗長・誤配置された抽象の削除

- 次の単純転送 UseCase は削除し、既存 composition provider から domain Repository port を直接注入する。
  - core の dictionary/conjugation fetch 3件。
  - Auth の observe、reload、sign-out、verify-email、password-reset。
  - Quiz の English conjugation/template fetch。
  - User の `EnsureUserExistsInteractor`。Auth lifecycle controller は `IUserRepository.ensureUserProfile` を直接呼ぶ。
- Search の辞書方向判定は UseCase ではなく、例外を発生させない pure domain service に変更する。空文字などの入力エラーは application、表示文言は presentation が扱う。
- Ranking の値をそのまま返す filter UseCase と処理が空の pagination UseCaseを削除し、filter/page state 更新を Ranking ViewModel に集約する。
- MyWord の `HandleWordRegistrationInteractor`、callback 入力、未使用 output/repository-input を削除する。ViewModel は register の `Result<String>` を直接成功・失敗 state/effect へ変換する。
- 参照が宣言自身しかない Presenter interface と OutputData を削除する。
- DI provider と ViewModel constructor を新しい application contract または Repository port に更新し、旧 provider export を残さない。
- `I` prefix、`Interactor`、`pagenation`、`.dart` を含むディレクトリ名などの全面 rename は Phase 3へ残す。

### 4. failure と infrastructure 境界

- `LoadRankingsInteractor` と `UpdateMyWordStatusInteractor` から `DatabaseError` の catch/生成を除去する。
- Ranking/MyWordStatus の Repository adapter は現在どおり datasource 例外を `DatabaseError` に変換し、application は返された `Result` を透過的に返す。
- application の入力不正は `ValidationError`、未認証は `UnauthorizedError`、対象不存在は既存の typed not-found error を返す。
- error message は診断情報として扱い、画面表示文言や dialog/navigation は ViewModel の state/effect 変換に限定する。

### 5. 実装順序

1. domain purity の architecture test と現在の振る舞いを固定する characterization test を追加する。
2. Word status を方向単位で機械移動し、import・DI・テストを更新する。
3. MyWord/MyWordStatus を機械移動し、その後の別コミットで callback 削除と `FieldUpdate<bool>` 化を行う。
4. User/Auth を移動し、単純転送 UseCase を削除する。
5. Search/Quiz/core catalog/Ranking を移動または簡素化する。
6. 未使用 Presenter/DTO/provider を削除し、domain の Flutter import を除去する。
7. import baseline は解消した項目だけ削除し、無関係な既存7件は変更しない。

各 feature で、まず移動だけのコミットを作り、公開契約変更・削除・renameを同じコミットへ混在させない。

## テスト計画

- application unit test
  - fake Repository と fake CurrentSession だけで成功・failure、authenticated/guest scope を検証する。
  - register/update/delete が正しい account ID、UTC timestamp、patch を Repository へ渡す。
  - MyWordStatus の未指定フィールドが保持され、bool から `0/1` への変換が datasource 境界だけで行われる。
  - Search は Repository の呼び出し順、ページング、複数結果の合成を検証する。
  - Ranking は include/exclude filter と次ページ計算を検証する。
- presentation test
  - MyWord 登録成功・validation failure・Repository failure が callback を application へ渡さず、state/effect に変換される。
  - Ranking filter 更新と空結果処理が ViewModel 内で維持される。
  - 単純転送 UseCase 削除後も WordPage、Quiz、Auth lifecycle の状態遷移が変わらない。
- adapter test
  - Drift/Firebase/asset 例外が Repository adapter で `DatabaseError` へ変換される。
- architecture test
  - domain の Flutter/Firebase/Drift/Riverpod/GoRouter/application import が0。
  - domain の `DatabaseError` 生成と UI callback が0。
  - production から旧 `ISyncUseCase` 実装への参照が0。
- 各 slice で対象テストと import checkerを実行し、最後に `flutter analyze`、全 `flutter test` を実行する。pure domain test は Flutter binding なしで実行できる形にする。

## 前提・対象外

- 新しい `SyncEngine`、SyncQueue、DatasetSyncHandler、outbox/checkpoint 契約は変更しない。
- `SyncMyWordInteractor`、`SyncMyWordStatusUsecase`、`ISyncUseCase` と旧 remote Repository API は application へ移さず、Local-first 8でまとめて削除する。
- word-status の単一契約化、ViewModel state 標準化、Coordinator/ref 除去、query projection 分離、命名整理は後続タスクへ残す。
- DB schema、同期 protocol、route contract、ユーザー向け挙動は変更しない。
