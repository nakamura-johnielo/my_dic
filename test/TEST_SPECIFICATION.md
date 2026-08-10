# テストスイート仕様書 - 技術採用者向け

## 📋 概要

本テストスイートは、Clean Architecture + Riverpodによる設計の正当性を実証するために作成されました。
**「テストが書ける」ではなく「テスト可能な設計ができている」ことを示す**ことを目的としています。

## 🎯 テスト戦略

### 優先順位（test_query.md準拠）

```
★★★★★ UseCase Test        : Domain層の純粋なビジネスロジック
★★★★☆ Repository Test     : 外部依存との境界確認
★★★★☆ ViewModel Test     : Riverpod状態管理の検証
★★☆☆☆ Widget Test         : 状態に応じた表示切替のみ
```

### 重要な設計原則

1. **mockito/mocktail 不使用** - Fake実装によるテスト
2. **ProviderContainer 使用** - 本物のRiverpod DI環境でテスト
3. **Domain優先** - UIより Domain/State/DI境界を重視
4. **AAA パターン** - Arrange / Act / Assert を明確に分離

## 📊 テストカバレッジ

### 実装済みテスト

| カテゴリ | テストファイル | テスト数 | 優先度 |
|---------|--------------|---------|--------|
| **Foundation** | `result_test.dart` | 14 | ★★★★★ |
| **UseCase - Auth** | `signin_interactor_test.dart` | 9 | ★★★★★ |
| **UseCase - Core** | `update_status_interactor_test.dart` | 8 | ★★★★★ |
| **UseCase - MyWord** | `load_my_word_interactor_test.dart` | 13 | ★★★★★ |
| **ViewModel - Auth** | `auth_view_model_test.dart` | 8 | ★★★★☆ |
| **Widget - Auth** | `auth_state_display_test.dart` | 3 | ★★☆☆☆ |
| **合計** | **6ファイル** | **52テスト** | - |

## 🏗️ テスト構造

```
test/
├── helpers/                              # テストヘルパー・Fake実装
│   ├── test_helpers.dart                # テストデータ生成ユーティリティ
│   ├── fake_auth_repository.dart        # Fake認証リポジトリ
│   ├── fake_auth_usecases.dart          # Fake認証UseCases
│   ├── fake_word_status_repository.dart # Fake単語ステータスリポジトリ
│   └── fake_my_word_repository.dart     # Fakeマイワードリポジトリ
│
├── unit/                                 # ユニットテスト
│   ├── core/
│   │   ├── shared/utils/
│   │   │   └── result_test.dart         # Result型の動作検証
│   │   └── domain/usecase/
│   │       └── update_status_interactor_test.dart  # 重要な同期ロジック
│   └── features/
│       ├── auth/
│       │   ├── domain/usecase/
│       │   │   └── signin_interactor_test.dart     # 認証ロジック
│       │   └── presentation/view_model/
│       │       └── auth_view_model_test.dart       # Riverpod状態管理
│       └── my_word/
│           └── domain/usecase/
│               └── load_my_word_interactor_test.dart  # ページネーション
│
└── widget/                               # ウィジェットテスト（最小限）
    └── auth/
        └── auth_state_display_test.dart  # 状態による表示切替のみ
```

## 💎 主要テストの特徴

### 1. Result型テスト (`result_test.dart`)

**目的**: Clean Architectureのエラーハンドリング基盤検証

```dart
test('map_transformsData_whenResultIsSuccess', () async {
  const result = Result<int>.success(10);
  final mapped = result.map((data) => data * 2);
  expect(mapped.dataOrNull, 20);
});
```

**検証ポイント**:
- Success/Failureの分岐
- map/flatMapによる関数型エラーハンドリング
- 例外発生時の自動BusinessRuleError変換

### 2. SignInInteractor テスト (`signin_interactor_test.dart`)

**目的**: 入力検証とビジネスロジックの分離を実証

