# WordDetail refactor plan

## 1. 目的とスコープ

WordDetail feature を
[Feature設計ルール](../architecture/feature-design-rules.md) と Catalog の基準実装に
合わせ、単一の公開業務 facade、consumer-owned required port、pure composition、用途限定の
technical seam を持つ構造へ移行する。

- feature 外の業務コードは
  `package:my_dic/features/word_detail/port/word_detail.dart` だけを利用する
- Catalog が所有する辞書事実／活用事実と、WordDetail が所有する集約／warning／表示 policy
  を分離する
- Catalog との値・error 変換を `lib/integration/catalog_word_detail/**` に限定する
- primary detail と optional conjugation の failure 単位を維持する
- Catalog DTO、raw HTML、自由文字列の issue source、generic `BusinessRuleError` を
  WordDetail の公開 contract から排除する
- app bootstrap が adapter、application reader、Riverpod lifetime を組み立てる
- app routing は WordDetail の facade と controlled presentation entry だけに依存する

対象は `lib/features/word_detail/**`、新設する
`lib/integration/catalog_word_detail/**`、WordDetail を接続する `lib/app/bootstrap/**` と
`lib/app/routing/**`、関連 test、boundary checker、ADR／公開 surface 文書である。

この計画では次を変更しない。

- Drift schema、辞書 asset、seed、migration、sync protocol
- `CatalogWordRef`、`CatalogId` と各 Catalog の意味
- canonical path `word/:wordId` と `catalog` query parameter
- support 中の legacy `type=espJpn|jpnEsp` parse と、legacy `hasConj` を無視する挙動
- `WordDetailPresentationInput.highlight` が ephemeral で route identity ではないこと
- 西日／日西の辞書表示、活用 tab、Quiz FAB、WordStatus button の表示条件
- primary failure、empty、conjugation warning、dispose 後 late completion の画面挙動
- WordStatus の状態／mutation と Quiz の route／game semantics の ownership
- user-facing 文言、tab 順、活用の subject／tense 順、HTML 表示の視覚的意味

retry 追加、route 廃止、画面デザイン変更、Catalog schema／wire format変更は別変更とする。

## 2. 現状の問題と基線

現行は `port`／`internal` の二層へ移動済みで、route、partial success、async race の主要挙動も
test 化されている。一方、feature 境界は未完成である。

- `port/word_detail.dart` がなく、app と test が個別 `port/**` を deep import する
- `port/composition.dart` と `port/presentation_dependencies.dart` がなく、app bootstrap が
  WordDetail application capability を組み立てていない
- internal presentation provider が Catalog の Riverpod dependency provider を直接読み、
  `LoadWordDetailQuery` を生成している
- application service が Catalog の legacy `CatalogReaderPort`／`ConjugationReaderPort` と
  Catalog DTOへ直接依存し、WordDetail-owned required port がない
- `WordDetailViewData` が `EspJpnEntry`、`JpnEspEntry`、`CatalogConjugation` をそのまま公開し、
  consumer contract と provider contract が結合している
- Catalog entry の `content`／`espanolHtml` が raw HTML で、WordDetail presentation が
  `flutter_html` へ直接渡している
- `WordDetailQueryResult` が core の `QueryIssue` と自由文字列 `source` を公開する
- identity／variant mismatch を generic `BusinessRuleError` へ変換し、WordDetail の typed
  failure contract がない
- `presentation_entry.dart` は internal widget を直接 re-exportし、controlled entry 自身を
  宣言していない
- legacy route の `espJpn`／`jpnEsp` 解釈を app callback に委ね、route serialization の
  ownership が app に漏れている
- `jpn_esp_state.dart` のように責務と一致しない名称、旧 `internal/di/**` を参照する test、
  重複した旧 test directory が残る
- `WordDetailFragmentBuilderInput` 等の内部 renderer input が mutable／public class のままで、
  screen class に取得、capability 判定、layout 組み立てが集中している

2026-08-11 の実測基線は次のとおり。

