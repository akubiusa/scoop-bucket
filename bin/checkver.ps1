if(!$env:SCOOP_HOME) { $env:SCOOP_HOME = Resolve-Path (scoop prefix scoop) }
$checkver = "$env:SCOOP_HOME/bin/checkver.ps1"
$dir = "$PSScriptRoot/../bucket" # リポジトリルートの bucket/ を対象にする
Invoke-Expression -command "& '$checkver' -dir '$dir' $($args | ForEach-Object { "$_ " })"