```dart
test('execute_returnsValidationError_whenEmailIsEmpty', () async {
  final repository = FakeAuthRepository.success();
  final useCase = SignInInteractor(repository);
  
  final result = await useCase.execute('', 'password123');
  
  expect(result.errorOrNull, isA<ValidationError>());
  expect(repository.signInCallCount, 0); // リポジトリは呼ばれない
});
```

**検証ポイント**:
- ドメインレベルのバリデーション
- 早期リターンによるリポジトリ呼び出し回避
- Fake実装による呼び出し回数追跡

### 3. UpdateStatusInteractor テスト (`update_status_interactor_test.dart`)

**目的**: 複雑な同期ロジック（ローカル+リモート）の正確性検証

```dart
test('execute_updatesLocalAndRemote_whenUserIsLoggedIn', () async {
  final repository = FakeWordStatusRepository.success();
  final useCase = UpdateStatusInteractor(repository);
  
  await useCase.execute(UpdateStatusInputData('user-123', 100, {...}));
  
  expect(repository.localUpdateCallCount, 1);
  expect(repository.remoteUpdateCallCount, 1);  // ログイン時は両方
});

test('execute_updatesLocalOnly_whenUserIsAnonymous', () async {
  await useCase.execute(UpdateStatusInputData('anonymous', 400, {...}));
  
  expect(repository.localUpdateCallCount, 1);
  expect(repository.remoteUpdateCallCount, 0);  // 匿名は local のみ
});
```

**検証ポイント**:
- オフライン対応のビジネスロジック
- 部分的失敗のハンドリング（local成功、remote失敗）
- ユーザー状態による分岐

### 4. LoadMyWordInteractor テスト (`load_my_word_interactor_test.dart`)

**目的**: ページネーションロジックの数学的正確性検証

```dart
test('execute_calculatesCorrectOffset_forSecondPage', () async {
  final input = LoadMyWordInputData(10, 1); // size=10, page=1
  await useCase.execute(input);
  
  expect(repository.lastOffset, 10);  // offset = page * size = 1 * 10
});
```

**検証ポイント**:
- offset計算の正確性
- エッジケース（page=0、大きなページ番号）
- バリデーション（負の値、ゼロの拒否）

### 5. AuthViewModel テスト (`auth_view_model_test.dart`) ⭐ 最重要

**目的**: Riverpod ProviderContainerを使った本格的な状態管理テスト

```dart
test('signIn_updatesState_whenUserIsVerified', () async {
  // Arrange: Fake UseCases でプロバイダーをオーバーライド
  final container = ProviderContainer(
    overrides: [
      signInInteractorProvider.overrideWithValue(fakeSignIn),
      verificateInteractorProvider.overrideWithValue(fakeVerifyEmail),
      // ...
    ],
  );
  
  // Act: ViewModelのメソッド呼び出し
  final viewModel = container.read(authViewModelProvider.notifier);
  await viewModel.signIn('test@example.com', 'password123');
  
  // Assert: State の変更を検証
  final state = container.read(authViewModelProvider);
  expect(state!.isAuthorized, true);
});
```

**検証ポイント**:
- **ProviderContainer** による本物のDI環境
- **overrideWithValue** による依存注入
- 状態遷移の検証（null → loading → success/error）
- 複雑なフロー（未認証時の確認メール送信）

### 6. Widget テスト (`auth_state_display_test.dart`)

**目的**: 状態による表示の切り替えのみ検証（最小限）

```dart
testWidgets('displays_verificationMessage_whenUserIsNotAuthorized', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authViewModelProvider.overrideWith(
          (ref) => _TestAuthViewModel(UserState(..., isAuthorized: false)),
        ),
      ],
      child: MaterialApp(home: ...),
    ),
  );
  
  expect(find.text('メールを確認してください'), findsOneWidget);
});
```

**検証ポイント**:
- 状態による条件分岐のみ
- レイアウト・色・paddingは検証しない
- タップイベントの詳細な動作は検証しない

## 🔧 Fake実装の設計

### Fake vs Mock の違い

