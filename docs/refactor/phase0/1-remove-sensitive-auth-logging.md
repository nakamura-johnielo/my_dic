# Phase 0-1: 認証機密情報のログ出力を除去する

- 状態: 完了
- 優先度: P0 / セキュリティ
- 依存タスク: なし
- 次の推奨タスク: [`2-repair-v5-migration.md`](2-repair-v5-migration.md)
- 元調査: [`FLUTTER_ARCHITECTURE_REVIEW.md`](../../FLUTTER_ARCHITECTURE_REVIEW.md) P0-1

## 目的

refresh token、access token、passwordなどの認証機密情報が、debug/releaseを問わずログへ出ないことを保証する。

## 現在の問題

`lib/features/auth/data/data_source/remote/firebase_auth_dao.dart:23-27`でFirebase Userのrefresh tokenを取得し、ログへ出力している。この処理は認証状態変化とsign-inから呼ばれる。

debug限定ログであっても、開発端末、CI、クラッシュ収集、画面共有、ログ転送から漏えいする。tokenを取得する必要自体がない。

## 対象範囲

- `lib/features/auth/data/data_source/remote/firebase_auth_dao.dart`
- `lib/core/shared/utils/logger.dart`
- 認証、HTTP header、Firebase credentialに関連する全ログ呼出し
- CIまたはtestでの機密語検出

## 対象外

- logger全体の置換
- observability基盤の全面導入
- 認証アーキテクチャの再設計。これはPhase 0-6とPhase 1-4で扱う

## 実装方針

1. refresh tokenを取得・出力するメソッドと呼出しを削除する。
2. UIDやemailも必要最小限にし、可能ならhashまたは内部correlation IDへ置き換える。
3. loggerに構造化されたredaction境界を用意する。文字列置換だけに依存せず、機密値を引数として受けないAPIを優先する。
4. `token`、`refreshToken`、`password`、`authorization`、credential全体を出力している箇所を`rg`で検索する。
5. Firebase例外はcodeと安全なcontextだけを記録し、credentialや生のUser objectを出さない。

## 推奨検証

- `rg -n -i "refresh.?token|access.?token|password|authorization|credential" lib test`
- sign-in、sign-up、sign-out、auth state changeを実行し、ログへtokenが出ないことを確認する
- logger redactionの単体テストを追加する
- 静的checkまたはCIで、禁止ログパターンの再混入を検出する

## 完了条件

- [x] refresh tokenを取得するコードがアプリから削除されている
- [x] token、password、Authorization headerを出力する経路がない
- [x] 認証成功・失敗ログに秘密値が含まれない
- [x] 再混入を検出するtestまたはCI checkがある
- [x] sign-in、sign-outの挙動が変わっていない

## LLMへの引き継ぎ事項

このタスクではログ削除を小さな変更として完結させる。Auth Store、Coordinator、User Profileの再設計を同じ変更に含めない。
