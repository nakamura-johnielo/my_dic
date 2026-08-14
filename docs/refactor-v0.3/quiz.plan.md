# Quiz refactor plan

## 1. 目的とスコープ

Quiz feature を [Feature設計ルール](../architecture/feature-design-rules.md) と
Catalog の基準実装に合わせて、単一の公開業務 facade、consumer-owned required port、
owner-internal infrastructure、用途限定の technical seam を持つ構造へ移行する。

- feature 外の業務コードは
  `package:my_dic/features/quiz/port/quiz.dart` だけを利用する
- Catalog の辞書事実と Quiz の候補選定・warning・ゲーム進行 policy を分離する
- 候補検索とゲーム読込を、独立した failure 単位を持つ focused port として扱う
- Catalog との contract 変換は `lib/integration/catalog_quiz/**` に限定する
- English conjugation table、bundled prompt assets、wire key の解釈を Quiz internal に閉じる
- Riverpod、Flutter、Drift row、DAO、raw `Map<String, ...>`、raw exception を
  business contract に出さない
- app router と bootstrap は Quiz の public facade／technical seam だけに依存する

対象は `lib/features/quiz/**`、`lib/integration/catalog_quiz/**`、Quiz を接続する
`lib/app/bootstrap/**` と `lib/app/routing/**`、関連 test、boundary checker、ADR／公開
surface 文書である。

この計画では次を変更しない。

- Drift schema version、`es_en_conjugacions` の table／column／seed／migration
- Catalog の identity、辞書詳細、スペイン語活用、frequency、ranking の semantics
- canonical／legacy Quiz route と URL serialization
- 検索画面の page size、重複除去、same-page retry、stale response discard
- enrichment failure を warning にして基本候補を表示する policy
- primary word not found／活用なしを no-data 表示する画面挙動
- 英語活用 row がない場合の `V-ing`、`V-en`、`V`、`Vs`、`V-ed` fallback
- 分詞は `yo` のみ、命令形は `yo` 以外という出題集合と、本番でのランダム順
- WordStatus button の所有権と画面遷移先

検索仕様、出題方式、採点・履歴、学習進捗、schema／asset format の変更は別変更とする。

## 2. 現状の問題と基線

候補検索はすでに `QuizCatalogGateway` と Catalog-backed adapter へ移行しているが、
feature 全体の境界は未完成である。

- `port/quiz.dart` がなく、app、integration、test が個別 `port/**` を deep import する
- `port/composition.dart` が `internal/candidate_search/**` を直接 import し、pure factory
  facade になっていない
- `presentation_dependencies.dart` の Riverpod 利用が、一般 technical seam として
  checker に実装されていない
- integration provider が gateway の wiring だけでなく Quiz candidate policy の生成まで行う
- ゲーム読込は Catalog の legacy `CatalogReaderPort`／`ConjugationReaderPort` を Quiz
  internal が直接利用し、consumer-owned game required port がない
- `LoadQuizGameCompatibilityAdapter` は application から infrastructure asset を直接参照する
- `QuizGameLoadResult.failure` が `Object` を公開し、infrastructure error を正規化しない
- `QuizGameData` が `CatalogConjugation` と wire-keyed `Map<String, ...>` を公開する
- Catalog から Quiz-owned conjugation への変換が presentation で行われる
- candidate query は `assert` だけで検証し、空文字を contract で拒否しない
- candidate issue source と gateway operation が自由文字列である
- `internal/game/data/**`、repository、use case、`QuizGameAssets` に重複経路がある
- presentation が `internal/composition/**` を直接 import し、view model に debug log と
  wire-key 解釈が残る
- 未参照の `lib/features/quiz/quiz_search_card.dart` が feature 直下に残る

2026-08-11 の実測では次の既存赤がある。Phase 0 で production behavior の変更より先に
解消し、以降のリファクタ起因の失敗と混同しない。

