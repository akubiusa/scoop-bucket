# AGENTS.md

AI コーディングエージェントとコントリビューター向けのガイドです。`CLAUDE.md` はこのファイルを取り込み、`.github/copilot-instructions.md` がレビュー観点を補足します。

## Language

- すべての成果物は **日本語** で書く。コミットメッセージの description、PR / Issue のタイトルと本文、レビューコメント、コード内コメント、ドキュメント (`README.md`、`AGENTS.md` など) が対象。
- 日本語と英数字の間には半角スペースを入れる。段落の文の途中で手動改行しない。
- 例外 (そのまま維持する): 引用、技術的な識別子、生成ファイル、外部由来のテキスト。マニフェストの `description` は上流アプリの説明文なので英語のままとし、Scoop の慣習に従う。
- 例外として `.github/copilot-instructions.md` は英語で書く (Copilot 向けのレビュー指示)。
- ランタイムメッセージ (ログ、エラー) は英語。
- 過去のコミットの言語を変えるために Git の履歴を書き換えない。

## Overview

個人用 Scoop バケット。`bucket/*.json` が Scoop マニフェスト、`bin/*.ps1` が PowerShell スクリプト。既定ブランチは `master`。

- `bucket/*.json`: アプリごとのマニフェスト。ファイル名はアプリ名由来で、大文字を含むもの (`ElitesRNGAuraObserver.json` など) もあるが意図的。
- `bin/checkver.ps1`、`checkurls.ps1`、`checkhashes.ps1`、`formatjson.ps1`、`missing-checkver.ps1`、`auto-pr.ps1`: Scoop 本体 (`$env:SCOOP_HOME`、未設定なら `scoop prefix scoop`) の同名スクリプトに `bucket/` を渡して呼び出すラッパー。引数はそのまま Scoop 本体に渡る。
- `bin/test.ps1`: Pester (5.2.0 以上) と BuildHelpers (2.0.1 以上) が必要。リポジトリ全体を対象に Pester を実行し、失敗数を終了コードにする。現状 `*.Tests.ps1` は存在しないため、実質的なテストは定義されていない。
- `bin/update-readme.ps1`: `bucket/*.json` から `README.md` の `## Apps` セクションを再生成する。見出し `## Apps` を文字列一致で探すため、README のこの見出しを変更しない。
- `README.md` の `## Apps` セクションは手動編集しない。スクリプトは `## Apps` から次の `##` 見出し (なければファイル末尾) までを丸ごと置き換えるため、このセクションに説明文などを足さない (README の最後のセクションのままにする)。

## Commands

```powershell
.\bin\checkver.ps1            # バージョンチェック (-Update で更新)
.\bin\checkurls.ps1           # URL チェック
.\bin\checkhashes.ps1         # ハッシュチェック
.\bin\formatjson.ps1          # マニフェストの JSON 整形
.\bin\missing-checkver.ps1    # checkver 未定義のマニフェストを検出
.\bin\test.ps1                # Pester テスト
.\bin\update-readme.ps1       # README の Apps セクションを再生成
```

PowerShell から Scoop が使える環境 (`scoop` が PATH 上にある、または `SCOOP_HOME` が設定済み) が前提。`bin/` のスクリプトは Windows PowerShell 5.1 と PowerShell Core の両方で動かす (CI が両方で `bin/test.ps1` を実行する)。

## CI / 自動更新

- `.github/workflows/ci.yml` (Tests): PR と push で、Scoop 本体を checkout して `bin/test.ps1` を WindowsPowerShell と PowerShell Core の 2 ジョブで実行する。
- `.github/workflows/excavator.yml` (Excavator): 4 時間ごと (`20 */4 * * *`) と手動実行。全マニフェストに `checkver.ps1 -Update -SkipUpdated` を実行し、更新があったマニフェストごとに `<app>: Update to version <version>` のコミットを作り、`update-readme.ps1` で README を更新して `master` に直接 push する (PR は作らない)。push には Secrets の `EXCAVATOR_SSH_KEY` (Deploy Key) を使う。
- `.github/workflows/keep-alive.yml`: 毎月 1 日に、非アクティブで無効化されたワークフローを再有効化する。
- `docs(readme): Apps セクションを自動更新` と `<app>: Update to version <version>` のコミットは自動生成。手動で同様のコミットを作らない。

## マニフェストの規約

- [Scoop Schema](https://raw.githubusercontent.com/ScoopInstaller/Scoop/master/schema.json) に準拠し、`$schema` を含める。
- 必須: `version`、`description`、`homepage`、`license`、`url` (32bit / 64bit が別なら `architecture`)、`hash`。`hash` を省略しない。
- 自動更新のため `checkver` と `autoupdate` を定義する (`autoupdate` の URL は `$version` で `checkver` の結果と整合させる)。
- 永続化するデータは `persist`、コマンド公開は `bin`、スタートメニューのショートカットは `shortcuts`、インストール前後の処理は `pre_install` / `post_install` で指定する。
- 既存の例: `bucket/ScreenRelay.json` (GitHub Releases + `persist` + `post_install`)、`bucket/jquake.json` (`architecture` ごとの `autoupdate`)。
- マニフェストを追加・変更したら `.\bin\formatjson.ps1` で整形し、`README.md` の Apps は `.\bin\update-readme.ps1` で更新する (Excavator も自動更新する)。

## Conventions

- コミットは [Conventional Commits](https://www.conventionalcommits.org/)、ブランチは [Conventional Branch](https://conventional-branch.github.io) の短縮形 (`feat/...`、`fix/...`)。
- スクリプト内のコメントは日本語、エラーメッセージは英語。
- Renovate が作成した PR にコミットしない。シークレットをコミットしない。
