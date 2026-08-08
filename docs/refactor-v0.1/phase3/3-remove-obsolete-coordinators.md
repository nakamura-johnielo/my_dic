# Phase 3-3: コメントアウトされた旧Coordinatorを削除またはADR化する

- 状態: 未着手
- 優先度: 低〜中 / 可読性
- 依存タスク: [`../phase1/4-introduce-current-session.md`](../phase1/4-introduce-current-session.md)、[`../phase2/4-remove-ref-from-coordinators.md`](../phase2/4-remove-ref-from-coordinators.md)
- 元調査: [`FLUTTER_ARCHITECTURE_REVIEW.md`](../../FLUTTER_ARCHITECTURE_REVIEW.md) 6 P1-1、10.1

## 目的

コメントアウトされた旧認証・User連携実装を本番コードから除き、必要な設計判断だけを短いADRとして残す。

## 現在の問題

旧`AuthUserCoordinator`は約149行すべてがコメントアウトされている。コード履歴の代わりとしてsource内に残り、現在の実装か設計案か判断しにくい。DI側にも未完成Coordinatorを示すTODOがある。

## 対象範囲

- コメントアウトされた`AuthUserCoordinator`
- 関連する未使用DI、TODO、import
- Auth/User lifecycleに関する有効な設計判断

## 実装方針

1. Git履歴と現行session設計を確認する。
2. 旧コードから今後も必要な要件だけを抽出する。
3. 「AuthとUser Profileを分離し、AppSessionで派生統合する」などの判断を残す必要があれば`docs/adr/`へ短いADRを作る。
4. コメントアウトコードと未使用DIを削除する。
5. TODOは実行可能なissue/taskへ移すか、解決済みとして削除する。

## ADRに残す候補

- Authentication、User Profile、Authorizationの境界
- Firebase auth streamを単一source of truthにする理由
- profile ensureをidempotentにする理由
- Coordinatorへ`Ref`を保持させない理由

## 推奨検証

- 旧Coordinator名の参照が0
- current sessionとsign-up lifecycle testが通る
- 新規参加者が現行入口を一つに特定できる
- ADRがsource codeを複製せず、判断と理由だけを記録する

## 完了条件

- [ ] コメントアウトされた旧Coordinatorがsourceから削除されている
- [ ] 未使用DIとimportが削除されている
- [ ] 必要な判断はADRまたはrefactor文書に残っている
- [ ] 現行認証フローの入口が明確である

## LLMへの引き継ぎ事項

Gitが履歴を保持するため、旧実装コードを文書へ丸ごと移さない。ADRには採用した判断、却下した代替、理由、影響だけを書く。
