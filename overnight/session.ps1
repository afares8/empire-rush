# session.ps1 - Corre UNA sesion de Devin (bypass / print) en una ventana nueva.
# Lanza devin en -p (no-interactivo, sale solo al terminar), loguea todo,
# crea un archivo "marker" cuando termina (para que el controlador lo detecte)
# y deja la ventana abierta para revision.
#
# DISENIO ROBUSTO: try/finally con marker siempre creado.

param(
    [Parameter(Mandatory=$true)][int]$Iteration,
    [Parameter(Mandatory=$true)][int]$Round,
    [Parameter(Mandatory=$true)][string]$WorkDir,
    [Parameter(Mandatory=$true)][string]$PromptFile,
    [Parameter(Mandatory=$true)][string]$LogFile,
    [Parameter(Mandatory=$true)][string]$DoneMarker
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

$guardPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "noop_guard.ps1"
if (Test-Path $guardPath) {
    . $guardPath
    if (-not (Get-Command Test-IterationProducedWork -ErrorAction SilentlyContinue)) {
        Write-Host "ERROR: noop_guard.ps1 no definio Test-IterationProducedWork. Abortando."
        Write-Marker "CRASH: noop_guard.ps1 invalido (funcion no definida)"
        exit 1
    }
} else {
    Write-Host "ERROR: noop_guard.ps1 no existe en $guardPath. Abortando."
    Write-Marker "CRASH: noop_guard.ps1 no existe"
    exit 1
}

try {
    $t0 = Get-Date

    try {
        Set-Location $WorkDir
    } catch {
        Write-Host "ERROR: no se pudo hacer Set-Location a '$WorkDir': $_"
        Write-Marker "CRASH: Set-Location fallo: $_"
        exit 1
    }

    Write-Host "============================================================"
    Write-Host " Devin Overnight (Empire Rush) - Ronda $Round - Iteracion $Iteration"
    Write-Host " Directorio : $WorkDir"
    Write-Host " Modo       : bypass (--permission-mode dangerous)"
    Write-Host " Ejecucion  : print (-p)  -> sale solo al terminar"
    Write-Host " Modelo     : glm-5.2"
    Write-Host " Prompt     : $PromptFile"
    Write-Host " Log        : $LogFile"
    Write-Host " Inicio     : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    Write-Host "============================================================"
    Write-Host ""

    $env:DEVIN_OVERNIGHT_ROUND = "$Round"
    $env:DEVIN_OVERNIGHT_ITER  = "$Iteration"

    $ec = -1
    try {
        $logParent = Split-Path -Parent $LogFile
        if ($logParent -and -not (Test-Path $logParent)) {
            try { New-Item -ItemType Directory -Path $logParent -Force | Out-Null } catch { }
        }
        if (-not (Test-Path $LogFile)) { New-Item -ItemType File -Path $LogFile -Force | Out-Null }

        # ---- Watchdog anti-hang: pipeline foreground + monitor de proceso ----
        #
        # Root cause: devin.exe en modo -p bufferiza TODO el output hasta
        # terminar. El pipeline `& devin | ForEach-Object` captura el output
        # correctamente PERO se queda bloqueado esperando que devin cierre
        # stdout. A veces devin termina su trabajo pero NO sale (hang) — el
        # pipeline nunca retorna y el marker nunca se crea.
        #
        # Fix: lanzar devin con el pipeline en el FOREGROUND (captura output
        # en tiempo real, escribe al log file linea a linea). En paralelo,
        # un watchdog en BACKGROUND monitorea el PROCESO devin (no el log):
        #   - Si devin tiene procesos hijos (bash, godot, git) → está trabajando
        #   - Si devin NO tiene hijos Y su CPU no cambia → terminó pero hung
        #   - Si hung por >120s → matar devin → el pipeline desbloquea
        #
        # Esto es distinto a monitorear el log file (que no crece en tiempo
        # real porque devin bufferiza). Monitoreamos el PROCESO: CPU + hijos.

        # El watchdog corre en un Start-Job para no bloquear el foreground
        $watchdogPid = $PID  # session.ps1 PID, para encontrar devin como hijo
        $idleThreshold = 120  # 120s sin CPU ni hijos → asumir hung

        $watchdogScript = {
            param($parentPid, $threshold)
            $lastCpu = -1.0
            $idleStart = $null
            while ($true) {
                Start-Sleep -Seconds 5
                try {
                    # Buscar devin.exe hijo de parentPid
                    $devinProcs = Get-CimInstance Win32_Process -Filter "Name='devin.exe'" -ErrorAction SilentlyContinue |
                        Where-Object { $_.ParentProcessId -eq $parentPid -or $_.CommandLine -match 'prompt-file' }
                    if (-not $devinProcs -or $devinProcs.Count -eq 0) {
                        # devin no existe → ya terminó o no arrancó aún
                        return
                    }
                    foreach ($dp in $devinProcs) {
                        $proc = Get-Process -Id $dp.ProcessId -ErrorAction SilentlyContinue
                        if (-not $proc) { continue }
                        $cpu = $proc.CPU
                        # Contar procesos hijos directos de devin
                        $children = @(Get-CimInstance Win32_Process -Filter "ParentProcessId=$($dp.ProcessId)" -ErrorAction SilentlyContinue)
                        $childCount = if ($children) { $children.Count } else { 0 }

                        if ($childCount -gt 0 -or $cpu -ne $lastCpu) {
                            # Hay actividad → reset idle timer
                            $idleStart = $null
                        } else {
                            # Sin hijos y CPU sin cambio → posible hung
                            if (-not $idleStart) { $idleStart = Get-Date }
                            $idleSecs = [int]((Get-Date) - $idleStart).TotalSeconds
                            if ($idleSecs -gt $threshold) {
                                # Matar devin y todo su arbol
                                $toKill = @($dp.ProcessId)
                                $queue = New-Object System.Collections.Generic.Queue[int]
                                $queue.Enqueue($dp.ProcessId)
                                while ($queue.Count -gt 0) {
                                    $cur = $queue.Dequeue()
                                    $kids = Get-CimInstance Win32_Process -Filter "ParentProcessId=$cur" -ErrorAction SilentlyContinue
                                    foreach ($k in $kids) { $toKill += $k.ProcessId; $queue.Enqueue($k.ProcessId) }
                                }
                                foreach ($p in $toKill) {
                                    try { Stop-Process -Id $p -Force -ErrorAction SilentlyContinue } catch {}
                                }
                                return
                            }
                        }
                        $lastCpu = $cpu
                    }
                } catch { }
            }
        }

        # Lanzar watchdog en background job
        $wdJob = Start-Job -ScriptBlock $watchdogScript -ArgumentList $watchdogPid, $idleThreshold
        Write-Host "Watchdog activo (job Id $($wdJob.Id), idle threshold ${idleThreshold}s)..."

        # Lanzar devin en FOREGROUND con pipeline (captura output en tiempo real)
        # El pipeline se bloquea hasta que devin cierre stdout. Si devin hang,
        # el watchdog lo mata y el pipeline desbloquea.
        try {
            & devin --model glm-5.2 --permission-mode dangerous -p --prompt-file "$PromptFile" 2>&1 | ForEach-Object {
                Write-Host $_
                $_ | Out-File -FilePath "$LogFile" -Encoding UTF8 -Append
            }
            $ec = $LASTEXITCODE
        } finally {
            # Detener watchdog
            Stop-Job $wdJob -ErrorAction SilentlyContinue
            Remove-Job $wdJob -Force -ErrorAction SilentlyContinue
        }

        # Si devin fue matado por el watchdog, $LASTEXITCODE puede ser null/negativo
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

    Write-Host ""
    Write-Host "============================================================"
    Write-Host " Devin termino. Exit code: $ec"
    Write-Host " Fin        : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    Write-Host " Log        : $LogFile"
    Write-Host "============================================================"

    $producedWork = $false
    try {
        $producedWork = Test-IterationProducedWork -workDir $WorkDir -t0 $t0
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
        Write-Host "[NoOp] ITERACION NO-OP detectada: sin snapshot nuevo ni"
        Write-Host " cambios en ROADMAP.md desde el inicio de la sesion."
        Write-Host " NO se escribe el marker 'OK' => el controlador hara"
        Write-Host " timeout y Reset-FailedIteration descartara el arbol."
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
