# ADR 0001: Catalog・WordStatus・MyWord の ownership

## Status

Accepted

## Date

2026-08-08

## Decision owners

- Catalog
- WordStatus
- MyWord

## Context

辞書語彙の domain entity と Repository は現在 `core` にあり、辞書語のユーザー別 status は西日・日西の feature と共通 UI に分散している。MyWord は本体と status が同一 feature 内の別 Repository／table で管理される一方、entity 本体にも status field が残る。これは移行前の物理配置であり、論理 ownership を表すものではない。

現行実装では、次の振る舞いが確認できる。

- 辞書 entity と Repository は [`EspJpnWord`](../../../lib/core/domain/entity/word/word.dart)、[`JpnEspWord`](../../../lib/core/domain/entity/jpn_esp/jpn_esp_word.dart)、[`IConjugacionsRepository`](../../../lib/core/domain/i_repository/i_conjugation_repository.dart) などとして `core` に置かれている。
- `JpnEspWord` は `isLearned`、`isBookmarked`、`hasNote` を持つが、方向別 status は別の [`WordStatus`](../../../lib/features/esp_jpn_word_status/domain/esp_word_status.dart) と [`JpnEspWordStatus`](../../../lib/features/jpn_esp_word_status/domain/jpn_esp_word_status.dart) にも存在する。
- status の Drift table は [`EspJpnWordStatus`](../../../lib/core/infrastructure/database/drift/tables/esp_jpn/word_status.dart) と [`JpnEspWordStatus`](../../../lib/core/infrastructure/database/drift/tables/jpn-esp/jpn_esp_word_status.dart) に分かれ、dataset ID も [`SyncDataset`](../../../lib/core/shared/enums/sync_dataset.dart) で方向別に固定されている。
- 共通 status UI は [`status_button.dart`](../../../lib/features/word_status/presentation/status_button.dart) にあり、方向別実装の選択と MyWord 用 adaptation は app の [`word_status_buttons.dart`](../../../lib/app/presentation/word_status_buttons.dart) が行う。
- MyWord の [`MyWord`](../../../lib/features/my_word/domain/entity/my_word.dart) と [`MyWordStatus`](../../../lib/features/my_word/domain/entity/my_word_status.dart) は identity と Repository が分かれ、[`MyWordRepository._toEntity`](../../../lib/features/my_word/data/repository_impl/my_word_repository.dart) は本体側 status を常に `false` にしている。
- [`DatasetPlan.localFirst`](../../../lib/features/sync/application/policy/dataset_plan.dart) は `my_word_status` が `my_words` に依存する同期順序を定める。

現状全体の索引は [`CURRENT_ARCHITECTURE_REPORT.md`](../../CURRENT_ARCHITECTURE_REPORT.md)、目標構造の rationale と移行順は [`concept.md`](../../refactor-v0.2/concept.md) にある。この ADR は、それらを踏まえた ownership の規範的な source of truth である。

ここでいう **feature ownership** は、用語・identity・invariant・公開 contract・永続化 mapping の意味を変更する責任を持つ論理 module を指す。**account ownership** は、行や document がどのユーザーに属するかというデータ scope を指す。たとえば WordStatus と MyWord は account-owned data を扱うが、その account 自体や session の正本を所有しない。この二つを同一視してはならない。

## Decision drivers

owner は次の軸で判定する。

1. source of truth: 用語と invariant の正本をどこに置くか
2. identity: entity を一意に指す契約を誰が定義するか
3. lifecycle: create／update／delete が何に従属するか
4. account scope: 全ユーザー共通か、account-owned data か
5. transaction／sync coupling: 永続化、同期順序、競合解決を何と一緒に変更するか
6. independent reason to change: consumer や基盤と独立して変更される業務理由は何か

段階移行中も既存 route、schema、Firebase、同期 protocol とユーザー挙動を維持できること、および read 上の共通性を理由に異なる write lifecycle を混ぜないことも判断条件とする。

## Decision

現在の directory や共通 database への table 登録は ownership の根拠にしない。Catalog、WordStatus、MyWord をそれぞれ次の論理 owner とし、consumer と横断基盤は公開 contract 越しに協調しなければならない。

### Catalog

Catalog は、アプリが配布・参照する辞書 master と語彙知識の正本を所有する。

Catalog が所有するもの:

- Catalog 内で一意な word identity contract
- 見出し語、語義、dictionary entry、example、idiom、supplement、品詞
- 辞書データから導出する conjugation と「活用を持つか」の判定
- 西日／日西の構造差を保った Catalog variant
- 検索・詳細・活用取得に必要な公開 read port と、その内部 adapter
- 辞書 master の Repository、DAO、mapper の業務上の意味

Catalog が所有しないもの:

- `isLearned`、`isBookmarked`、`hasNote` などのユーザー別状態
- MyWord と MyWordStatus
- Search の query／pagination／result enrichment、WordDetail の画面 aggregation、Quiz の出題 rule、Ranking の画面 projection
- route／navigation、app-level composition、database connection／transaction runtime

西日と日西は同じ Catalog owner 配下の variant とするが、一つの巨大な nullable entity へ統合してはならない。

