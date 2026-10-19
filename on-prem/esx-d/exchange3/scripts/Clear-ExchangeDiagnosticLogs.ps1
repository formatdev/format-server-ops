[CmdletBinding()]
param(
    [switch]$Apply,
    [ValidateRange(15, 3650)]
    [int]$RetentionDays = 15
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Test-PathWithin {
    param([string]$Path, [string]$Root)
    $full = [IO.Path]::GetFullPath($Path).TrimEnd('\')
    $base = [IO.Path]::GetFullPath($Root).TrimEnd('\')
    return $full.Equals($base, [StringComparison]::OrdinalIgnoreCase) -or
        $full.StartsWith($base + '\', [StringComparison]::OrdinalIgnoreCase)
}

function Assert-NoReparsePoint {
    param([string]$Path)
    $current = [IO.Path]::GetFullPath($Path)
    while ($current) {
        $item = Get-Item -LiteralPath $current -Force -ErrorAction Stop
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            throw "Reparse point is not permitted: $current"
        }
        $parent = [IO.Directory]::GetParent($current)
        if ($null -eq $parent) { break }
        $current = $parent.FullName
    }
}

function Test-DiagnosticCandidate {
    param($Item, [string]$Root, [datetime]$CutoffUtc)
    if ($Item.PSIsContainer -or
        ($Item.Attributes -band [IO.FileAttributes]::ReparsePoint) -or
        -not (Test-PathWithin $Item.FullName $Root)) { return $false }

    foreach ($protected in @('C:\ExchangeLogs', 'E:\ExchangeDatabases')) {
        if (Test-PathWithin $Item.FullName $protected) { return $false }
    }
    if ($Item.Extension -notin @('.log', '.blg', '.etl')) { return $false }
    if ($Item.Name -match '^E[0-9a-f]{2}(?:[0-9a-f]{8}|tmp)?\.log$') { return $false }
    return $Item.LastWriteTimeUtc -lt $CutoffUtc
}

function Remove-DiagnosticCandidate {
    param($Item, [string]$Root, [datetime]$CutoffUtc, [switch]$Apply)
    # Revalidate metadata and every ancestor immediately before any deletion.
    Assert-NoReparsePoint $Item.FullName
    $fresh = Get-Item -LiteralPath $Item.FullName -Force -ErrorAction Stop
    if (-not (Test-DiagnosticCandidate $fresh $Root $CutoffUtc)) {
        return [pscustomobject]@{ Status = 'SkippedChanged'; Bytes = 0L }
    }
    if (-not $Apply) {
        return [pscustomobject]@{ Status = 'Candidate'; Bytes = $fresh.Length }
    }

    $handle = $null
    try {
        $handle = [IO.File]::Open($fresh.FullName, [IO.FileMode]::Open,
            [IO.FileAccess]::Read, [IO.FileShare]::None)
    }
    catch [IO.IOException] {
        $code = $_.Exception.HResult -band 0xffff
        if ($code -in @(32, 33)) {
            return [pscustomobject]@{ Status = 'SkippedInUse'; Bytes = 0L }
        }
        throw
    }
    finally {
        if ($null -ne $handle) { $handle.Dispose() }
    }

    $fresh = Get-Item -LiteralPath $fresh.FullName -Force -ErrorAction Stop
    Assert-NoReparsePoint $fresh.FullName
    if (-not (Test-DiagnosticCandidate $fresh $Root $CutoffUtc)) {
        return [pscustomobject]@{ Status = 'SkippedChanged'; Bytes = 0L }
    }
    $length = $fresh.Length
    Remove-Item -LiteralPath $fresh.FullName -ErrorAction Stop
    return [pscustomobject]@{ Status = 'Deleted'; Bytes = $length }
}

function Invoke-ExchangeDiagnosticCleanup {
    param([switch]$Apply, [int]$RetentionDays = 15)
    if ($env:COMPUTERNAME -ne 'EXCHANGE3') { throw 'This script is restricted to EXCHANGE3.' }

    $roots = @(
        'C:\inetpub\logs\LogFiles',
        'C:\Program Files\Microsoft\Exchange Server\V15\Logging',
        'C:\Program Files\Microsoft\Exchange Server\V15\Bin\Search\Ceres\Diagnostics\ETLTraces',
        'C:\Program Files\Microsoft\Exchange Server\V15\Bin\Search\Ceres\Diagnostics\Logs'
    )
    $reportDirectory = 'C:\script\ExchangeDiagnosticCleanup\Reports'
    Assert-NoReparsePoint $reportDirectory
    # Check all roots before touching any file, rather than discovering an unsafe root late.
    $presentRoots = @()
    foreach ($root in $roots) {
        if (Test-Path -LiteralPath $root) {
            Assert-NoReparsePoint $root
            $presentRoots += $root
        }
    }
    if ($presentRoots.Count -eq 0) { throw 'No diagnostic roots exist; refusing to proceed.' }

    $mutex = [Threading.Mutex]::new($false, 'Global\Codex.ExchangeDiagnosticCleanup')
    $owned = $false
    $writer = $null
    try {
        try { $owned = $mutex.WaitOne(0) }
        catch [Threading.AbandonedMutexException] { $owned = $true }
        if (-not $owned) { throw 'Another diagnostic cleanup is already running.' }

        $started = [datetime]::UtcNow
        $cutoff = $started.AddDays(-$RetentionDays)
        $mode = if ($Apply) { 'Apply' } else { 'Preview' }
        $runId = $started.ToString('yyyyMMddTHHmmssfffZ') + '-' + $mode
        $auditPath = Join-Path $reportDirectory ($runId + '.jsonl')
        $summaryPath = Join-Path $reportDirectory ($runId + '.summary.json')
        $writer = [IO.StreamWriter]::new($auditPath, $false, [Text.UTF8Encoding]::new($false))
        $writer.AutoFlush = $true
        $results = @()
        $errors = 0

        foreach ($root in $roots) {
            $stats = [ordered]@{
                Root = $root; Present = ($root -in $presentRoots); Scanned = 0L
                Candidates = 0L; CandidateBytes = 0L; Deleted = 0L; DeletedBytes = 0L
                SkippedInUse = 0L; SkippedChanged = 0L; ReparsePointsSkipped = 0L; Errors = 0L
            }
            $stack = [Collections.Generic.Stack[string]]::new()
            if ($stats.Present) { $stack.Push($root) }
            while ($stack.Count -gt 0) {
                $directory = $stack.Pop()
                try {
                    Assert-NoReparsePoint $directory
                    $children = @(Get-ChildItem -LiteralPath $directory -Force -ErrorAction Stop)
                }
                catch {
                    $stats.Errors++; $errors++
                    $writer.WriteLine((@{ Status = 'Error'; Path = $directory; Error = $_.Exception.Message } | ConvertTo-Json -Compress))
                    continue
                }
                foreach ($item in $children) {
                    if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
                        $stats.ReparsePointsSkipped++
                        $writer.WriteLine((@{ Status = 'SkippedReparsePoint'; Path = $item.FullName } | ConvertTo-Json -Compress))
                        continue
                    }
                    if ($item.PSIsContainer) { $stack.Push($item.FullName); continue }
                    $stats.Scanned++
                    if (-not (Test-DiagnosticCandidate $item $root $cutoff)) { continue }
                    $stats.Candidates++; $stats.CandidateBytes += $item.Length
                    try {
                        $result = Remove-DiagnosticCandidate $item $root $cutoff -Apply:$Apply
                        if ($result.Status -eq 'Deleted') {
                            $stats.Deleted++; $stats.DeletedBytes += $result.Bytes
                        }
                        elseif ($result.Status -eq 'SkippedInUse') { $stats.SkippedInUse++ }
                        elseif ($result.Status -eq 'SkippedChanged') { $stats.SkippedChanged++ }
                        $writer.WriteLine((@{
                            Status = $result.Status; Path = $item.FullName
                            Bytes = $result.Bytes; LastWriteTimeUtc = $item.LastWriteTimeUtc.ToString('o')
                        } | ConvertTo-Json -Compress))
                    }
                    catch {
                        $stats.Errors++; $errors++
                        $writer.WriteLine((@{ Status = 'Error'; Path = $item.FullName; Error = $_.Exception.Message } | ConvertTo-Json -Compress))
                    }
                }
            }
            $results += [pscustomobject]$stats
        }
        $summary = [ordered]@{
            Computer = $env:COMPUTERNAME; Mode = $mode; RetentionDays = $RetentionDays
            StartedUtc = $started.ToString('o'); FinishedUtc = [datetime]::UtcNow.ToString('o')
            CutoffUtc = $cutoff.ToString('o'); AuditPath = $auditPath; Errors = $errors
            ProtectedRoots = @('C:\ExchangeLogs', 'E:\ExchangeDatabases'); Roots = $results
        }
        $json = $summary | ConvertTo-Json -Depth 6
        [IO.File]::WriteAllText($summaryPath, $json, [Text.UTF8Encoding]::new($false))
        Write-Output $json
        if ($errors -gt 0) { throw "Cleanup reported $errors errors; inspect $summaryPath" }
    }
    finally {
        if ($null -ne $writer) { $writer.Dispose() }
        if ($owned) { $mutex.ReleaseMutex() }
        $mutex.Dispose()
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    try { Invoke-ExchangeDiagnosticCleanup -Apply:$Apply -RetentionDays $RetentionDays }
    catch { Write-Error -ErrorRecord $_ -ErrorAction Continue; exit 1 }
}
