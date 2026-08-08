# Local-first 3: Drift永続SyncQueueを実装する

- 状態: 完了
- 優先度: P0 / 再送保証
- 依存タスク: [`2-build-drift-sync-schema.md`](2-build-drift-sync-schema.md)、[`../phase0/4-fix-result-propagation.md`](../phase0/4-fix-result-propagation.md)
- 関連タスク: [`4-build-sync-engine.md`](4-build-sync-engine.md)

## 目的

local commit後にprocess killやnetwork failureが発生しても、未送信mutationを失わず安全に再送できるようにする。

## Queueの責務

- SyncQueueはメモリ上の`Queue`ではなくDriftの`sync_outbox`を正とする。
- featureのDrift Repositoryは業務rowとoutboxを同一transactionで更新する。
- Engineはpending itemをleaseし、server-confirmed acknowledgment後だけackする。
- retryable failureは指数backoffとjitterを使い、`nextAttemptAt`まで保留する。
- 認証切れはpause、通信失敗はretry、validation/schema不整合はdead-letterに分類する。
- lease timeout後はprocess restartを含め再取得可能にする。

## Queue contract

```text
leasePending(accountId, dataset, limit, now) -> LeasedMutation list
ack(mutationId, leasedLocalRevision)
retry(mutationId, errorCode, nextAttemptAt)
deadLetter(mutationId, errorCode)
releaseExpiredLeases(now)
```

`ack`は送信した`localRevision`と一致するmutationだけを完了する。送信中に新しいlocal編集が発生した場合、古いackで新しいmutationを消してはならない。

## coalesce方針

- 同じentityの未lease mutationは、意味を保てる場合だけ最新stateへcoalesceする。
- leased mutationは書き換えず、再編集を新しいrevisionとして残す。
- create後、remote未送信のままdeleteされたentityは、remoteに存在しないことが保証できる場合だけ相殺できる。
- patchのfield maskを失うcoalesceは禁止する。

## 必須テスト

- domain row更新とenqueueのatomicity
- enqueue直後のprocess killから復旧できる
- remote成功後、local ack前のprocess killで安全に再送できる
- 同一mutation再送が冪等である
- in-flight中の再編集を古いackが消さない
- retry、backoff、lease timeout、dead-letterが規定どおり遷移する
- account Aのitemをaccount Bでleaseできない

## 完了条件

- [x] Engine停止後も未送信mutationが失われない
- [x] ack条件がrevisionで保護されている
- [x] retryable/non-retryableが型またはerror codeで区別される
- [x] Queue以外のdirty flagが未送信状態のwriterになっていない
- [x] Queue contract testがDrift実装とfake実装の両方に適用される

## LLMへの引き継ぎ事項

application層から「Repository更新後にQueueへ追加」という二段階呼出しをしない。atomicityは同じDrift databaseを所有するinfrastructure transactionで保証する。
