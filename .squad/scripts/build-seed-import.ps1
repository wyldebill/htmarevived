[CmdletBinding()]
param(
    [string]$SeedFile = ".squad\data\buffalo-small-businesses-seed.json",
    [string]$OutputFile = ".squad\data\buffalo-small-businesses-rtdb-seed.json",
    [string]$NodePath = "businesses",
    [switch]$Apply
)

$ErrorActionPreference = "Stop"

function Resolve-RepoPath {
    param([string]$Path)
    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }

    return Join-Path (Get-Location) $Path
}

$seedFilePath = Resolve-RepoPath -Path $SeedFile
$outputFilePath = Resolve-RepoPath -Path $OutputFile

if (-not (Test-Path -LiteralPath $seedFilePath)) {
    throw "Seed file not found: $seedFilePath"
}

$rawSeed = Get-Content -LiteralPath $seedFilePath -Raw | ConvertFrom-Json
if ($null -eq $rawSeed -or $rawSeed.Count -ne 20) {
    throw "Seed input must contain exactly 20 businesses. Found: $($rawSeed.Count)"
}

$sortedSeed = $rawSeed | Sort-Object -Property id
$businessesPayload = [ordered]@{}

foreach ($entry in $sortedSeed) {
    if ([string]::IsNullOrWhiteSpace($entry.id)) { throw "Every business must include a non-empty id." }
    if ([string]::IsNullOrWhiteSpace($entry.name)) { throw "Missing name for id '$($entry.id)'." }
    if ([string]::IsNullOrWhiteSpace($entry.category)) { throw "Missing category for id '$($entry.id)'." }
    if ([string]::IsNullOrWhiteSpace($entry.address)) { throw "Missing address for id '$($entry.id)'." }
    if ($null -eq $entry.coordinates) { throw "Missing coordinates for id '$($entry.id)'." }
    if ($null -eq $entry.coordinates.lat) { throw "Missing coordinates.lat for id '$($entry.id)'." }
    if ($null -eq $entry.coordinates.lng) { throw "Missing coordinates.lng for id '$($entry.id)'." }

    $businessesPayload[$entry.id] = [ordered]@{
        name = $entry.name
        category = $entry.category
        address = $entry.address
        lat = [double]$entry.coordinates.lat
        lng = [double]$entry.coordinates.lng
    }
}

$payloadJson = $businessesPayload | ConvertTo-Json -Depth 5
$outputDir = Split-Path -Parent $outputFilePath
if (-not (Test-Path -LiteralPath $outputDir)) {
    New-Item -Path $outputDir -ItemType Directory | Out-Null
}
Set-Content -LiteralPath $outputFilePath -Value $payloadJson

Write-Host "Prepared deterministic RTDB payload for '$NodePath' with 20 businesses."
Write-Host "Output file: $outputFilePath"

if (-not $Apply) {
    Write-Host "Dry run complete. Use -Apply with FIREBASE_DATABASE_URL and FIREBASE_DATABASE_SECRET to import."
    exit 0
}

$databaseUrl = $env:FIREBASE_DATABASE_URL
$databaseSecret = $env:FIREBASE_DATABASE_SECRET

if ([string]::IsNullOrWhiteSpace($databaseUrl)) {
    throw "FIREBASE_DATABASE_URL is required when using -Apply."
}
if ([string]::IsNullOrWhiteSpace($databaseSecret)) {
    throw "FIREBASE_DATABASE_SECRET is required when using -Apply."
}

$trimmedUrl = $databaseUrl.TrimEnd("/")
$trimmedNodePath = $NodePath.Trim("/")
$targetUri = "$trimmedUrl/$trimmedNodePath.json?auth=$databaseSecret"

Invoke-RestMethod -Method Put -Uri $targetUri -Body $payloadJson -ContentType "application/json" | Out-Null
Write-Host "Realtime Database import complete at /$trimmedNodePath."
