# MyWord refactor plan

## 1. 目的とスコープ

MyWord feature を Catalog と同じ境界原則へ移行する。

- feature 外の業務コードは、単一 facade
  `package:my_dic/features/my_word/port/my_word.dart` だけを利用する
- `port/**` の業務契約は pure Dart とし、`internal/**` の型を再 export しない
- Riverpod、Drift、Firebase、Widget、DAO、data source は公開業務契約へ出さない
- composition と Flutter entry は用途を限定した technical seam とする
- MyWord と MyWordStatus は同じ owner に残すが、別 write aggregate として扱う
- dataset 固有の local/remote mapping と Sync adapter は MyWord が所有し、
  retry、queue、checkpoint、scheduling は Sync が所有する
- guest migration は app-owned workflow のまま、MyWord 側の処理を高水準 port で提供する

対象は `lib/features/my_word/**` と、その直接 consumer である
`lib/app/bootstrap/**`、`lib/app/guest_migration/**`、`lib/app/routing/**`、関連 test、
boundary checker、文書である。

この計画では、次を変更しない。

- Drift schema version、table/column/index/primary key、migration SQL
- Firebase collection/document/field、revision、tombstone、outbox payload
- `SyncDataset.myWords` / `SyncDataset.myWordStatus` の stable ID と同期順序
- UUID の wire 表現、guest/account scope の意味
- create/update/delete/status update の validation とエラーメッセージ
- route、画面仕様、pagination、status button の `hasNote` 挙動
- Catalog word、辞書 WordStatus、MyWord の ownership

ページング改善、UI refresh、MyWord と Catalog の統合、MyWordStatus と WordStatus の
domain 統合は別変更とする。

## 2. 現状の問題

現行の `port` は完成した公開契約ではなく、次の暫定 bridge を含む。

- `query.dart` が internal application query/model を再 export する
- `result.dart` が internal domain entity と presentation UI model を再 export する
- `guest_migration.dart` が Drift 型を含む local data source を再 export する
- `composition.dart` が Riverpod provider と internal DI を公開する
- `presentation_entry.dart` が internal widget を直接再 export し、feature 内の view が
  `internal/composition/view_model_di.dart` を参照する
- command facade はコメントアウトされた export だけで、公開契約として成立していない
- app guest migration が MyWord の data source を直接操作している

2026-08-11 時点の checker 実測では、MyWord に次の違反がある。

- `business_port_no_framework`: `guest_migration.dart`、`query.dart`、`result.dart`
- `composition_exact_facade`: `composition.dart` から internal DI/factory への不正な公開
- `composition_no_framework` / `composition_no_provider_types`: Riverpod provider の公開
- `presentation_entry_exact_facade`: command/query/result/guest migration の internal export
- `internal_clean_architecture`: 4 view から `internal/composition/view_model_di.dart` への依存

## 3. 確定する ownership

### MyWord が所有するもの

- MyWord の文字列 ID、headword、description、updated time
- create/read/update/delete と validation
- account scope、local-first write、revision、tombstone、outbox mapping
- MyWord に従属する MyWordStatus と status update/watch
- MyWord と MyWordStatus を合成した card 用 read projection
- `my_words` / `my_word_status` dataset 固有の local/remote DTO と Sync adapter
- MyWord/MyWordStatus の guest row count と移行処理
- MyWord の画面、view model、effect consumption

### MyWord が所有しないもの

- Catalog word と Catalog identity
- 辞書 WordStatus
- session の正本、account switch、epoch activation
- cross-feature guest migration transaction の開始と session fence
- Sync retry、queue、checkpoint、cancellation、scheduling
- database connection lifecycle と app route graph

依存方向は次とする。

```text
app routing / guest migration / sync composition
                    |
                    v
      MyWord facade / technical seams
                    |
                    v
            MyWord internal
                    |
          +---------+---------+
          v                   v
        core              Sync public port
```

MyWord presentation から WordStatus の限定 presentation entry への一方向依存は、
共通 status button UI の利用として維持する。WordStatus から MyWord への逆依存は許可しない。

## 4. 目標ディレクトリ

