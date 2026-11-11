if(!$env:SCOOP_HOME) { $env:SCOOP_HOME = Resolve-Path (scoop prefix scoop) }
$checkurls = "$env:SCOOP_HOME/bin/checkurls.ps1"
$dir = "$PSScriptRoot/../bucket" # リポジトリルートの bucket/ を対象にする
Invoke-Expression -command "& '$checkurls' -dir '$dir' $($args | ForEach-Object { "$_ " })"