- `flutter test test/unit/features/quiz`: 25 pass、6 load/failure
  - test が存在しない旧 path（`domain/repository/**`、`application/conjugation/**`、
    `quiz_dao_providers.dart` など）を参照する
  - port 全 directory を走査する test が、許可された
    `presentation_dependencies.dart` の Riverpod まで business port 違反として扱う
- import boundary checker
  - Quiz: `composition_exact_facade` 1件
  - Quiz: `business_port_no_framework` 1件。ただし対象は許可すべき
    `presentation_dependencies.dart` であり、checker の technical seam 未一般化が原因
  - repository 全体には Quiz 外の既存違反もあるため、Quiz 完了判定と分離する
- feature dependency checker
  - Quiz: application から infrastructure asset への `internal_clean_architecture` 1件

## 3. Ownership matrix

| Owner | Owns | Does not own |
|---|---|---|
| Catalog | `CatalogWordRef`、辞書 entry、スペイン語活用、見出し語、frequency、ranking、Catalog read error | Quiz の検索語解釈、warning、候補projection、ゲーム進行 |
| Quiz | candidate query、paging要求、候補選定・重複・warning、English prompt／fallback、出題可能組合せ、question order、flip／next／back、画面policy | Catalog persistence、Catalog DTOの正本、WordStatus、router graph |
| `lib/integration/catalog_quiz` | Catalog facade と Quiz required port 間の値・error変換、`CatalogWordRef`保持 | trim、paging表示、warning化、fallback、候補選定、asset／DAO操作 |
| `app/bootstrap` | database runtime、Catalog/Quiz composition の lifetime、Riverpod override | Quiz の業務semantics、DTO変換 |
| `app/routing` | route登録、parse結果からpresentation entryへの接続、navigation callback | Quiz identity／route serialization、Quiz widget内部状態 |
| WordStatus | dictionary status の状態と共通presentation entry | Quiz game/session state |

依存方向は次とする。

```text
Catalog facade
      ^
      |  value/error conversion
lib/integration/catalog_quiz
      |
      v
Quiz required ports --> Quiz internal application policy
                              |
                    +---------+---------+
                    v                   v
          Quiz infrastructure      Quiz presentation
                    ^                   ^
                    +------ factory ----+
                              ^
                         app/bootstrap
```

## 4. 目標構造

```text
lib/features/quiz/
├─ port/
│  ├─ quiz.dart
│  ├─ reader/
│  │  ├─ quiz_candidate_reader_port.dart
│  │  └─ quiz_game_reader_port.dart
│  ├─ gateway/
│  │  ├─ quiz_candidate_catalog_gateway.dart
│  │  └─ quiz_game_catalog_gateway.dart
│  ├─ query/
│  ├─ result/
│  ├─ model/
│  ├─ error/
│  ├─ route.dart
│  ├─ composition.dart
│  ├─ presentation_dependencies.dart
│  └─ presentation_entry.dart
└─ internal/
   ├─ application/
   │  ├─ candidate_search/
   │  └─ game/
   ├─ domain/
   │  └─ game/
   ├─ infrastructure/
   │  ├─ assets/
   │  └─ drift/
   ├─ presentation/
   │  ├─ search/
   │  └─ game/
   └─ factory/
      └─ quiz_composition_factory.dart

lib/integration/catalog_quiz/
├─ catalog_backed_quiz_candidate_gateway.dart
├─ catalog_backed_quiz_game_gateway.dart
└─ catalog_quiz_providers.dart
```

最初から全 path rename を行わず、契約追加、consumer切替、旧参照0の確認、機械的移動の
順に進める。Drift generated part の移動が必要な場合は、そのphaseだけで再生成する。

## 5. 目標 public contract

### 5.1 Sole business facade

feature 外の業務 import は次だけとする。

```dart
import 'package:my_dic/features/quiz/port/quiz.dart';
```

`quiz.dart` は pure Dart の次のcontract groupだけを明示exportする。

- shared identityとして許可された `CatalogWordRef`
- candidate/game query、result、model、typed error
- `QuizCandidateReaderPort`、`QuizGameReaderPort`
- Quiz-owned Catalog required portsと、そのquery/result/error
- pure route contract と presentation input