```text
lib/features/my_word/
├─ port/
│  ├─ my_word.dart
│  ├─ command.dart
│  ├─ query.dart
│  ├─ result.dart
│  ├─ guest_migration.dart
│  ├─ composition.dart
│  └─ presentation_entry.dart
└─ internal/
   ├─ application/
   │  ├─ command/
   │  ├─ query/
   │  └─ mapper/
   ├─ domain/
   │  ├─ entity/
   │  └─ repository/
   ├─ infrastructure/
   │  ├─ drift/
   │  ├─ firebase/
   │  ├─ guest_migration/
   │  └─ sync/
   ├─ presentation/
   │  ├─ provider/
   │  ├─ state/
   │  ├─ view_model/
   │  └─ view/
   └─ factory/
      ├─ my_word_ports_factory.dart
      └─ my_word_sync_factory.dart
```

最初の変更では、既存 infrastructure の細かな path rename を必須にしない。
依存境界を先に完成させ、rename は参照切替後の機械的なフェーズに分離する。

## 5. 公開 surface

### 5.1 業務 facade

feature 外の業務 import は次だけとする。

```dart
import 'package:my_dic/features/my_word/port/my_word.dart';
```

`my_word.dart` は次の pure contract group を export する。

- shared `Result<T>`
- command: register、update、delete、status update
- query: page load と single-item watch
- result/model: MyWord、MyWordStatus、card projection
- focused application ports
- high-level guest migration port

公開型は `port` 内で定義し、internal entity、repository、use case interface、UI model を
再 export しない。公開型の exact list は実装時に
`docs/refactor-v0.3/my-word-public-surface.md` へ記録する。

### 5.2 Command contract

既存 validation と wire identity を維持するため、最初の移行では ID と account scope は
文字列のまま扱う。UUID validation を追加する `MyWordId` value object 化は行わない。

```dart
final class RegisterMyWordCommand {
  final String headword;
  final String description;
  final String accountScope;
}

final class UpdateMyWordCommand {
  final String myWordId;
  final String headword;
  final String description;
  final String accountScope;
}

final class DeleteMyWordCommand {
  final String myWordId;
  final String accountScope;
}

final class UpdateMyWordStatusCommand {
  final String myWordId;
  final FieldUpdate<bool> isLearned;
  final FieldUpdate<bool> isBookmarked;
  final FieldUpdate<bool> hasNote;
  final String accountScope;
}
```

focused port は旧 `I*UseCase.execute(...)` をそのまま外へ出さず、意図が分かる operation 名を
持たせる。

```dart
abstract interface class MyWordCommandPort {
  Future<Result<String>> register(RegisterMyWordCommand command);
  Future<Result<void>> update(UpdateMyWordCommand command);
  Future<Result<void>> delete(DeleteMyWordCommand command);
}

abstract interface class MyWordStatusCommandPort {
  Future<Result<void>> updateStatus(UpdateMyWordStatusCommand command);
}
```

### 5.3 Query と result contract

既存ページング挙動を変えないため、初回移行では page result の `hasMore` 契約を新設せず、
現在と同じ ID list を返す。Catalog と同じ `size + 1` 契約へ変更する場合は、別の
behavior change として characterization test を追加してから行う。

```dart
final class LoadMyWordsQuery {
  final int size;
  final int page;
  final String accountScope;
}

final class WatchMyWordItemQuery {
  final String myWordId;
  final String accountScope;
}

abstract interface class MyWordReaderPort {
  Future<Result<List<String>>> loadIds(LoadMyWordsQuery query);
  Stream<MyWordItem?> watchItem(WatchMyWordItemQuery query);
}
```

公開 result は framework-free な snapshot とし、`@immutable` のためだけに Flutter を
import しない。必要なら `meta` も使わず、const、value equality、copy method を Dart だけで
実装する。

- `MyWord`: `wordId`、`headword`、`description`、`updatedAt`
- `MyWordStatus`: `wordId`、3 flags、`updatedAt`
- `MyWordItem`: MyWord と MyWordStatus の read-only projection

既存 internal entity の `word` / `contents` / `editAt` と公開名の変換は owner mapper が行う。
Drift row、Firebase DTO、presentation の `MyWordItemUiModel` は公開しない。

### 5.4 Guest migration contract

app workflow から local data source を排除し、WordStatus と同程度の高水準 port にする。

```dart
final class MyWordGuestRowCounts {
  final int words;
  final int statuses;
}

abstract interface class MyWordGuestMigrationPort {
  Future<MyWordGuestRowCounts> countGuestRows();

  Future<void> migrateGuestRows({
    required String accountId,
    required String migrationId,
    required DateTime Function() clock,
  });
}
```

adapter は MyWord と MyWordStatus の対応、collision policy、outbox enqueue を内部で処理する。
cross-feature transaction と session fence は引き続き app workflow が所有する。

### 5.5 Technical seams