- import boundary checker／feature dependency checker に WordDetail 起因の報告はない
  - ただし sole facade、WordDetail technical seam、Catalog required port をまだ検査していないため、
    現状準拠の証明にはならない
  - repository 全体には他 feature の既存違反が残る
- WordDetail focused test は 12 test が pass、5 load/failure
  - 旧 `core/application/query/query_issue.dart`
  - 旧 `features/word_detail/internal/di/view_model_di.dart`
  - 旧 `features/word_status/presentation/status_button.dart`
  - 作業中の MyWord contract 変更から波及した compile error
- application aggregation の7 test、dispose fence、conjugation label、Gate B presentation／router
  test は成功している

Phase 0 では WordDetail の stale test を現行 production path へ合わせる。他 feature の作業中変更は
同じ差分で修正せず、外部 blocker として分離する。

## 3. Ownership matrix

| Owner | Owns | Does not own |
|---|---|---|
| Catalog | `CatalogWordRef`／`CatalogId`、辞書 aggregate、語義、見出し、例文、活用、活用なし、content の source 解釈、Catalog read error | WordDetail の warning、tab／FAB／status 表示、highlight、route |
| WordDetail | detail query、Catalog required port、方向別 detail projection、conjugation failure の warning 化、empty 判定、route serialization、ephemeral highlight、画面 capability policy | Catalog persistence／HTML source／活用正本、WordStatus mutation、Quiz game |
| `lib/integration/catalog_word_detail` | Catalog facade から WordDetail required port への値・typed error 変換、identity 保持 | HTML parse、warning 化、empty／tab／FAB policy、Riverpod lifetime |
| `app/bootstrap` | Catalog adapter と WordDetail composition の instance／lifetime／override | detail aggregation、warning／表示 semantics |
| `app/routing` | GoRouter 登録、parse 結果から presentation entry への接続、Quiz navigation callback | WordDetail route serialization、Catalog／WordDetail DTO変換 |
| WordStatus | 辞書 status 状態、mutation、public status entry | WordDetail の load state と表示 capability |
| Quiz | game route、game data、game presentation | WordDetail が Quiz を開く条件 |

依存方向は次とする。

```text
Catalog facade
      ^
      | semantic value / typed error conversion
lib/integration/catalog_word_detail
      |
      v
WordDetailCatalogGateway
      |
      v
WordDetailReaderPort implementation ----> WordDetail presentation
              ^                                  ^
              +-------- feature factory --------+
                              ^
                         app/bootstrap

WordDetail presentation -- pure callback --> app/routing --> Quiz route
WordDetail presentation -- public entry ----> WordStatus
```

## 4. 変えてはいけない挙動

リファクタ前に次を characterization test で固定する。

- primary detail failure は画面全体 failure になる
- Catalog が要求と異なる identity／direction variant を返した場合は成功にしない
- 西日 detail のみ optional conjugation を読む
- conjugation なしは成功で、warning、活用 tab、Quiz FABを表示しない
- conjugation failure は primary detail を維持し、typed issue から presentation warning へ変換する
- 日西 detail は conjugation readerを呼ばず、辞書だけを表示する
- valid non-empty detail のみ WordStatus entry を mountする
- loading、failure、empty では WordStatus providerを mountしない
- conjugation があっても entry が空なら Quiz callbackを発火できない
- 同じ load key の initialize は1回だけ実行する
- dispose／generation変更後の late completion は state を更新しない
- multi-tabへ切り替わる際に `TabController` を安全に再生成する
- highlight は活用表示だけに使い、取得成否、provider key、URLへ混ぜない
- navigation callback は `CatalogWordRef` と optional display hintだけを appへ渡す
- canonical URL の refresh round-trip、legacy `type`、invalid ID／catalog／conflict を維持する
- legacy `hasConj` の値は能力判定に使用しない

## 5. 目標構造

