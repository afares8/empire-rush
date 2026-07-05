# finetune.ps1 - Corre UNA sesion de Devin dedicada a FINE-TUNING del
# proceso overnight de Empire Rush. Analiza los logs de las 5 rondas,
# extrae lecciones, actualiza LEARNINGS.md, re-prioriza ROADMAP.md, y
# produce overnight/FINAL_REPORT.md con el informe de mejoras.
#
# Mismo diseno robusto que session.ps1: try/finally con marker siempre creado.

param(
    [Parameter(Mandatory=$true)][int]$Round,
    [Parameter(Mandatory=$true)][string]$WorkDir,
    [Parameter(Mandatory=$true)][string]$PromptFile,
    [Parameter(Mandatory=$true)][string]$LogFile,
    [Parameter(Mandatory=$true)][string]$DoneMarker,
    [Parameter(Mandatory=$true)][string]$LogDir
)

$ErrorActionPreference = 'Continue'

try {
    [Console]::InputEncoding  = [System.Text.Encoding]::UTF8
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $OutputEncoding = [System.Text.Encoding]::UTF8
} catch { }

$script:isNoOp = $false

function Write-Marker([string]$content) {
    $markerDir = Split-Path -Parent $DoneMarker
    if ($markerDir -and -not (Test-Path $markerDir)) {
        try { New-Item -ItemType Directory -Path $markerDir -Force | Out-Null } catch { }
    }
    try {
        Set-Content -LiteralPath $DoneMarker -Value $content -Encoding UTF8 -Force
        Write-Host "Marker creado: $DoneMarker (contenido: $content)"
    } catch {
        Write-Host "ERROR: No se pudo escribir DoneMarker: $_"
        try { New-Item -ItemType File -Path $DoneMarker -Force | Out-Null } catch {}
    }
}

# Verifica que el fine-tuning produjo trabajo real desde $t0.
# Produce trabajo si: creo un snapshot finetune_*.txt nuevo, O modifico
# LEARNINGS.md, O modifico ROADMAP.md, O creo FINAL_REPORT.md.
function Test-FinetuneProducedWork([string]$workDir, [datetime]$t0) {
    $snapshotsDir = Join-Path $workDir "overnight\snapshots"
    if (Test-Path $snapshotsDir) {
        try {
            $newSnap = Get-ChildItem -Path $snapshotsDir -Filter "finetune_*.txt" -ErrorAction Stop |
                Where-Object { $_.LastWriteTime -ge $t0 } |
                Select-Object -First 1
            if ($newSnap) { return $true }
        } catch { }
    }
    foreach ($f in @("overnight\LEARNINGS.md", "ROADMAP.md", "overnight\FINAL_REPORT.md")) {
        $p = Join-Path $workDir $f
        if (Test-Path $p) {
            try {
                if ((Get-Item $p).LastWriteTime -ge $t0) { return $true }
            } catch { }
        }
    }
    Write-Host "[NoOp] WARN: fine-tuning no produjo snapshot finetune_*.txt nuevo ni modifico LEARNINGS.md/ROADMAP.md/FINAL_REPORT.md desde $($(Get-Date -Date $t0 -Format 'HH:mm:ss'))."
    return $false
}