現行 `JpnEspWord` の status field は Catalog word の正本ではなく、移行中の互換 field である。正本は WordStatus とし、Catalog word と status を同時に必要とする consumer は read-only query projection で合成する。field の物理削除は移行順序9まで行わない。

`CatalogId`／`CatalogWordRef` の具体的な Dart API、enum 値、validation、serialization は未実装であり、移行順序2で定義する。この ADR は identity contract の owner が Catalog であること、および consumer 独自の `WordType` や direction flag を正本にしてはならないことだけを固定する。

### WordStatus

WordStatus は、account と Catalog word の組に付随する学習状態の正本を所有する。

WordStatus が所有するもの:

- Catalog word の `isLearned`、`isBookmarked`、`hasNote`
- account scope を含む status identity と、状態の watch／update invariant
- 西日／日西で共通の domain model と application contract
- 共通 model と方向別の既存保存形式を接続する mapper／adapter
- 辞書 status の presentation contract と共通 status button UI

WordStatus が所有しないもの:

- Catalog word 本体、dictionary entry、conjugation
- MyWordStatus、account／session の正本
- 汎用 SyncEngine、queue、checkpoint、retry、scheduling
- app が方向別実装を選択して注入する composition

西日／日西 WordStatus は論理 domain model と application contract を一つにしなければならない。ただし、方向別 Drift table、column／primary key、Firebase collection／document、local／remote DTO、mapper、sync handler 接続、および `SyncDataset.espJpnWordStatus`／`SyncDataset.jpnEspWordStatus` の stable ID は物理 dataset として維持する。論理統合は物理 dataset の migration や一本化を意味しない。

### MyWord と MyWordStatus

MyWord は、ユーザーが作成・編集・削除する個人辞書項目とその lifecycle の正本を所有する。

MyWord が所有するもの:

- UUID 文字列の MyWord identity、`word`／`contents` と登録 validation
- create／read／update／delete、tombstone、account scope
- MyWord 固有の local-first write と同期 mapping
- MyWord に従属する MyWordStatus
- `my_word_status` を `my_words` より後に同期する依存制約

MyWord が所有しないもの:

- Catalog word／辞書 master、Catalog identity／read port
- Catalog word 用の WordStatus
- 複数 source を横断する一覧 read model
- 汎用 SyncEngine、queue、checkpoint、retry、scheduling

MyWordStatus は MyWord owner 配下に残さなければならない。MyWordStatus は Catalog word の整数 ID ではなく MyWord の UUID を参照し、MyWord の削除 lifecycle と同期成功に従属する。また `hasNote` は local table／outbox、remote DTO、Firestore rule、UI contract が一致しておらず、辞書 WordStatus と同一 contract ではない。現時点の共有範囲は status button UI と小さな presentation 操作 contract に限る。identity、field、削除、同期、競合解決が実際に一致した場合に限り、別 ADR で共通 status への昇格を検討できる。

Catalog word と MyWord は ID、書き込み可否、account scope、削除、同期、validation の lifecycle が異なるため、同じ write model または共通基底 entity に統合してはならない。両方を同じ一覧に表示するときは consumer または専用 read feature が query projection で合成する。現行 `MyWord` の status field も正本ではなく、MyWordStatus から projection するための過渡的な互換 field であり、物理削除は移行順序9まで行わない。

## Ownership matrix

| Owner／境界 | 正本として所有するもの | 所有しないもの／境界 |
|---|---|---|
| Catalog | 辞書 word identity、語彙知識、Catalog read port、辞書 master mapping | ユーザー status、consumer orchestration、runtime |
| WordStatus | account × `CatalogWordRef` の状態、共通 domain／application contract、方向別 status adapter | Catalog word、MyWordStatus、session、汎用 sync engine |
| MyWord | MyWord identity／CRUD／validation、MyWordStatus、dataset 固有 mapping と同期依存 | Catalog、辞書 WordStatus、汎用 sync engine、横断一覧 |
| `app/bootstrap`・routing・session | 起動時の結線、route／navigation、account／session 解決 | feature の domain truth、dataset の業務意味 |
| `sync` | SyncEngine、queue、checkpoint、retry、scheduling | feature dataset の payload 意味、mapping、競合 rule |
| database infrastructure | connection の生成・破棄、汎用 transaction runtime | table schema の業務上の意味、feature mapper |
| consumer query | Search／WordDetail／Quiz／Ranking 用の read orchestration と projection | 他 owner の write model と invariant |

共通 [`DatabaseProvider`](../../../lib/core/infrastructure/database/drift/database_provider.dart) に table が登録されていても、database infrastructure がその業務意味を所有することにはならない。同様に [`SyncEngine`](../../../lib/features/sync/application/sync_engine.dart) が dataset を実行しても、dataset 固有の payload mapping と競合 rule は各 feature owner が提供する。

## Allowed dependency direction