```text
lib/features/word_detail/
├─ port/
│  ├─ word_detail.dart
│  ├─ reader/
│  │  └─ word_detail_reader_port.dart
│  ├─ gateway/
│  │  └─ word_detail_catalog_gateway.dart
│  ├─ query/
│  │  └─ word_detail_query.dart
│  ├─ result/
│  │  └─ word_detail_result.dart
│  ├─ model/
│  │  ├─ word_detail_data.dart
│  │  ├─ word_detail_entry.dart
│  │  ├─ word_detail_content_block.dart
│  │  ├─ word_detail_conjugation.dart
│  │  └─ word_detail_issue.dart
│  ├─ error/
│  │  └─ word_detail_read_error.dart
│  ├─ route.dart
│  ├─ presentation_input.dart
│  ├─ composition.dart
│  ├─ composition_contract.dart
│  ├─ presentation_dependencies.dart
│  └─ presentation_entry.dart
└─ internal/
   ├─ application/
   │  └─ word_detail_reader.dart
   ├─ presentation/
   │  ├─ components/
   │  ├─ provider/
   │  ├─ ui_model/
   │  ├─ view_model/
   │  └─ view/
   └─ composition/
      └─ word_detail_composition_factory.dart

lib/integration/catalog_word_detail/
├─ catalog_backed_word_detail_gateway.dart
└─ catalog_word_detail_providers.dart

lib/app/bootstrap/
└─ word_detail_composition.dart
```

`domain` と `infrastructure` は必要な責務がない限り作らない。WordDetail は Catalog の
persistence adapterを所有しない。

## 6. 目標 public contract

### 6.1 Sole business facade

feature 外の業務 import は次だけとする。

```dart
import 'package:my_dic/features/word_detail/port/word_detail.dart';
```

`word_detail.dart` は次を明示 exportする。

- shared identity として許可された `CatalogWordRef`／`CatalogId`
- `WordDetailQuery`、`WordDetailResult`
- sealed `WordDetailData` と方向別 variant
- WordDetail-owned entry／semantic content block／conjugation model
- typed `WordDetailIssue` と `WordDetailReadError`
- provided `WordDetailReaderPort`
- required `WordDetailCatalogGateway`
- pure `WordDetailRoute` と `WordDetailPresentationInput`

`composition.dart`、`presentation_dependencies.dart`、`presentation_entry.dart` は business facade
から exportしない。

### 6.2 Required Catalog gateway

`WordDetailCatalogGateway` は consumer 語彙で2つの failure 単位を提供する。

```dart
abstract interface class WordDetailCatalogGateway {
  Future<Result<WordDetailDictionary>> readDictionary(CatalogWordRef word);
  Future<Result<WordDetailConjugation?>> readConjugation(
    CatalogWordRef word,
  );
}
```

- query/result/error は WordDetail 所有型とする
- `CatalogWordRef` だけを owner-shared identity として共有する
- Catalog DTO、Catalog error、HTML、wire-keyed mapを返さない
- dictionary 不在は typed not-found failure とする
- conjugation なしは `Result.success(null)` とする
- DB／unexpected exception は adapter で WordDetail-owned errorへ変換する

2 operation は一つの aggregate call にまとめない。application service が primary failure と
optional enrichment failure を別々に扱える状態を維持する。

### 6.3 Provided readerとresult

`WordDetailReaderPort` は読み取り専用 application Query Service とする。

```dart
abstract interface class WordDetailReaderPort {
  Future<Result<WordDetailResult>> read(WordDetailQuery query);
}
```

- query は positive な `CatalogWordRef` を保持する
- result は sealed direction data と0件以上の typed issueを持つ
- primary failure は `Result.failure(WordDetailReadError)`
- conjugation failure は成功 result の `WordDetailConjugationIssue`
- empty collection と aggregate not found を区別する
- identity／direction mismatch は `WordDetailContractMismatchError`
- collection は immutable、公開 model は Flutter／Riverpod／Catalog DTO 非依存とする

`ILoadWordDetailQuery`、`WordDetailQueryResult`、`WordDetailViewData` は移行中だけ残し、全参照0後に
削除する。最終形に typedef／re-export shim は残さない。

