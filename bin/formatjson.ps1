if(!$env:SCOOP_HOME) { $env:SCOOP_HOME = Resolve-Path (scoop prefix scoop) }
$formatjson = "$env:SCOOP_HOME/bin/formatjson.ps1"
$path = "$PSScriptRoot/../bucket" # リポジトリルートの bucket/ を対象にする
Invoke-Expression -command "& '$formatjson' -dir '$path' $($args | ForEach-Object { "$_ " })"
