param(
    # Scoop 本体の upstream 引数の既定値を上書きする
    [String]$upstream = "lukesampson/scoop-extras:master"
)

if(!$env:SCOOP_HOME) { $env:SCOOP_HOME = Resolve-Path (scoop prefix scoop) }
$autopr = "$env:SCOOP_HOME/bin/auto-pr.ps1"
$dir = "$PSScriptRoot/../bucket" # リポジトリルートの bucket/ を対象にする
Invoke-Expression -command "& '$autopr' -dir '$dir' -upstream $upstream $($args | ForEach-Object { "$_ " })"