try {
    $t0 = Get-Date

    try { Set-Location $WorkDir }
    catch {
        Write-Host "ERROR: no se pudo hacer Set-Location a '$WorkDir': $_"
        Write-Marker "CRASH: Set-Location fallo: $_"
        exit 1
    }

    Write-Host "============================================================"
    Write-Host " Devin Overnight (Empire Rush) - FINE-TUNING (Ronda $Round)"
    Write-Host " Directorio : $WorkDir"
    Write-Host " Logs a analizar : $LogDir"
    Write-Host " Modo       : bypass (--permission-mode dangerous)"
    Write-Host " Ejecucion  : print (-p)  -> sale solo al terminar"
    Write-Host " Modelo     : glm-5.2"
    Write-Host " Prompt     : $PromptFile"
    Write-Host " Log        : $LogFile"
    Write-Host " Inicio     : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    Write-Host "============================================================"
    Write-Host ""

    $env:DEVIN_OVERNIGHT_ROLE   = "finetune"
    $env:DEVIN_OVERNIGHT_ROUND  = "$Round"
    $env:DEVIN_OVERNIGHT_LOGDIR = $LogDir

    $ec = -1
    try {
        $logParent = Split-Path -Parent $LogFile
        if ($logParent -and -not (Test-Path $logParent)) {
            try { New-Item -ItemType Directory -Path $logParent -Force | Out-Null } catch { }
        }
        if (-not (Test-Path $LogFile)) { New-Item -ItemType File -Path $LogFile -Force | Out-Null }

        # ---- Watchdog via Start-Job + pipeline + monitor de idle ----
        # (mismo fix que session.ps1 — ver comentario ahi)
        $job = Start-Job -ScriptBlock {
            param($pf, $lf, $wd, $round)
            Set-Location $wd
            $env:DEVIN_OVERNIGHT_ROLE   = "finetune"
            $env:DEVIN_OVERNIGHT_ROUND  = "$round"
            & devin --model glm-5.2 --permission-mode dangerous -p --prompt-file "$pf" 2>&1 | ForEach-Object {
                $_ | Out-File -FilePath "$lf" -Encoding UTF8 -Append
            }
            $LASTEXITCODE
        } -ArgumentList $PromptFile, $LogFile, $WorkDir, $Round

        Write-Host "Devin lanzado en background job (Id $($job.Id)). Watchdog activo..."

        $lastLogSize = 0
        $lastActivity = Get-Date
        $idleThreshold = 60

        while ($job.State -eq 'Running') {
            Start-Sleep -Seconds 3
            if (Test-Path $LogFile) {
                try {
                    $currentSize = (Get-Item $LogFile).Length
                    if ($currentSize -gt $lastLogSize) {
                        $lastActivity = Get-Date
                        $allLines = Get-Content $LogFile -ErrorAction SilentlyContinue
                        if ($allLines) {
                            $linesSoFar = [int]($lastLogSize / 200)
                            if ($linesSoFar -lt $allLines.Count) {
                                $allLines[$linesSoFar..($allLines.Count - 1)] | ForEach-Object { Write-Host $_ }
                            }
                        }
                        $lastLogSize = $currentSize
                    }
                } catch { }
            }
            $idleSecs = [int]((Get-Date) - $lastActivity).TotalSeconds
            if ($idleSecs -gt $idleThreshold) {
                Write-Host ""
                Write-Host "[Watchdog] Devin sin output por ${idleSecs}s (>$idleThreshold). Asumiendo terminado. Matando job..."
                Stop-Job $job -Force -ErrorAction SilentlyContinue
                break
            }
        }

        # Stream final
        if (Test-Path $LogFile) {
            try {
                $finalSize = (Get-Item $LogFile).Length
                if ($finalSize -gt $lastLogSize) {
                    $allLines = Get-Content $LogFile -ErrorAction SilentlyContinue
                    if ($allLines) {
                        $linesSoFar = [int]($lastLogSize / 200)
                        if ($linesSoFar -lt $allLines.Count) {
                            $allLines[$linesSoFar..($allLines.Count - 1)] | ForEach-Object { Write-Host $_ }
                        }
                    }
                }
            } catch { }
        }

        $ec = 0
        try {
            $results = Receive-Job $job -ErrorAction SilentlyContinue
            if ($results -and $results.Count -gt 0) {
                $ec = [int]$results[-1]
            }
        } catch { }
        Remove-Job $job -Force -ErrorAction SilentlyContinue
    } catch {
        Write-Host "EXCEPCION ejecutando devin: $_"
        Write-Marker "CRASH: devin lanzo excepcion: $_"
        exit 1
    }

    if ($ec -ne 0) {
        Write-Host ""
        Write-Host "============================================================"
        Write-Host " ERROR: devin fallo con exit code $ec"
        Write-Host " Fine-tuning NO completado. Abortando (no marker OK)."
        Write-Host "============================================================"
        Write-Marker "CRASH: devin exit code $ec at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        exit 1
    }

    Write-Host ""
    Write-Host "============================================================"
    Write-Host " Fine-tuning termino. Exit code: $ec"
    Write-Host " Fin        : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    Write-Host " Log        : $LogFile"
    Write-Host "============================================================"

    $producedWork = $false
    try {
        $producedWork = Test-FinetuneProducedWork -workDir $WorkDir -t0 $t0
    } catch {
        Write-Host "[NoOp] WARN: la verificacion de trabajo producido lanzo excepcion (fail-open): $_"
        $producedWork = $true
    }

    if ($producedWork) {
        Write-Marker "OK exit=$ec at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    } else {
        $script:isNoOp = $true
        Write-Host ""
        Write-Host "============================================================"
        Write-Host "[NoOp] FINE-TUNING NO-OP detectada: sin snapshot nuevo ni"
        Write-Host " cambios en LEARNINGS.md/ROADMAP.md/FINAL_REPORT.md."
        Write-Host "============================================================"
    }
}
finally {
    if ((-not (Test-Path $DoneMarker)) -and (-not $script:isNoOp)) {
        Write-Marker "CRASH: finally sin marker previo"
    }
    Write-Host ""
    Write-Host "Esta ventana queda abierta para revision (-NoExit). Cierra manualmente si quieres."
}
