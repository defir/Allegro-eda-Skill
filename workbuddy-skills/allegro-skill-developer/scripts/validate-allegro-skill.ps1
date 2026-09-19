param(
    [Parameter(Mandatory = $true)]
    [string]$SkillFile,

    [string]$CnSkillPath = 'D:\Cadence\SPB25.1\tools\bin\cnskill.exe'
)

$ErrorActionPreference = 'Stop'
$sourcePath = (Resolve-Path -LiteralPath $SkillFile).Path

if (-not (Test-Path -LiteralPath $CnSkillPath -PathType Leaf)) {
    throw "cnskill.exe was not found at: $CnSkillPath"
}

$tempRoot = Join-Path ([IO.Path]::GetTempPath()) ('allegro-skill-check-' + [guid]::NewGuid().ToString('N'))
$wrapperPath = Join-Path $tempRoot 'validate.il'
$stdoutPath = Join-Path $tempRoot 'stdout.txt'
$stderrPath = Join-Path $tempRoot 'stderr.txt'

New-Item -ItemType Directory -Path $tempRoot | Out-Null

try {
    $skillPathForLisp = $sourcePath.Replace('\', '/')
    $wrapper = @"
procedure(axlCmdRegister(@rest args) t)
load("$skillPathForLisp")
printf("ALLEGRO_SKILL_LOAD_OK\n")
exit()
"@
    Set-Content -LiteralPath $wrapperPath -Value $wrapper -Encoding ascii

    $process = Start-Process -FilePath $CnSkillPath `
        -ArgumentList @('-nongraph', $wrapperPath) `
        -WindowStyle Hidden `
        -RedirectStandardOutput $stdoutPath `
        -RedirectStandardError $stderrPath `
        -Wait `
        -PassThru

    $stdout = if (Test-Path -LiteralPath $stdoutPath) { Get-Content -LiteralPath $stdoutPath -Raw } else { '' }
    $stderr = if (Test-Path -LiteralPath $stderrPath) { Get-Content -LiteralPath $stderrPath -Raw } else { '' }
    $combined = $stdout + $stderr

    if ($process.ExitCode -ne 0 -or $combined -match '\*Error\*' -or $combined -notmatch 'ALLEGRO_SKILL_LOAD_OK') {
        Write-Error "Allegro SKILL load validation failed.`n$combined"
        exit 1
    }

    Write-Output "PASS: standalone SKILL load succeeded for $sourcePath"
    Write-Output 'NOTE: this does not validate Allegro database/runtime behavior.'
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