`composition.dart`、`presentation_dependencies.dart`、`presentation_entry.dart` は
technical seam とし、`quiz.dart` からexportしない。

### 5.2 Candidate query／result

- `QuizCandidateQuery` は生成時に trim し、空文字、`page < 0`、`size <= 0` を
  `ArgumentError` で同期的に拒否する。`assert` をvalidationとして使わない
- `QuizCandidatePage.hasNext` はCatalogのlook-ahead事実を保持し、UIが件数から推測しない
- `QuizCandidateIssue.source` は `meaning`、`headword`、`ranking` のenumにする
- primary search failure は `Result.failure`、enrichment failure は typed issue を伴う
  success、0件はempty successとする
- `QuizCandidate` は `CatalogWordRef` と Quiz表示に必要なclean valueだけを持つ

`QuizCandidateSource` は移行中だけ残し、最終的に read-only Query Service として
`QuizCandidateReaderPort` へ改名する。

### 5.3 Game query／result

`LoadQuizGame` は `QuizGameReaderPort` へ置換し、非同期境界は
`Future<Result<QuizGameLoadOutcome>>` とする。

- success variant: ready、primary not found、no conjugation
- failure: `QuizGameLoadError`。source は enum、原因は正規化済み `AppError`
- raw `Object`、Drift error、asset exception を公開しない
- UI上は not found と no conjugation を従来どおり同じno-data表示にできる

ready result は Catalog model や wire map ではなく Quiz-owned typed model を返す。

- `QuizConjugation`、`QuizMoodTense`、`QuizSubject`
- `QuizEnglishConjugation` と typed form access
- `QuizEnglishPromptGuide` と typed template access
- `QuizBeConjugation` と typed subject/tense access

JSON／DB の `MoodTense.*`、`EnglishMoodTense.*`、`EnglishSubject.*` は internal mapper が
一度だけ解釈する。presentation はtyped accessorだけを使う。

### 5.4 Required Catalog ports

interface segregation のため、候補検索とゲーム読込を分離する。

- `QuizCandidateCatalogGateway`
  - conjugation candidate search
  - meanings、headword/frequency、ranking の独立batch enrichment
- `QuizGameCatalogGateway`
  - primary word existence/detail確認
  - optional conjugation read

両gatewayは `Result<T>`、Quiz-owned DTO、`QuizCatalogGatewayError` を返す。
Catalog DTOからQuiz DTOへの変換とCatalog errorの正規化はintegration adapterが担当する。
trim、warning化、fallback、表示方針はadapterへ置かない。

## 6. 実装フェーズ

### Phase 0: test基線とcharacterization

- 存在しない旧internal pathを参照するtest importを現行pathへ合わせる
- business port purity testをfacadeのexport closureに限定し、technical seamを別検査にする
- 既存25 passを維持したうえでQuiz unit suiteをgreenに戻す
- 候補検索のtrim、paging、部分enrichment、missing map key、重複除去、retry、stale responseを固定する
- ゲーム読込のprimary not found、no conjugation、source別failure、asset failure、DB failureを固定する
- English row missing時の5 fallback、be／`be ...`／3rd person変換を固定する
- 分詞・命令形の除外、next/back/flip、dispose後のlate completion、double-tap retryを固定する
- route canonical／legacy parseとdisplay hint非identityを既存route contract testで固定する

### Phase 1: pure facadeと新contract

- `port/quiz.dart` とpublic surface contract testを追加する
- candidate/gameのfocused reader、query、result、typed errorを追加する
- candidate/game用Catalog required portを分割して追加する
- string issue/sourceとraw errorをtyped contractへ置換する
- Quiz-owned typed conjugation／English prompt modelを追加する
- 旧portはconsumer切替までcompatibilityとして残すが、facadeからlegacy aliasを最終形として公開しない

### Phase 2: Catalog integrationを分割

