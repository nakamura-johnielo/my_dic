`word_status`は、公開Repositoryを廃止して「単体read・watch・batch read・command」を分離する方針が最もルールに適合します。物理的な西日／日西dataset、Firestore wire、同期IDは維持し、論理contractと境界だけを段階的に整理します。

## 現状の主な差分

- [repository.dart](C:/Users/deded/Documents/LocalDev/my_dic/lib/features/word_status/port/repository.dart:6) がread/watch/writeを一つに集約した公開Repositoryになっている。
- `accountId`がraw `String`で、updateのscopeがCommand外に分離されている。
- `watch`が`Stream<WordStatus>`なので、DB例外をtyped failureへ正規化できない。
- [word_status.dart](C:/Users/deded/Documents/LocalDev/my_dic/lib/features/word_status/port/word_status.dart:1) がmodel定義であり、唯一のbusiness facadeになっていない。
- [composition.dart](C:/Users/deded/Documents/LocalDev/my_dic/lib/features/word_status/port/composition.dart:5) がinternal実装と`DatabaseProvider`を直接参照している。
- [presentation_entry.dart](C:/Users/deded/Documents/LocalDev/my_dic/lib/features/word_status/port/presentation_entry.dart:1) がinternal provider／view modelをre-exportしている。
- 方向別adapterに`dynamic` rowと重複mappingがある。
- Firebase adapterがUserProfileのwire DTOに依存している。
- Rankingが[WordStatus tableを直接参照](C:/Users/deded/Documents/LocalDev/my_dic/lib/features/ranking/internal/infrastructure/drift/ranking_dao.dart:5)している。
- 現在のテストには、存在しない旧presentation pathや旧class名を参照するものが残っている。

## Ownership matrix

| Owner | 所有するもの | 所有しないもの |
|---|---|---|
| WordStatus | account scope × `CatalogWordRef`の状態、read/watch/update invariant、物理row欠落時の意味、方向別永続化・同期mapping、guest merge | Catalog word本体、sessionの現在値、Rankingのfilter/paging |
| Catalog | `CatalogWordRef`とCatalog identity | ユーザー別status |
| Auth／Session | account identityの正本、guest/sign-in判定、session epoch | statusの状態と保存規則 |
| Sync | queue、retry、checkpoint、実行runtime | WordStatus payload、field mask、競合mapping |
| Consumer | 表示位置、filter、warning、paging、navigation | WordStatus table、wire DTO、write lifecycle |
| `app/bootstrap` | instance、lifetime、sessionからscopeへの変換、feature間結線 | WordStatusの業務semantics |

## 目標構造

```text
lib/features/word_status/
├─ port/
│  ├─ word_status.dart                 # 唯一のbusiness facade
│  ├─ model/
│  │  ├─ word_status.dart
│  │  └─ word_status_scope.dart
│  ├─ query/
│  │  ├─ read_word_status_query.dart
│  │  └─ read_word_status_batch_query.dart
│  ├─ command/
│  │  └─ update_word_status_command.dart
│  ├─ result/
│  │  └─ word_status_batch.dart
│  ├─ reader/
│  │  ├─ word_status_reader_port.dart
│  │  ├─ word_status_watch_port.dart
│  │  └─ word_status_batch_reader_port.dart
│  ├─ command/
│  │  └─ word_status_command_port.dart
│  ├─ error/
│  │  ├─ word_status_read_error.dart
│  │  └─ word_status_write_error.dart
│  ├─ guest_migration.dart
│  ├─ composition.dart
│  ├─ presentation_dependencies.dart
│  └─ presentation_entry.dart
└─ internal/
   ├─ application/
   ├─ domain/
   ├─ infrastructure/
   │  ├─ drift/
   │  ├─ firebase/
   │  ├─ sync/
   │  └─ guest_migration/
   ├─ presentation/
   └─ factory/
```

## 公開contract

次の細粒度portへ分割します。

```dart
WordStatusReaderPort.read(query)
    -> Future<Result<WordStatus>>

WordStatusWatchPort.watch(query)
    -> Stream<Result<WordStatus>>

WordStatusBatchReaderPort.readBatch(query)
    -> Future<Result<WordStatusBatch>>

WordStatusCommandPort.update(command)
    -> Future<Result<void>>
```

契約上の要点:

- Query／Command自身が`CatalogWordRef`とtyped account scopeを保持する。
- `updatedAt`はcallerに渡させず、application serviceがclockから決定する。
- 物理rowがない場合はnot-foundではなく「全flag falseの初期状態」とする。
- 初期状態の`updatedAt`はepoch sentinelではなく`null`などの明示的表現にする。
- batchはempty inputをempty successとし、物理row欠落分も初期状態として返す。
- unsupported Catalog、DB障害、corrupt rowをWordStatus所有のtyped errorへ正規化する。
- `CatalogId.values`全件への暗黙依存をやめ、対応Catalogを明示する。
- raw account `String`を公開contractから除く。account ID自体はSession/Auth所有のvalue objectを利用し、WordStatusはguest/accountのscopeだけを表現する。

## 段階的な実装計画

### Phase 0: baselineと契約決定

- sourceとtestでずれているclass名・presentation pathをまず整合させる。
- 現行挙動をcharacterization testで固定する。
- 特に以下を決定・記録する。
  - row欠落＝全false
  - no-op command＝成功かArgumentErrorか。互換性優先なら成功を維持
  - batchの上限、重複wordの扱い
  - unsupported Catalogの扱い
  - 西日側の`>=`と日西側の`>`という現在の時刻境界差が仕様か不具合か
