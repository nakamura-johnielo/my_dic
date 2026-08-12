# 命名規則
## 推奨規則早見
```text
interface
  <ドメイン><読み取る能力>ReaderPort
  <依存先><能力>Gateway

implementation
  <技術><Gateway名>GatewayAdapter
  <技術><ReaderPort名>Reader
```

例：

```dart
abstract class CatalogConjugationReaderPort
abstract class CatalogConjugationSearchReaderPort

abstract class QuizCatalogCandidateGateway
abstract class PaymentGateway

final class HttpQuizCatalogGatewayAdapter implements QuizCatalogGateway {}
final class QuizCatalogCandidateGatewayAdapter implements QuizCatalogCandidateGateway {}

final class DriftCatalogEntryDetailReader implements CatalogEntryDetailReaderPort {}
final class CatalogEntryDetailReader implements CatalogEntryDetailReaderPort {}
```

## 推奨規則詳細
### 1. 自分の機能を公開する読み取り`Port` (interface)

```text
<ドメイン><読み取る能力>ReaderPort
```
能力を表す名詞句を `<読み取る能力>` に置きます。

例：

```dart
CatalogEntryDetailReaderPort
CatalogConjugationReaderPort
CatalogConjugationSearchReaderPort
QuizCandidateReaderPort
```

### 2. 別Featureへの要求`Gateway` (interface)

```text
<依存先><能力>Gateway
```

必要なら、契約を所有するFeatureの名前も付けます。

```dart
QuizCatalogCandidateGateway
SearchCatalogGateway
PaymentGateway
NotificationGateway
```

重要なのは、Gatewayを利用する側が契約を所有することです。

たとえばQuizが必要とするCatalogアクセスなら、`Catalog`の汎用APIではなく「Quizから見たCatalog」を表します。

```dart
abstract interface class QuizCatalogCandidateGateway {
  // Quizが本当に必要な操作だけ
}
```

```text
Quizが所有する、Catalog candidate用Gateway
```

とまとまりを読み取りやすい。

ただし、プロジェクトですでに `SearchCatalogGateway` があるため、それに合わせるなら以下でもよいでしょう。


### 3. `Gateway`の実装 (implements)

```text
<技術><Gateway名>Adapter
```

1. 実装技術が明示できる場合は：

```dart
final class HttpQuizCatalogGatewayAdapter
    implements QuizCatalogGateway {}
```

2. 実装技術が明示できない場合は：

```dart
final class QuizCatalogCandidateGatewayAdapter
    implements QuizCatalogCandidateGateway {}
```


### 4.  `ReaderPort`の実装 (implements)

```text
<技術><ReaderPort名>Reader
```

```dart
// 契約
abstract interface class CatalogEntryDetailReaderPort {}

// 実装
final class DriftCatalogEntryDetailReader
    implements CatalogEntryDetailReaderPort {}
```


### 5. 複数Portを束ねる型

単に依存をまとめるComposition用オブジェクトなら、`...Ports` が明確です。

```dart
final class CatalogReadPorts {
  final CatalogEntryDetailReaderPort entryDetail;
  final CatalogConjugationReaderPort conjugation;
  final CatalogRankingReaderPort ranking;
}
```