### 6.4 HTML／semantic content の prerequisite

現行 Catalog detail model の `content` と `espanolHtml` は Feature設計ルールの
「公開DTOへHTML断片を漏らさない」に適合しない。integration adapter が HTML を parseすると
Catalog owner の責務を奪うため、次を prerequisite とする。

- Catalog internal mapper が source HTML を semantic content block へ変換する
- Catalog facade は raw HTML ではなく owner-owned structured contentを提供する
- Catalog-to-WordDetail adapter は semantic block同士の値変換だけを行う
- WordDetail presentation は `flutter_html` への raw string投入をやめ、WordDetail blockを描画する
- representative real asset の golden／widget smokeで見出し、本文、強調、改行等の視覚的意味を固定する

Catalog側の structured contractをこの差分で追加できない場合、raw HTMLを新WordDetail contractへ
コピーして進めない。Catalog planの prerequisiteとして分離し、WordDetailのPhase 2以降を止める。

### 6.5 Technical seams、presentation、routing

- `port/composition.dart`
  - pure `createWordDetailComposition(WordDetailCatalogGateway)` のみ公開する
  - internal factoryへの委譲とpublic composition contract以外を持たない
- `port/presentation_dependencies.dart`
  - Riverpodによる `WordDetailReaderPort` 注入口だけを定義する
  - Catalog providerやapplication serviceを生成しない
- `port/presentation_entry.dart`
  - `WordDetailEntry` の controlled Flutter signatureを宣言する
  - inputと `onOpenQuiz(CatalogWordRef, String?)` callbackを明示する
  - internal widget、provider、view modelを exportしない
- `WordDetailRoute`
  - canonical／legacy serializationを自身で所有する
  - `parseLegacyType` callbackを廃止し、appから legacy mappingを除去する
  - highlight と `hasConj` を identity／能力判定に含めない

WordStatus public entryの利用はpresentation technical dependencyとして維持できる。ただし
WordDetailからWordStatus internal/providerをimportせず、status mount条件はWordDetailが所有する。

## 7. 実装フェーズ

### Phase 0: test基線とcharacterization

- staleな `QueryIssue`、WordDetail DI、WordStatus test importを現行pathへ更新する
- 重複した旧 test directoryを統合し、same-feature white-box testだけが internalをimportする
- MyWord作業中変更からのcompile failureをWordDetail変更と分離して記録する
- §4のapplication、view model、widget、route挙動をproduction変更前に固定する
- facade導入前の外部 import一覧とlegacy type／class参照一覧を保存する
- focused suiteをgreenにしてからcontract変更へ進む。外部blockerが残る場合は該当testを明示する

### Phase 1: facadeとWordDetail-owned contract

- `port/word_detail.dart` とfacade contract testを追加する
- required gateway、provided reader、query、result、typed issue／errorを追加する
- direction別 data、entry、conjugation、semantic content blockをWordDetail型として追加する
- query validation、identity保持、collection immutability、absence／failure semanticsをtestする
- legacy contractはcaller切替まで併存させるが、新facadeから最終APIとして公開しない

### Phase 2: Catalog semantic prerequisiteとpure integration adapter

- Catalog owner側で raw HTMLを semantic structured contentへ変換する契約を確定する
- `CatalogBackedWordDetailGateway` をpure adapterとして追加する
- adapter本体は Catalog／WordDetail facade と shared `Result` だけをimportする
- direction、entry hierarchy、conjugation enum/value、identity、typed errorを変換する
- adapterはwarning、empty、tab、FAB、highlight policyを持たない
- Catalog legacy reader／presentation dependencyをWordDetail internalから除去できる状態にする

### Phase 3: application reader切替

- `LoadWordDetailQuery` を `WordDetailReaderPort` 実装へ移行する
- primary dictionaryを先に読み、西日のみ optional conjugationを読む順序を維持する
- conjugation errorを typed issueへ変換し、primary dataを保持する
- identity／direction mismatchをtyped contract errorへ正規化する
- generic `QueryIssue`、自由文字列 source、`BusinessRuleError`、Catalog model依存を削除する
- 旧 `ILoadWordDetailQuery` と旧view data参照はconsumer切替まで残す

