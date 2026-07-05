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

        # ---- Watchdog anti-hang (mismo enfoque que session.ps1) ----
        $watchdogPid = $PID
        $idleThreshold = 120

        $watchdogScript = {
            param($parentPid, $threshold)
            $lastCpu = -1.0
            $idleStart = $null
            while ($true) {
                Start-Sleep -Seconds 5
                try {
                    $devinProcs = Get-CimInstance Win32_Process -Filter "Name='devin.exe'" -ErrorAction SilentlyContinue |
                        Where-Object { $_.ParentProcessId -eq $parentPid -or $_.CommandLine -match 'prompt-file' }
                    if (-not $devinProcs -or $devinProcs.Count -eq 0) { return }
                    foreach ($dp in $devinProcs) {
                        $proc = Get-Process -Id $dp.ProcessId -ErrorAction SilentlyContinue
                        if (-not $proc) { continue }
                        $cpu = $proc.CPU
                        $children = @(Get-CimInstance Win32_Process -Filter "ParentProcessId=$($dp.ProcessId)" -ErrorAction SilentlyContinue)
                        $childCount = if ($children) { $children.Count } else { 0 }
                        if ($childCount -gt 0 -or $cpu -ne $lastCpu) {
                            $idleStart = $null
                        } else {
                            if (-not $idleStart) { $idleStart = Get-Date }
                            $idleSecs = [int]((Get-Date) - $idleStart).TotalSeconds
                            if ($idleSecs -gt $threshold) {
                                $toKill = @($dp.ProcessId)
                                $queue = New-Object System.Collections.Generic.Queue[int]
                                $queue.Enqueue($dp.ProcessId)
                                while ($queue.Count -gt 0) {
                                    $cur = $queue.Dequeue()
                                    $kids = Get-CimInstance Win32_Process -Filter "ParentProcessId=$cur" -ErrorAction SilentlyContinue
                                    foreach ($k in $kids) { $toKill += $k.ProcessId; $queue.Enqueue($k.ProcessId) }
                                }
                                foreach ($p in $toKill) { try { Stop-Process -Id $p -Force -ErrorAction SilentlyContinue } catch {} }
                                return
                            }
                        }
                        $lastCpu = $cpu
                    }
                } catch { }
            }
        }

        $wdJob = Start-Job -ScriptBlock $watchdogScript -ArgumentList $watchdogPid, $idleThreshold
        Write-Host "Watchdog activo (job Id $($wdJob.Id), idle threshold ${idleThreshold}s)..."

        try {
            & devin --model glm-5.2 --permission-mode dangerous -p --prompt-file "$PromptFile" 2>&1 | ForEach-Object {
                Write-Host $_
                $_ | Out-File -FilePath "$LogFile" -Encoding UTF8 -Append
            }
            $ec = $LASTEXITCODE
        } finally {
            Stop-Job $wdJob -ErrorAction SilentlyContinue
            Remove-Job $wdJob -Force -ErrorAction SilentlyContinue
        }

        if ($null -eq $ec -or $ec -lt 0) { $ec = 0 }

        # ---- Cleanup: matar procesos devin huerfanos ----
        try {
            Get-CimInstance Win32_Process -Filter "Name='devin.exe'" -ErrorAction SilentlyContinue |
                Where-Object { $_.CommandLine -match 'prompt-file' } |
                ForEach-Object {
                    $parent = Get-Process -Id $_.ParentProcessId -ErrorAction SilentlyContinue
                    if (-not $parent) {
                        Write-Host "[Cleanup] Matando devin huerfano PID $($_.ProcessId)"
                        Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
                    }
                }
        } catch { }
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
