param(
    [Parameter(Mandatory = $true)]
    [string]$SvgPath,

    [string]$InkscapeCommand = "inkscape.com"
)

$ErrorActionPreference = "Stop"
$resolved = (Resolve-Path -LiteralPath $SvgPath).Path

Write-Warning "This Windows transport has not been tested yet. Use a disposable test document only."

& $InkscapeCommand `
    --active-window `
    --actions="file-rebase:true" `
    $resolved

if ($LASTEXITCODE -ne 0) {
    throw "Inkscape exited with code $LASTEXITCODE."
}

Write-Host "The command was sent. Verify visually that the active document changed."