### Phase 4: compositionとbootstrap

- `internal/composition/word_detail_composition_factory.dart` がreaderを生成する
- `port/composition.dart` はpure factory facadeとしてinternal factoryへ委譲する
- `catalog_word_detail_providers.dart` はCatalog-backed gatewayのwiringだけを行う
- `lib/app/bootstrap/word_detail_composition.dart` がgatewayからcompositionを生成する
- root `ProviderScope` で `WordDetailReaderPort` dependencyをoverrideする
- WordDetail internal providerから Catalog presentation dependencyと`LoadWordDetailQuery`生成を削除する
- composition testで同一app scopeのreaderがpresentationへ注入されることを確認する

### Phase 5: presentation境界とrenderer整理

- view modelは `WordDetailReaderPort` とWordDetail-owned modelだけを使用する
- typed issueをpresentationのwarningへ変換し、既存のprimary／warning表示を維持する
- `jpn_esp_state.dart` を責務に合う `word_detail_state.dart` へrenameする
- screenからstate-to-capability判定とlayout input生成を小さなinternal mapper／rendererへ分離する
- internal renderer inputをimmutable/privateにし、未使用 `wordId` 等を削除する
- raw HTML rendererをsemantic content block rendererへ置換する
- tab lifecycle、status mount、Quiz FAB enable条件、highlightをwidget testで固定する
- `WordDetailEntry` をpublic controlled entryとし、`WordDetailFragment`の直接exportを廃止する

### Phase 6: routeとcaller切替

- legacy type mappingを `WordDetailRoute` に移し、appの `_catalogIdFromLegacyType` を削除する
- app routingは `word_detail.dart` と `presentation_entry.dart` だけをimportする
- navigation callbackはWordDetail facadeのroute contractを使う
- integration／app／cross-feature testのbusiness importを各feature facadeへ切り替える
- source featureからWordDetail route importがないこと、WordDetailからQuiz route importがないことを確認する

### Phase 7: legacy削除

- production／test／generated参照0を `rg` で確認する
- `ILoadWordDetailQuery`、旧 query barrel、`WordDetailQueryResult`、`WordDetailViewData`を削除する
- Catalog legacy `CatalogReaderPort`／`ConjugationReaderPort` のWordDetail用途参照を削除する
- 旧 DI path、重複 test、direct internal widget export、compatibility aliasを削除する
- 空directoryと責務不一致の旧file名を整理する
- 最終状態にshim、typedef alias、重複modelを残さない

### Phase 8: checker、ADR、public surface

- WordDetail向けsole facade ruleをimport boundary／feature dependency checkerへ追加する
  - feature外のbusiness importは`port/word_detail.dart`のみ
  - technical exceptionはcomposition、presentation dependencies、presentation entryのみ
  - WordDetail外からinternal import禁止
  - integrationからfeature internal、Flutter、Riverpod、Catalog deep port import禁止
  - business facade export closureのframework／internal／raw HTML依存禁止
- `presentation_dependencies.dart` のRiverpod許可を全feature共通technical seamとして一般化する
- positive／negative fixture testを追加し、baselineへ新規違反を加えない
- WordDetail ownership／partial failure／route ownership ADRを追加する
- `word-detail-public-surface.md`、`import-boundaries.md`、`remaining-work.md`を実装と一致させる
- WordDetail外の既存checker違反は同時修正せずowner／削除条件付きで記録する

## 8. Test strategy

### Public contract test

- 単一 `word_detail.dart` importから全business contractを利用できる
- facade export closureにFlutter、Riverpod、GoRouter、Catalog DTO、raw HTML、internalがない
- query validation、value equality、immutable collection、typed issue／error
- dictionary not found、empty collection、optional conjugation、partial failureの区別
- route canonical round-trip、legacy type、invalid／conflict、`hasConj`無視、highlight非identity

