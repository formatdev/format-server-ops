[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Clear-ExchangeDiagnosticLogs.ps1')

$root = Join-Path $env:TEMP ('Codex-DiagnosticCleanupTests-' + [guid]::NewGuid().ToString('N'))
$null = New-Item -ItemType Directory -Path $root
$cutoff = [datetime]::UtcNow.AddDays(-15)
$passed = 0
$junction = $null

function Assert-True {
    param([bool]$Condition, [string]$Name)
    if (-not $Condition) { throw "FAIL: $Name" }
    $script:passed++
    Write-Output "PASS: $Name"
}

function New-FixtureFile {
    param([string]$Name, [datetime]$ModifiedUtc)
    $p = Join-Path $root $Name
    [IO.File]::WriteAllText($p, 'fixture')
    [IO.File]::SetLastWriteTimeUtc($p, $ModifiedUtc)
    return Get-Item -LiteralPath $p
}

try {
    $old = New-FixtureFile 'old.log' $cutoff.AddDays(-1)
    Assert-True (Test-DiagnosticCandidate $old $root $cutoff) 'old diagnostic log is eligible'
    foreach ($name in @('old.blg', 'old.etl', 'old.LOG')) {
        $item = New-FixtureFile $name $cutoff.AddDays(-1)
        Assert-True (Test-DiagnosticCandidate $item $root $cutoff) "$name is eligible"
    }
    foreach ($name in @('current.log', 'boundary.log')) {
        $time = if ($name -eq 'boundary.log') { $cutoff } else { [datetime]::UtcNow }
        $item = New-FixtureFile $name $time
        Assert-True (-not (Test-DiagnosticCandidate $item $root $cutoff)) "$name is retained"
    }
    foreach ($name in @('E01000D4683.log', 'e02000366f0.log', 'E01.log', 'E02tmp.log', 'E01.chk', 'E01res00001.jrs', 'database.edb', 'settings.xml')) {
        $item = New-FixtureFile $name $cutoff.AddDays(-100)
        Assert-True (-not (Test-DiagnosticCandidate $item $root $cutoff)) "$name is protected"
    }
    Assert-True (-not (Test-PathWithin ($root + '-sibling\old.log') $root)) 'sibling-prefix path is excluded'
    foreach ($protected in @('C:\ExchangeLogs\Archive-DB2\unusual.log', 'E:\ExchangeDatabases\unusual.log')) {
        $fake = [pscustomobject]@{ FullName = $protected; Name = 'unusual.log'; Extension = '.log'; PSIsContainer = $false; Attributes = [IO.FileAttributes]::Normal; LastWriteTimeUtc = $cutoff.AddDays(-30) }
        Assert-True (-not (Test-DiagnosticCandidate $fake ([IO.Path]::GetPathRoot($protected)) $cutoff)) 'protected root excludes arbitrary log names'
    }
    $preview = Remove-DiagnosticCandidate $old $root $cutoff
    Assert-True ($preview.Status -eq 'Candidate' -and (Test-Path -LiteralPath $old.FullName)) 'preview does not delete'

    $literal = New-FixtureFile 'brackets[1].log' $cutoff.AddDays(-1)
    $result = Remove-DiagnosticCandidate $literal $root $cutoff -Apply
    Assert-True ($result.Status -eq 'Deleted' -and -not (Test-Path -LiteralPath $literal.FullName)) 'literal filename deletion works'

    $locked = New-FixtureFile 'locked.log' $cutoff.AddDays(-1)
    $handle = [IO.File]::Open($locked.FullName, [IO.FileMode]::Open, [IO.FileAccess]::ReadWrite, [IO.FileShare]::Read)
    try {
        $result = Remove-DiagnosticCandidate $locked $root $cutoff -Apply
        Assert-True ($result.Status -eq 'SkippedInUse' -and (Test-Path -LiteralPath $locked.FullName)) 'in-use file is retained'
    }
    finally { $handle.Dispose() }

    $changed = New-FixtureFile 'changed.log' $cutoff.AddDays(-1)
    [IO.File]::SetLastWriteTimeUtc($changed.FullName, [datetime]::UtcNow)
    $result = Remove-DiagnosticCandidate $changed $root $cutoff -Apply
    Assert-True ($result.Status -eq 'SkippedChanged' -and (Test-Path -LiteralPath $changed.FullName)) 'refreshed file is retained'

    $target = Join-Path $root 'target'
    $junction = Join-Path $root 'junction'
    $null = New-Item -ItemType Directory -Path $target
    $null = New-Item -ItemType Junction -Path $junction -Target $target
    $threw = $false
    try { Assert-NoReparsePoint $junction } catch { $threw = $true }
    Assert-True $threw 'junction is rejected'
    $null = [IO.Directory]::Delete($junction)

    Write-Output "All $passed tests passed."
}
finally {
    if ($junction -and (Test-Path -LiteralPath $junction)) { [IO.Directory]::Delete($junction) }
    Remove-Item -LiteralPath $root -Recurse -Force -ErrorAction Stop
}