```text
Search / WordDetail / Quiz / Ranking
                 |
                 v
          Catalog public port
                 ^
                 |
        Catalog internal adapter

CatalogWordRef <--- WordStatus public contract

MyWord <--- MyWordStatus
  ^             |
  +-------------+ lifecycle / sync dependency

app/bootstrap: public contract と adapter の結線のみ
sync: engine を所有し、dataset の業務意味は各 feature が所有
database infrastructure: runtime を所有し、schema の業務意味は各 feature が所有
```

本文として、Search、WordDetail、Quiz、Ranking は Catalog の公開 port にのみ依存し、Catalog は consumer の domain／presentation 型に依存してはならない。WordStatus は Catalog-owned の最小 identity contract `CatalogWordRef` に依存できるが、Catalog は WordStatus に依存しない。MyWordStatus は MyWord identity と lifecycle に依存し、MyWord owner の外へ切り離さない。

`app/bootstrap` だけが公開 contract と具象 adapter を結線する。`app/session` は account scope を解決するが feature invariant を所有しない。sync は engine と実行 runtime を所有し、各 feature は dataset adapter、payload mapping、競合 rule を所有する。database infrastructure は connection／transaction runtime を所有し、各 feature は schema の意味と mapper を所有する。複数 owner を読む consumer query は projection を作れるが、他 owner の table や write model を更新してはならない。

## Compatibility constraints

この ADR の採用だけでは、次を変更しない。

- ユーザーから見える機能、画面、status button の挙動
- route path、query parameter、deep link、Search／WordDetail／Quiz／Ranking の業務結果
- MyWord の validation、CRUD、guest／account scope
- Drift schema version、table 名、column 名、primary key、foreign key
- Firebase collection、document contract、Security Rules
- `SyncDataset` stable ID、outbox payload、field mask、競合 rule、guest migration の transaction と対象 dataset
- 公開済みの型や Repository の即時 rename／move

MyWordStatus の `hasNote` 不一致はこの ADR で機能を追加・削除して解消しない。schema、Firebase、同期 protocol、route の変更が必要な場合は、対応する後続 slice または別 ADR で migration と互換性を判断しなければならない。

## Consequences

Positive:

- source of truth と dependency direction が明確になる。
- schema と同期 protocol を維持したまま段階移行できる。
- Catalog と MyWord の不要な union 分岐を write path に持ち込まずに済む。

Negative:

- 移行中は新旧 adapter と旧 path が併存する。
- 物理配置だけを見ても owner を判断できない期間がある。

Trade-off:

- 複数 source の read projection が増えても、write model の純度と異なる lifecycle の分離を優先する。

## Rejected alternatives

1. 辞書 domain を恒久的に汎用 `core` に置く案は、独立した語彙知識の変更理由と source of truth を隠し、consumer と runtime の共有物に見せるため採用しない。
2. 西日／日西の Catalog を巨大な nullable entity にする案は、variant ごとの構造差と invariant を弱め、無効な状態を増やすため採用しない。
3. Catalog word と MyWord を共通 write entity にする案は、identity、account scope、CRUD、削除、同期 lifecycle が異なり、ほぼすべての write に source 分岐を要求するため採用しない。
4. MyWordStatus を直ちに WordStatus に統合する案は、MyWord への lifecycle／sync coupling と `hasNote` contract の不一致を無視するため採用しない。
5. 方向別 status の table、collection、stable ID も同時に一本化する案は、論理 model の統合に不要な schema／protocol migration risk を生むため採用しない。

## Follow-up

MyWord's Phase 7--8 follow-up is complete: external business consumers use
`features/my_word/port/my_word.dart`; bootstrap and routing use the explicit
composition and presentation-entry technical seams. The import-boundary
checkers enforce that no external consumer reaches `my_word/internal/**`.

[`concept.md` の移行順](../../refactor-v0.2/concept.md#移行順)に従い、この ADR は次の作業へ入力される。

| 移行順序 | Follow-up |
|---|---|
| 2 | Catalog-owned の最小 identity value として `CatalogId`／`CatalogWordRef` を実装する。route、Search、WordDetail、Quiz、Ranking、WordStatus が使う既存 `WordType`／`SearchDirection`／`DictionaryDirection` と変換境界を棚卸しする。route、DB、serialization への反映はそれぞれの後続 scope に従う。 |
| 3 | Catalog 公開 port と既存 Repository への内部 adapter を実装する。 |
| 4 | Quiz→Search の依存を Catalog／Quiz-owned port に置き換える。 |
| 5 | Catalog による能力判定へ移した後、`hasConj` を route contract から除く。 |
| 6 | Word／Dictionary／Conjugation の物理配置を Catalog へ移す。 |
| 7 | 西日・日西 WordStatus の domain／application を論理統合する。 |
| 8 | table、Firebase collection、`SyncDataset` stable ID を保った方向別 adapter を実装する。 |
| 9 | MyWord／JpnEspWord の過渡的 status field を除き、query projection で合成する。 |
| 10 | この ownership と依存方向を import boundary で機械的に検証する。 |
| 11 | 論理境界が成立した後に directory 名を整理する。 |

移行順序2より前に `CatalogWordRef` の実装や directory 移動を先行させない。`CatalogWordRef` は Catalog 内部 entity の公開ではなく、consumer と WordStatus が使う最小 identity contract とする。