### Application test

- 西日／日西の分岐とidentity保持
- primary failure、identity mismatch、direction mismatch
- conjugation success／absence／failureと、日西でgatewayを呼ばないこと
- warningがprimary dataを失わせないこと
- unexpected gateway exceptionのWordDetail error正規化

### Integration adapter test

- Catalog semantic DTOからWordDetail DTOへの全variant変換
- Catalog errorからWordDetail typed errorへの変換
- `CatalogWordRef` とoptional conjugation absenceの保持
- adapterにwarning／presentation policyがないこと
- framework／ProviderContainerなしで動くこと

### Presentation／routing／acceptance test

- initial、loading、data、empty、failure、warning、stale dataのrenderer matrix
- status entryのmount有無、活用tab、Quiz FAB、callback payload、highlight
- same-key coalescing、dispose後late completion、tab count変更
- real asset由来semantic contentの代表表示 smoke／golden
- invalid URLはWordDetail dependencyを読まずInvalidRoutePageで停止する
- public presentation entryからCatalog adapterまでを通すGate B acceptance
- app bootstrapがWordDetail readerを同一scopeへ注入するcomposition test

## 9. 検証順序

各phaseをbuild可能な縦スライスにし、次の順で実行する。

1. 変更対象のfocused contract／unit／widget test
2. `flutter test test/unit/features/word_detail test/widget/features/word_detail`
3. `flutter test test/unit/integration/catalog_word_detail`
4. WordDetail Gate B acceptance、route、app composition test
5. Catalog semantic contractのfocused test／real asset smoke
6. `dart analyze`
7. import boundary checkerとfeature dependency checker
8. full `flutter test`

repository全体の既存赤が残る場合は、WordDetail起因かをrule ID／source pathで分離して記録する。
baselineへ新しいWordDetail違反を追加して通さない。

## 10. 完了条件

- `word_detail.dart` がsole business facadeで、外部deep importが0件
- WordDetail外から`features/word_detail/internal/**` importが0件
- business contractのFlutter／Riverpod／GoRouter／Catalog DTO／raw HTML露出が0件
- `WordDetailCatalogGateway` をWordDetailが所有し、pure adapterが
  `lib/integration/catalog_word_detail` にある
- adapterにHTML parse、warning、empty、tab、FAB、highlight policyがない
- WordDetail application／presentationからCatalog legacy reader、Catalog DTO、Catalog
  presentation dependency importが0件
- generic `QueryIssue`、自由文字列 issue source、generic mismatch errorが残っていない
- app bootstrapがWordDetail compositionとlifetimeを所有する
- presentation entryがinternal provider／view model／widgetをexportしない
- routeがlegacy mappingを所有し、app callbackへのserialization依存がない
- 旧query／view data／DI path／compatibility shim／重複testが削除済み
- canonical／legacy route、partial warning、status／Quiz capability、画面表示に意図しない差分がない
- WordDetail起因の両boundary checker違反が0件
- WordDetail unit/widget/integration/acceptance、`dart analyze`、full testがgreen
- ADRとpublic surface manifestが実装と一致する

## 11. 実装時の停止条件

次が必要になった場合は、構造リファクタへ黙って含めず方針を再確認する。

- Catalog ownerがsemantic content contractを提供せず、raw HTMLを新contractへ流す必要がある
- structured content化で現在の辞書表示の情報または視覚的意味が失われる
- `CatalogWordRef`、Catalog direction、辞書／活用 ownershipの変更
- canonical path、query parameter、legacy `type` support期間、`hasConj`挙動の変更
- highlightをURL／identity／load成功条件へ加える変更
- conjugation failureを画面全体failureにする変更
- not found／empty／failureのuser-visible区別または文言変更
- status mount条件、Quiz FAB条件、callback payloadの変更
- WordStatus／Quiz internalをWordDetailから直接importする必要が生じる
- schema、asset、seed、migration、sync protocolの変更
- WordDetail以外のfeature debtを同じ差分で解消する必要が生じた場合
