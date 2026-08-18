# 命名規則

## 表層の公開契約

```text
interface
  <ドメイン><能力>QueryPort
  <ドメイン><能力>CommandPort
  <他Feature><能力>Gateway

implementation
  <技術><ドメイン><能力>QueryService
  <技術><ドメイン><能力>CommandService
  <ドメイン>ApplicationService
```

例:

```dart
abstract interface class CatalogEntryDetailQueryPort {}
abstract interface class MyWordCommandPort {}
abstract interface class QuizCatalogCandidateGateway {}

final class DriftCatalogEntryDetailQueryService
    implements CatalogEntryDetailQueryPort {}

final class MyWordCommandService implements MyWordCommandPort {}

final class MyWordApplicationService
    implements MyWordQueryPort,
        MyWordCommandPort,
        MyWordStatusCommandPort {}
```

`Port` は契約（interface）だけに使用する。実装クラス名に `Port`、
`Impl`、`Adapter`、`Internal` は使用しない。

## QueryPort と CommandPort

### QueryPort（interface）

読み取り専用の能力を公開する契約には、次の名前を使う。

```text
<ドメイン><読み取る能力>QueryPort
```

例:

```dart
abstract interface class CatalogEntryDetailQueryPort {}
abstract interface class CatalogConjugationQueryPort {}
abstract interface class CatalogWordSearchQueryPort {}
abstract interface class MyWordQueryPort {}
```

### CommandPort（interface）

状態を変更する能力を公開する契約には、次の名前を使う。

```text
<ドメイン><変更する能力>CommandPort
```

例:

```dart
abstract interface class MyWordCommandPort {}
abstract interface class MyWordStatusCommandPort {}
```

### QueryPort / CommandPort の実装

Portを一つだけ実装するクラスは、能力に応じて `QueryService` または
`CommandService` とする。永続化技術が実装を区別する場合だけ、先頭に技術名を付ける。

```text
<技術><ドメイン><能力>QueryService
<技術><ドメイン><能力>CommandService
```

例:

```dart
final class DriftCatalogEntryDetailQueryService
    implements CatalogEntryDetailQueryPort {}

final class MyWordCommandService implements MyWordCommandPort {}
```

QueryPortとCommandPortをまとめて実装するFacadeは、`ApplicationService` とする。

```text
<ドメイン>ApplicationService
```

```dart
final class MyWordApplicationService
    implements MyWordQueryPort,
        MyWordCommandPort,
        MyWordStatusCommandPort {}
```

## Gateway

別Featureが必要とする能力を、そのFeatureの内部詳細を公開せずに表す契約には
`Gateway` を使う。

```text
<他Feature><能力>Gateway
```

例:

```dart
abstract interface class QuizCatalogCandidateGateway {}
abstract interface class PaymentGateway {}
```

Gatewayの実装は、実際の責務に応じて `Service`、`DataSource`、または
`Repository` の命名規則に従う。`GatewayAdapter` は使用しない。

## Infrastructure

Infrastructureの実装名は、次の4種類だけを使う。

| 種別 | 責務 | 形式 |
| --- | --- | --- |
| DAO | DB・SDK・テーブル・コレクションを直接操作する | `<技術><対象>Dao` |
| DataSource | Local/Remoteなど、保存先固有の操作を提供する | `<対象><技術>DataSource` |
| Repository | Domain/Application向けに集約の永続化を提供する | `<対象>Repository` |
| Service | 複数のDAO/DataSource/Repositoryを調整して処理を実行する | `<対象><能力>Service` |

例:

```dart
final class MyWordDao {}
final class MyWordDriftDataSource {}
final class FirebaseMyWordDataSource {}
final class MyWordRepository {}
final class MyWordGuestMigrationService {}
final class MyWordDatasetSyncService {}
```

## 複数PortをまとめるComposition用オブジェクト

複数の公開PortをまとめるComposition用オブジェクトには、`<ドメイン>Ports` を使う。

```dart
final class CatalogPorts {
  final CatalogEntryDetailQueryPort entryDetail;
  final CatalogConjugationQueryPort conjugation;
  final CatalogRankingQueryPort ranking;
}
```