次は `my_word.dart` から export しない。

- `port/composition.dart`: pure application/Sync composition
- `port/presentation_entry.dart`: controlled Flutter entry

`composition.dart` は Riverpod、DatabaseProvider、Firebase、Drift、Provider/Override を
signature に出さない。

```dart
enum MyWordDependency { database, outboxWriter }

typedef MyWordDependencyReader = T Function<T>(MyWordDependency dependency);

final class MyWordPorts {
  final MyWordReaderPort reader;
  final MyWordCommandPort commands;
  final MyWordStatusCommandPort statusCommands;
  final MyWordGuestMigrationPort guestMigration;
}

MyWordPorts createMyWordPorts(MyWordDependencyReader read);
```

Sync contribution は現行 `DatasetSyncHandler` / `SyncHandlerRuntime` 契約を維持し、
`MyWordSyncDependency` と 2 factory を pure facade に残す。`composition.dart` が到達できる
internal file は `internal/factory/**` の owner factory のみに限定する。

`presentation_entry.dart` は Provider/Override を公開せず、app が解決した scope と port を
constructor で受け取る controlled entry とする。

```dart
class MyWordPresentationPage extends StatelessWidget {
  const MyWordPresentationPage({
    required this.scope,
    required this.ports,
  });

  final SessionScopeKey scope;
  final MyWordPorts ports;
}
```

Riverpod scope/override が必要なら `internal/presentation/**` 内で組み立てる。

## 6. 実装フェーズ

### Phase 0: characterization と current contract 固定

production code を変更する前に、既存 test を整理し不足分を追加する。

- register: trim、空 headword、100/1000 文字境界、UUID 返却
- load: page/size validation、offset、account isolation、順序
- update/delete: validation、not found、tombstone、outbox field mask/revision
- status: default row、partial update、watch、outbox
- projection: missing status の default、word/status の account scope 一致
- guest migration: counts、pair migration、collision、idempotency、rollback
- Sync: dataset stable ID、remote/local mapping、ack、retry/dead-letter propagation
- presentation: page 0、same-page retry、duplicate suppression、account epoch 切替、effect once

既存 test の internal import は Phase 0 では許容し、移行後に public contract test と
owner-internal test へ分類する。期待値を弱めて test を通さない。

### Phase 1: pure public contract と facade を追加

- `command.dart`、`query.dart`、`result.dart` を port-local 定義へ置換する
- focused command/reader ports を定義する
- guest migration の高水準 contract を定義する
- `my_word.dart` を sole business facade として追加する
- public surface contract test を追加し、export closure に framework/internal 型がないことを検査する
- この時点では旧 interactor/provider を削除しない

### Phase 2: application adapter を新 port へ接続

- 旧 input data を public command/query へ置換する
- register/load/update/delete/status/watch を新 focused port の実装へまとめる
- internal domain entity から public result model への mapper を追加する
- `IMyWordItemQueryRepository` を owner-internal repository seam に戻し、外部には
  `MyWordReaderPort.watchItem` だけを見せる
- `I*UseCase`、`*InputData` は移行中だけ compatibility adapter として残す
- validation、error code/message、DateTime UTC 化を characterization test で固定する

### Phase 3: infrastructure と error mapping を閉じる

- Drift repository/query が public application port を実装する owner adapter になる
- Drift/Firebase row と公開 result の変換を internal mapper に集約する
- Database/Firebase exception を既存 `AppError` 系へ変換し、raw exception を公開契約へ出さない
- local data source、repository input model、DAO、remote DTO は internal のまま維持する
- schema/wire snapshot test で runtime 差分がないことを確認する

### Phase 4: guest migration を capability 化

- `MyWordGuestMigrationAdapter` に count と migrate の全 MyWord 固有処理を移す
- outbox writer は composition 時に owner adapter へ注入する
- app の `DetectGuestDataUseCase` / `MigrateGuestDataUseCase` は
  `MyWordGuestMigrationPort` だけに依存させる
- app から `IMyWordLocalDataSource` / `IMyWordStatusLocalDataSource` import を削除する
- transaction、session fence、共通 migration ID は app に残す
- collision と MyWord/MyWordStatus pair を壊さない contract test を追加する

### Phase 5: pure composition facade

- `internal/factory/my_word_ports_factory.dart` で DAO、repository、application port、
  guest migration を組み立てる
