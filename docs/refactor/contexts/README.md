# Refactor Contexts

このディレクトリは、リファクタ中に必要な現在地情報を、作業対象ごとに読み込めるよう分割したcontext集である。

元の`current.md`は`lib/`全体の責務調査を1ファイルにまとめていたため、必要な情報だけを読むには重かった。現在は`current.md`を短い入口にし、詳細を意味範囲ごとのファイルへ分けている。

## Index

| 文書 | 使うタイミング | 内容 |
| --- | --- | --- |
| [current.md](current.md) | 最初に全体の現在地だけ確認したい時 | 重要結論、目的別の最短参照先 |
| [runtime-and-status.md](runtime-and-status.md) | 起動、同期、現在の接続状態を確認する時 | 調査範囲、実行経路、active/prepared sync path、全体結論 |
| [phase-scaffolding.md](phase-scaffolding.md) | 未使用に見える足場の意図を確認する時 | Phase 0、Local-first 1〜4、Phase 1-1〜1-3の成果と扱い |
| [app-routing.md](app-routing.md) | `main.dart`、bootstrap、routing、tabを触る時 | top-level、`lib/app`、旧`lib/router`の責務 |
| [core-map.md](core-map.md) | `lib/core`の依存境界や責務を確認する時 | application、DI、domain、infrastructure、presentation/sharedの責務 |
| [feature-map.md](feature-map.md) | feature単位でリファクタ対象を確認する時 | auth、user、status、my_word、search、word_page、quiz、ranking、sync |
| [next-phase-guide.md](next-phase-guide.md) | 次に何を触るか、削除してよいかを判断する時 | Local-first 5〜7、Phase 1-4以降、checks、削除基準 |

## Quick Routing

| 目的 | 読む順序 |
| --- | --- |
| 何が現役で何が足場か確認する | [current.md](current.md) -> [runtime-and-status.md](runtime-and-status.md) -> [phase-scaffolding.md](phase-scaffolding.md) |
| Local-first 5のword statusを始める | [runtime-and-status.md](runtime-and-status.md) -> [feature-map.md](feature-map.md) -> [next-phase-guide.md](next-phase-guide.md) |
| Local-first 6のMyWordを始める | [feature-map.md](feature-map.md) -> [phase-scaffolding.md](phase-scaffolding.md) -> [next-phase-guide.md](next-phase-guide.md) |
| CurrentSessionを導入する | [runtime-and-status.md](runtime-and-status.md) -> [core-map.md](core-map.md) -> [feature-map.md](feature-map.md) -> [next-phase-guide.md](next-phase-guide.md) |
| Routerやdeep linkを直す | [app-routing.md](app-routing.md) -> [runtime-and-status.md](runtime-and-status.md) |
| import境界違反を減らす | [core-map.md](core-map.md) -> [feature-map.md](feature-map.md) -> [next-phase-guide.md](next-phase-guide.md) |

## Maintenance Rule

このcontext集を更新する時は、対象文書だけを更新する。全体方針やindexが変わる場合だけ、このREADMEと[current.md](current.md)も合わせて更新する。