# noop_guard.ps1 - Guard contra iteraciones WIP no-op para empire-rush.
#
# Antes de escribir el marker "OK" de fin de iteracion, verificar que
# esta produjo trabajo real (un snapshot nuevo en overnight/snapshots/
# Y una modificacion de ROADMAP.md desde el inicio de la sesion).
# Si no, el caller NO debe escribir el marker => el controlador hara
# timeout y Reset-FailedIteration descartara el arbol => no se
# commitea un WIP no-op (solo marker file, sin feature construida).

function Test-IterationProducedWork([string]$workDir, [datetime]$t0) {
    $snapshotsDir = Join-Path $workDir "overnight\snapshots"
    $hasNewSnapshot = $false
    if (Test-Path $snapshotsDir) {
        try {
            $newSnap = Get-ChildItem -Path $snapshotsDir -Filter "*.txt" -ErrorAction Stop |
                Where-Object { $_.LastWriteTime -ge $t0 } |
                Select-Object -First 1
            if ($newSnap) { $hasNewSnapshot = $true }
        } catch { }
    }

    $hasReportChange = $false
    foreach ($f in @("ROADMAP.md")) {
        $p = Join-Path $workDir $f
        if (Test-Path $p) {
            try {
                if ((Get-Item $p).LastWriteTime -ge $t0) { $hasReportChange = $true; break }
            } catch { }
        }
    }

    if (-not $hasNewSnapshot) {
        Write-Host "[NoOp] WARN: no se encontro un snapshot nuevo en overnight/snapshots/ desde $($(Get-Date -Date $t0 -Format 'HH:mm:ss'))."
    }
    if (-not $hasReportChange) {
        Write-Host "[NoOp] WARN: ROADMAP.md no fue modificado desde $($(Get-Date -Date $t0 -Format 'HH:mm:ss'))."
    }
    return ($hasNewSnapshot -and $hasReportChange)
}