- schema／wire変更が必要な修正は別ADRへ分離する。

完了条件: 現行の正しい挙動と、変更対象外のprotocolがテストで明示されている。

### Phase 1: 新しいpublic surface

- sole facadeとして`port/word_status.dart`を作る。
- model、Query、Command、Result、typed error、4種類のportを追加する。
- guest migration capabilityもbusiness facadeから公開する。
- 既存Repositoryは移行期間中だけ残し、新portから旧実装へ接続するshimを用意する。

完了条件: 新contractがpure Dartで、Flutter／Riverpod／Drift／Firebase／Sync型を含まない。

### Phase 2: applicationとDrift adapter

- public portを実装するWordStatus application serviceを追加する。
- Repository abstractionはinternalへ移す。
- 方向別generated rowを内部の正規化recordへ変換し、`dynamic`を排除する。
- watchを`Stream<Result<WordStatus>>`へ変換し、stream errorもtyped errorにする。
- batch readerはCatalog別にまとめて問い合わせ、N+1 queryを避ける。
- status row更新とoutbox enqueueのtransaction ownerを一箇所にする。
- productionの`AppLogger.print`を削除する。

完了条件: 単体read/watch/update/batchが新portから動作し、DB rowや`DatabaseError`が公開境界へ出ない。

### Phase 3: composition、sync、guest migration

- owner assemblyを`internal/factory/**`へ移す。
- `port/composition.dart`はfactoryへのcontrolled seamだけにする。
- `WordStatusPorts`をreader/watch/batch/command/guest migrationのbundleへ更新する。
- `DatabaseProvider`やinternal DAOをcompositionの公開signatureから除く。
- `SyncDataset` stable ID、Firestore collection、field mask、revision、cursorを変更せず、既存sync adapterを新factoryへ接続する。
- Firebase DAOから`UserDTO.collectionName`依存を除き、account document pathを中立なinfrastructure contractへ移す。
- guest migrationのOR merge、transaction参加、deterministic mutation IDを維持し、typed failureへ正規化する。

完了条件: appはtechnical composition seamだけを使い、sync protocolとguest migration結果が現行互換。

### Phase 4: presentation境界

- `presentation_entry.dart`からinternal provider／view modelのexportを削除する。
- 外部公開は制御されたWidgetまたはbutton rendererだけに限定する。
- `presentation_dependencies.dart`へreader、command、scope resolverを明示する。
- appがSessionをWordStatus scopeへ変換する。
- single-flight、effect一回消費、live update、loading/error表示を維持する。
- MyWordとの共有範囲はbutton UIと小さなpresentation contractだけに留める。

完了条件: internal providerをappでoverrideせず、public entryへ明示的な依存を渡して描画できる。

### Phase 5: consumer移行

- WordDetail、Quiz、RankingへWordStatus widget builderをpresentation dependencyとして注入する。
- consumer internalからWordStatus presentation entryの直接importを削除する。
- Ranking用required gatewayをRanking側に定義し、`lib/integration/word_status_ranking`でbatch portへ接続する。
- RankingからWordStatus table import、`EXISTS word_status` SQLを削除する。
- guest migration workflowは個別`port/guest_migration.dart`ではなくbusiness facadeをimportする。

完了条件: consumerがWordStatusのfacade／明示されたtechnical seam以外を参照せず、RankingがWordStatus保存形式を知らない。

### Phase 6: legacy削除と境界固定

- `repository.dart`、旧`commands.dart`、旧use case shimを参照0確認後に削除する。
- stale test pathと旧class名を新構造へ移す。
- import checkerへWordStatus固有ルールを追加する。
  - external business importは`port/word_status.dart`のみ
  - compositionは`app/bootstrap`のみ
  - presentation entryはapp-owned presentation wiringのみ
  - integrationからinternal／DAO／Firebaseへの依存禁止
- ADR 0001のfollow-upとWordStatus public-surface manifestを更新する。

## 検証順序

1. portのvalidation／absence／typed error test
2. application service test
3. 両方向のin-memory Drift contract test
4. sync／outbox／guest migration test
5. `word_status_ranking` adapter test
6. presentation widget／acceptance test
7. `dart run tool/check_feature_dependencies.dart`
8. `dart run tool/check_import_boundaries.dart`
9. `dart analyze`
10. repository全体の`flutter test`

## Phase 5–6 completion record

- WordDetail、Quiz、Rankingはappから注入されたcontrolled rendererを利用し、
  WordStatus presentation internalを参照しない。
- Rankingのstatus取得は`lib/integration/word_status_ranking`からbatch portへ
  接続され、WordStatus tableと保存形式を参照しない。
- guest migration consumerはsole business facadeをimportする。
- 旧`repository.dart`、`commands.dart`、`guest_migration.dart`、旧use caseは
  参照0を確認して削除した。
- compositionは単一canonical factory bridgeを使い、remote document操作は
  SDK-free gatewayを介してFirestore integration adapterへ接続する。
- schema、wire、stable dataset IDs、cursor順序、guest OR merge、UI挙動は
  変更していない。

## 対象外

- Drift schema、table名、column、primary key
- Firestore collection／document／field形式
- `SyncDataset` stable IDと競合protocol
- route、画面デザイン、button挙動
- MyWordStatusのWordStatusへの統合
- Rankingのfilter／paging policy

なお、現在のworktreeにはWordStatus以外を含む多数の未コミット変更があり、sourceとtestにも移行途中の不整合があります。このため今回はファイル変更やテスト実行は行わず、現在の状態を前提に計画のみ整理しました。