- 現行adapterをcandidate用とgame用のpure adapterへ分割する
- adapter本体はCatalog/Quizの各facadeとshared `Result`以外をimportしない
- candidate DTO、game DTO、Catalog error、`hasMore`、identity保持をcontract testで固定する
- `catalog_quiz_providers.dart` はgateway instanceのwiringだけを行い、Quiz candidate policyを生成しない
- Quiz internalからCatalog legacy reader／Catalog presentation dependency importを削除する

### Phase 3: candidate application policy切替

- candidate reader実装を規則準拠の`QuizCandidateQueryService`へ移行する
- trim済みquery、primary failure、3 enrichmentの並行取得、issue化、fallback headwordを維持する
- issue sourceとerrorをtyped化し、presentationの`QueryWarning`へ変換する責務はQuiz presentationに残す
- app/integration/testのcandidate business importを`quiz.dart`へ切り替える
- 旧`candidate_source.dart`、`candidate_query.dart`、aliasは参照0後に削除する

### Phase 4: game application service切替

- compatibility adapterを新`QuizGameReaderPort`実装へ置換する
- Catalog確認、optional conjugation、English DB read、2 asset readを明示した順序で合成する
- Catalog modelから`QuizConjugation`への変換をpresentationからapplication mapperへ移す
- raw mapをtyped English modelへ変換してからresultを返す
- primary not found／no conjugation／source別failureを`Result`とtyped outcome/errorへ正規化する
- application serviceにはgateway、owner repository/reader、asset readerをconstructor injectionし、
  infrastructure実装を直接importさせない

### Phase 5: infrastructureの統合

- `EsEnConjugacionDao` とtable row mappingを
  `internal/infrastructure/drift/**` に集約する
- missing rowのplaceholder生成をQuiz-owned mapper/readerの明示仕様にする
- bundled JSON 2種は単一のasset readerで読み、shape/key不正をtyped data-corruption errorにする
- `QuizJsonDao`、local data source、二重repository、薄い`FetchEnglishConj*` use caseを、
  production/test/generated参照0を確認して削除する
- DB／asset exceptionをQuiz-owned errorへ変換し、production debug logを削除する
- schema、generated table、asset path／wire keyは変更しないsnapshot/contract testを置く

### Phase 6: compositionとbootstrap

- `internal/factory/quiz_composition_factory.dart` がcandidate/game readerとowner infrastructureを組み立てる
- `port/composition.dart` はpure dependency reader、public gateway入力、`QuizPorts` bundleだけを公開する
- public signatureからRiverpod、Provider、DatabaseProvider、DAOを排除する
- `lib/app/bootstrap/quiz_composition.dart` でdatabase runtimeと2 Catalog gatewayを注入する
- integration providerから`createQuizCandidateSource`を削除し、app bootstrapがQuiz compositionのlifetimeを所有する
- `presentation_dependencies.dart` は`QuizPorts`（またはfocused reader）注入だけに限定する

### Phase 7: presentation境界

- search/game viewとproviderから`internal/composition/**` importを削除する
- game presentationはCatalog DTO／wire mapを解釈せず、typed Quiz modelだけを使用する
- retry lane、loading/no-data/failure表示、navigation callback、WordStatus public entry依存を維持する
- `presentation_entry.dart` をsole controlled Flutter entryとし、internal provider/view modelをexportしない
- app routingは`quiz.dart`のroute/inputと`presentation_entry.dart`だけをimportする
- 未参照のroot `quiz_search_card.dart` は参照0確認後に削除する
- Randomをtest注入可能にしても本番defaultは従来どおり非決定的に保つ

### Phase 8: legacy削除、checker、文書

- `rg`でproduction/test/generated参照0を確認してcompatibility adapter、旧port、旧DI、旧repository/use caseを削除する
- Quiz向けsole facade ruleを両checkerへ追加する
  - feature外のbusiness importは`port/quiz.dart`のみ
  - technical exceptionはcomposition、presentation dependencies、presentation entryのみ
  - Quiz external internal import禁止
  - integrationからQuiz internal／DAO／Drift／Flutter import禁止
  - business facade export closureのframework/internal依存禁止
