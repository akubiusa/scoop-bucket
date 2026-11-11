# Regenerates the Apps section of README.md from the manifests under bucket/

$bucketDir = Join-Path $PSScriptRoot '..\bucket'
$readmePath = Join-Path $PSScriptRoot '..\README.md'

# Sort manifests by file name
$manifests = Get-ChildItem -Path $bucketDir -Filter '*.json' | Sort-Object Name

# One list item per manifest, linked to its homepage
$appLines = foreach ($manifest in $manifests) {
    $json = Get-Content $manifest.FullName -Raw | ConvertFrom-Json
    $appName = [System.IO.Path]::GetFileNameWithoutExtension($manifest.Name)
    $homepage = $json.homepage
    $version = $json.version
    "- [$appName]($homepage): $version"
}

$lines = Get-Content $readmePath

# The Apps section runs from the '## Apps' heading to the next '## ' heading, or to the end of the file
$appsStart = -1
$nextSectionStart = -1

for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -eq '## Apps') {
        $appsStart = $i
    } elseif ($appsStart -ge 0 -and $lines[$i] -match '^##\s') {
        $nextSectionStart = $i
        break
    }
}

if ($appsStart -lt 0) {
    Write-Error "The '## Apps' section was not found in README.md."
    exit 1
}

$newSection = @('## Apps', '')
$newSection += $appLines

if ($nextSectionStart -ge 0) {
    $newLines = $lines[0..($appsStart - 1)] + $newSection + @('') + $lines[$nextSectionStart..($lines.Count - 1)]
} else {
    # No later section: any other lines in the Apps section are replaced
    $newLines = $lines[0..($appsStart - 1)] + $newSection
}

# Write back with LF line endings and a trailing newline
$content = ($newLines -join "`n") + "`n"
[System.IO.File]::WriteAllText($readmePath, $content)

Write-Host 'Updated the Apps section of README.md.'
