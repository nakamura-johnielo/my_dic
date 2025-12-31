# テスト実行クイックガイド

## すぐに実行

```bash
# 1. 依存関係のインストール
flutter pub get

# 2. 全テスト実行
flutter test

# 3. 特定のテストのみ実行
flutter test test/unit/features/auth/domain/usecase/signin_interactor_test.dart
```

## テストカテゴリ別実行

```bash
# UseCase層のテスト（★★★★★ 最優先）
flutter test test/unit/

# Auth機能のテスト
flutter test test/unit/features/auth/

# ViewModel層のテスト（★★★★☆ Riverpod状態管理）
flutter test test/unit/features/auth/presentation/view_model/

# Widget層のテスト（★★☆☆☆ 最小限）
flutter test test/widget/
```

## 期待される結果

```
✅ 52 tests passed
❌ 1 test failed (widget_test.dart - デフォルトテンプレート、無視してOK)

実行時間: 約5-10秒
```

## トラブルシューティング

### エラー: "Unable to find package"
```bash
flutter pub get
```

### エラー: "Bad state: No ProviderScope found"
→ widget_test.dartの失敗は無視してOK（本プロジェクトのテストではない）

## 個別テストファイルの詳細

| ファイル | テスト数 | 実行時間 | 重要度 |
|---------|---------|---------|--------|
| `result_test.dart` | 14 | ~1s | ★★★★★ |
| `signin_interactor_test.dart` | 9 | ~1s | ★★★★★ |
| `update_status_interactor_test.dart` | 8 | ~1s | ★★★★★ |
| `load_my_word_interactor_test.dart` | 13 | ~1s | ★★★★★ |
| `auth_view_model_test.dart` | 8 | ~2s | ★★★★☆ |
| `auth_state_display_test.dart` | 3 | ~1s | ★★☆☆☆ |

## VSCode で実行

1. テストファイルを開く
2. テストメソッド上部の "Run" / "Debug" をクリック
3. または、コマンドパレット (Ctrl+Shift+P) → "Flutter: Run All Tests"