- general checkerを修正し、全featureの`presentation_dependencies.dart`にRiverpodを許可する一方、
  business facadeからの到達は禁止する
- positive/negative fixture test、Quiz ADR、`quiz-public-surface.md`、import-boundaries、remaining-workを更新する
- Quiz外の既存checker違反は同時修正せずremaining workへ記録する

## 7. Test strategy

### Public contract test

- 単一`quiz.dart` importから全business contractを利用できる
- facade export closureにFlutter、Riverpod、Drift、internal、Catalog internalがない
- query validation、value equality、collection immutability、typed absence/failure
- route identityとserialization、display hint非identity

### Candidate application test

- trim済みquery、page/size、empty、exact-size最終page、hasNext保持
- primary failure、各enrichment failure、複数issue、batch partial missing
- fallback headword、frequency/ranking/meaning projection
- page overlapのidentity重複除去、same-page retry、stale/disposed response

### Game application/domain test

- primary not found、no conjugation、各source failure、unexpected exception正規化
- Catalog全tense/subjectからQuiz modelへのmapping
- English row存在／欠落fallback、be、`be ...`、3rd person、prompt展開
- 出題可能集合、random selection、next/back/flip、完了境界

### Infrastructure test

- in-memory DriftでID bind、row mapping、missing row、DB error正規化
- 実asset smokeとmalformed/missing asset error
- schema/table/columnとasset path/wire keyの非変更

### Integration／presentation／acceptance test

- Catalog DTO/errorから2 Quiz gatewayへのpure変換、identity/hasMore保持
- search warningとretry、game loading/no-data/failure/retry、late completion
- canonical/legacy routeからpublic presentation entryまでのacceptance
- app bootstrapが同一scopeのQuiz portsをpresentationへ注入するcomposition test

## 8. 検証順序

各phaseをbuild可能な縦スライスにし、次の順で実行する。

1. 変更対象のfocused unit／contract／widget test
2. `flutter test test/unit/features/quiz test/widget/features/quiz`
3. `flutter test test/unit/integration/catalog_quiz`
4. QuizのGate B acceptanceとapp route/composition test
5. `dart analyze`
6. import boundary checkerとfeature dependency checker
7. full `flutter test`

repository全体の既存赤が残る場合は、Quiz起因かをrule ID／source pathで分離して記録する。
baselineへ新しいQuiz違反を追加して通さない。

## 9. 完了条件

- `quiz.dart` がsole business facadeで、外部deep importが0件
- Quiz外から`features/quiz/internal/**` importが0件
- Quiz business portのframework／internal／Drift row／raw wire map露出が0件
- candidate/gameのCatalog required portをQuizが所有し、adapterが`lib/integration/catalog_quiz`にある
- integration adapterにtrim、paging表示、warning、fallback、candidate selection policyがない
- game application/presentationからCatalog legacy readerとCatalog model依存が0件
- `QuizGameLoadResult.failure(Object)` と自由文字列sourceが残っていない
- presentationから`internal/composition/**` importとwire key解釈が0件
- 旧compatibility adapter、重複repository/data source/use case、未参照root widgetが削除済み
- schema、route、asset wire、fallback、画面挙動に意図しない差分がない
- Quiz起因の両boundary checker違反が0件
- Quiz unit/widget/integration/acceptance、`dart analyze`、full testがgreen
- Quiz ADRとpublic surface manifestが実装と一致する

## 10. 実装時の停止条件

次が必要になった場合は、構造リファクタへ黙って含めず方針を再確認する。

- Catalog identity、Catalog ownership、WordStatus ownershipの変更
- route path、legacy route期限、query parameter、display hint semanticsの変更
- page size、検索方向、検索演算子、candidate orderingの変更
- enrichment failureを画面全体failureにする変更
- not found/no conjugationのuser-visible区別または文言変更
- English placeholder、asset wire key、prompt文法の変更
- 出題対象組合せ、ランダム方式、採点／履歴／進捗の追加
- Drift schema、seed、migration、asset JSON formatの変更
- Quiz以外のfeature debtを同じ差分で解消する必要が生じた場合