- `port/composition.dart` は pure dependency reader と factory だけにする
- `infra_di.dart` の provider export を削除する
- app-owned `myWordPortsProvider` を `lib/app/bootstrap/**` に追加し、database、outbox を注入する
- 既存 2 dataset sync factory は同じ scope/runtime から handler を構築することを test する
- Firebase/Drift/Riverpod 型が composition の public signature にないことを checker で固定する

### Phase 6: presentation composition の分離

- `view_model_di.dart` の presentation provider を
  `internal/presentation/provider/**` へ移す
- view/provider は `MyWordPorts` の pure interface に依存し、
  `internal/composition/**` を import しない
- `presentation_entry.dart` を controlled `MyWordPresentationPage` に置換する
- app router は scope と `MyWordPorts` を注入し、MyWord internal widget/provider を import しない
- status effect listener と consume-once は MyWord presentation owner に残す
- WordStatus の共通 button contract への依存は public presentation entry 経由に限定する
- 4 件の presentation-to-composition 違反を 0 にする

### Phase 7: consumer 移行と legacy 削除

- app、integration、test の MyWord business import を `port/my_word.dart` へ移す
- technical consumer だけ `composition.dart` / `presentation_entry.dart` を使用する
- 参照 0 を確認して旧 `I*UseCase`、input data、port の internal re-export、provider alias を削除する
- dead code の `WatchMyWordUsecase` などは、production/test/generated の参照 0 を確認した場合だけ削除する
- path rename が generated Drift part に影響する場合だけ build runner を実行し、生成差分を審査する

### Phase 8: checker と文書

- Catalog と同じ facade rule を MyWord に追加する
  - feature 外からの業務 import は `port/my_word.dart` のみ
  - technical exception は `composition.dart` と `presentation_entry.dart` のみ
  - feature 外から `my_word/internal/**` を禁止
  - `port/**` から internal への bridge は composition factory と presentation entry のみ
  - business port の Flutter/Riverpod/Drift/Firebase import を禁止
- positive/negative fixture test を両 checker に追加する
- `my-word-public-surface.md`、ADR 0001 の follow-up、import-boundaries、remaining-work を更新する
- repository 全体の既存非 MyWord 違反は MyWord 完了と混同せず、remaining work に記録する

## 7. Test strategy

### Public contract test

- facade の全公開型を単一 import から利用できる
- command/query/result は pure Dart
- query validation と Result failure が既存契約どおり
- internal entity、UI model、repository、data source、Provider 型が外から見えない

### Application test

- CRUD、status update/watch、page load、item projection
- validation field key/message
- account scope と UTC timestamp
- not found と infrastructure error propagation

### Drift/Sync contract test

- schema と generated SQL/type の非変更
- revision、tombstone、outbox payload/field mask
- local/remote mapping、ack、remote apply
- MyWordStatus と MyWord の dataset dependency

### Guest migration test

- count、成功、no-op retry、collision、pair preservation
- transaction rollback と session change
- app workflow が MyWord local data source を import しない

### Presentation test

- controlled entry に fake `MyWordPorts` を注入して ProviderContainer なしでも port を test できる
- 初回 load、pagination retry、account epoch reset、stale response discard
- create/update/delete/status effect の一回表示と dispose 後の通知抑止

## 8. 完了条件

- `my_word.dart` が sole business facade である
- MyWord の business port に framework import が 0 件
- MyWord port から internal entity/repository/data source/provider の export が 0 件
- app/integration から `features/my_word/internal/**` import が 0 件
- app guest migration から MyWord local data source import が 0 件
- MyWord presentation から `internal/composition/**` import が 0 件
- MyWord composition の public signature に Provider/Override/DatabaseProvider/SDK 型が 0 件
- MyWord に起因する両 boundary checker 違反が 0 件
- schema、Firebase wire、Sync stable ID、outbox/tombstone semantics に差分がない
- MyWord public/application/Drift/Sync/guest migration/presentation test が green
- targeted `dart analyze` と full `flutter test` が green
- 一時 compatibility export/provider/adapter が参照 0 後に削除済み

## 9. 実装時の停止条件

次が必要になった場合は、同じリファクタへ黙って含めず方針を再確認する。

- public ID を `String` から UUID value object へ変更する
- page result に `hasMore` を追加し SQL を `size + 1` に変える
- validation code/message または not-found semantics を変更する
- `hasNote` no-op を実装または削除する
- MyWordStatus を WordStatus feature へ移す
- guest migration の collision/transaction policy を変更する
- schema、Firebase wire、Sync order/stable ID を変更する
- MyWord 以外の feature debt を同時に解消する
