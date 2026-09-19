param(
    [Parameter(Mandatory = $true)]
    [string]$SkillFile,

    [string]$CadenceRoot = $env:CDSROOT
)

$ErrorActionPreference = 'Stop'
$sourcePath = (Resolve-Path -LiteralPath $SkillFile).Path

if ([string]::IsNullOrWhiteSpace($CadenceRoot)) {
    throw 'CadenceRoot was not supplied and CDSROOT is not set.'
}

$docRoot = Join-Path $CadenceRoot 'share\pcb\examples\skill\DOC'
if (-not (Test-Path -LiteralPath $docRoot -PathType Container)) {
    throw "Cadence SKILL documentation was not found at: $docRoot"
}

$ordinal = [System.StringComparer]::Ordinal
$ordinalIgnoreCase = [System.StringComparer]::OrdinalIgnoreCase
$documented = [System.Collections.Generic.HashSet[string]]::new($ordinal)
$variants = [System.Collections.Generic.Dictionary[string,System.Collections.Generic.Dictionary[string,int]]]::new($ordinalIgnoreCase)
$verifiedCanonical = [System.Collections.Generic.Dictionary[string,string]]::new($ordinalIgnoreCase)
$verifiedCanonical.Add('axlBackdrillGet', 'axlBackdrillGet')

Get-ChildItem -LiteralPath $docRoot -Filter '*.txt' -File -Recurse | ForEach-Object {
    $text = Get-Content -LiteralPath $_.FullName -Raw
    foreach ($match in [regex]::Matches($text, '\baxl[A-Za-z0-9_]+\b')) {
        $name = $match.Groups[1].Value
        if ([string]::IsNullOrEmpty($name)) {
            $name = $match.Value
        }
        [void]$documented.Add($name)
        if (-not $variants.ContainsKey($name)) {
            $variants.Add($name, [System.Collections.Generic.Dictionary[string,int]]::new($ordinal))
        }
        if ($variants[$name].ContainsKey($name)) {
            $variants[$name][$name]++
        }
        else {
            $variants[$name].Add($name, 1)
        }
    }
}

$source = Get-Content -LiteralPath $sourcePath -Raw
$source = [regex]::Replace($source, '(?m);.*$', '')
$source = [regex]::Replace($source, '"(?:\\.|[^"\\])*"', '""')
$usedNames = [System.Collections.Generic.HashSet[string]]::new($ordinal)
foreach ($match in [regex]::Matches($source, '\baxl[A-Za-z0-9_]+\b')) {
    [void]$usedNames.Add($match.Value)
}

$caseErrors = 0
$unknownNames = 0
foreach ($name in ($usedNames | Sort-Object)) {
    if ($verifiedCanonical.ContainsKey($name)) {
        $expected = $verifiedCanonical[$name]
        if ($name -ceq $expected) {
            continue
        }
        Write-Output "ERROR: API capitalization mismatch: $name -> $expected"
        $caseErrors++
    }
    elseif ($documented.Contains($name)) {
        continue
    }
    elseif ($variants.ContainsKey($name)) {
        $expected = $variants[$name].GetEnumerator() |
            Sort-Object -Property Value -Descending |
            Select-Object -First 1 -ExpandProperty Key
        if ($name -ceq $expected) {
            continue
        }
        Write-Output "ERROR: API capitalization mismatch: $name -> $expected"
        $caseErrors++
    }
    else {
        Write-Output "NOTE: API name is absent from the installed documentation: $name"
        $unknownNames++
    }
}

if ($caseErrors -gt 0) {
    Write-Error "Allegro API name check failed with $caseErrors case-only mismatch(es)."
    exit 1
}

Write-Output "PASS: no case-only Allegro API mismatches were found in $sourcePath"
if ($unknownNames -gt 0) {
    Write-Output "NOTE: $unknownNames name(s) require manual review for version-specific or wrapper APIs."
}
