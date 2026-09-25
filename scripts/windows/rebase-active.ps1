param(
    [Parameter(Mandatory = $true)]
    [string]$SvgPath,

    [string]$InkscapeCommand = "inkscape.com"
)

$ErrorActionPreference = "Stop"
$resolved = (Resolve-Path -LiteralPath $SvgPath).Path

Write-Warning "Tento Windows transport zatím nebyl prakticky ověřen. Používejte pouze testovací dokument."

& $InkscapeCommand `
    --active-window `
    --actions="file-rebase:true" `
    $resolved

if ($LASTEXITCODE -ne 0) {
    throw "Inkscape skončil s návratovým kódem $LASTEXITCODE."
}

Write-Host "Příkaz byl odeslán. Vizuálně ověřte, zda se aktivní dokument změnil."