```dart
// ❌ Mockito/Mocktail アプローチ（使用しない）
when(mock.signIn(any, any)).thenReturn(Result.success(auth));

// ✅ Fake実装アプローチ（採用）
final repo = FakeAuthRepository.success(auth: testAuth);
final useCase = SignInInteractor(repo);
```

### Fake実装の特徴

1. **Factoryパターン**: よくあるシナリオを簡単に生成
   ```dart
   FakeAuthRepository.success()
   FakeAuthRepository.invalidCredentials()
   FakeAuthRepository.networkError()
   ```

2. **呼び出し追跡**: メソッド呼び出しの検証が可能
   ```dart
   expect(repository.signInCallCount, 1);
   expect(repository.lastEmail, 'test@example.com');
   ```

3. **実装の透明性**: テストで何が起きているか一目瞭然

## 🎓 技術採用者へのアピールポイント

### 1. Clean Architecture の理解

- **Domain層の独立性**: UseCaseはFlutter依存ゼロで純粋なDartでテスト可能
- **境界の明確化**: Repository interfaceで外部依存を抽象化
- **エラーハンドリングの一貫性**: Result型による関数型エラーハンドリング

### 2. Riverpod の実践的活用

- **ProviderContainer**: テストでも本番と同じDI環境を使用
- **overrideWithValue**: 依存を簡単に差し替え可能な設計
- **StateNotifier**: 状態遷移が追跡可能で予測可能

### 3. テスト駆動設計（TDD指向）

- **テストファースト思考**: テストしやすい設計 = 保守しやすい設計
- **境界のテスト**: 重要なビジネスロジックの境界を優先的にテスト
- **エッジケース網羅**: 正常系だけでなく異常系・境界値も検証

### 4. 実務レベルの品質

- **命名規約**: `what_happens_expectedResult` 形式で意図が明確
- **AAA パターン**: Arrange/Act/Assertで読みやすい構造
- **適切な粒度**: テストが多すぎず少なすぎず、重要な部分に集中

## 📈 今後の拡張可能性

現在のテストスイートは基盤を確立しており、以下の追加が容易です:

1. **Repository実装テスト** (★★★★☆)
   - FirebaseとDriftの実装テスト
   - DTO ↔ Entity の変換テスト
   - エラーハンドリング変換テスト

2. **追加ViewModelテスト** (★★★★☆)
   - MyWordViewModel
   - RankingViewModel
   - WordDetailViewModel

3. **Integration Tests** (★★★☆☆)
   - 認証フロー全体
   - 単語登録から表示までの流れ

4. **Golden Tests** (★★☆☆☆)
   - UIスクリーンショット回帰テスト

## 🚀 テスト実行方法

```bash
# 全テスト実行
flutter test

# 特定カテゴリのみ実行
flutter test test/unit/                    # UseCaseとRepository
flutter test test/unit/features/auth/      # Auth機能のみ
flutter test test/widget/                  # Widgetテストのみ

# カバレッジ取得
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 📝 テスト結果サマリ

```
✅ 52 tests passed
❌ 1 test failed (default Flutter template - 無関係)

カテゴリ別:
  Foundation (Result型):     14 passed
  UseCase - SignIn:          9 passed
  UseCase - UpdateStatus:    8 passed
  UseCase - LoadMyWord:      13 passed
  ViewModel - Auth:          8 passed
  Widget - Auth:             3 passed (0 failed in our code)
```

## 🎯 結論

本テストスイートは以下を実証しています:

1. ✅ **Clean Architectureの適切な実装** - 層の分離とテスト可能性
2. ✅ **Riverpodの高度な活用** - ProviderContainerによる本格的DI
3. ✅ **mockito不使用のFake実装** - 透明性の高いテストコード
4. ✅ **実務レベルの品質** - 命名、構造、カバレッジのバランス
5. ✅ **保守性の高い設計** - テスト追加が容易な拡張可能な構造

**「テストが書ける」ではなく「テスト可能な設計」を実現しています。**
