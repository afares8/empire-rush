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

        # ---- Watchdog via Start-Job + pipeline + monitor de idle ----
        # Root cause del bug: devin.exe en modo -p a veces NO sale despues de
        # imprimir su resumen. El pipeline `& devin | ForEach-Object` se queda
        # bloqueado esperando que devin cierre stdout => el finally de
        # session.ps1 nunca se ejecuta => el marker nunca se crea => el
        # controller espera 90 min de timeout para matar el arbol.
        #
        # Fix: lanzar devin en un Start-Job (background PowerShell) que usa
        # el pipeline (captura output correctamente, a diferencia de
        # Start-Process -RedirectStandardOutput que no captura console APIs).
        # El foreground monitorea el tamano del log file. Si devin no produce
        # output nuevo por 60s (idle), Stop-Job mata el job + devin. Asi el
        # foreground nunca se bloquea y el marker se crea inmediatamente.
        $job = Start-Job -ScriptBlock {
            param($pf, $lf, $wd, $round, $iter)
            Set-Location $wd
            $env:DEVIN_OVERNIGHT_ROUND = "$round"
            $env:DEVIN_OVERNIGHT_ITER  = "$iter"
            & devin --model glm-5.2 --permission-mode dangerous -p --prompt-file "$pf" 2>&1 | ForEach-Object {
                $_ | Out-File -FilePath "$lf" -Encoding UTF8 -Append
            }
            $LASTEXITCODE
        } -ArgumentList $PromptFile, $LogFile, $WorkDir, $Round, $Iteration

        Write-Host "Devin lanzado en background job (Id $($job.Id)). Watchdog activo..."

        $lastLogSize = 0
        $lastActivity = Get-Date
        $idleThreshold = 120  # 120s sin output nuevo → asumir hung (devin a veces tarda en arrancar)

        while ($job.State -eq 'Running') {
            Start-Sleep -Seconds 3
            # Stream contenido nuevo del log a la consola
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
            # Watchdog: matar si idle demasiado tiempo
            $idleSecs = [int]((Get-Date) - $lastActivity).TotalSeconds
            if ($idleSecs -gt $idleThreshold) {
                Write-Host ""
                Write-Host "[Watchdog] Devin sin output por ${idleSecs}s (>$idleThreshold). Asumiendo terminado. Matando job..."
                Stop-Job $job -ErrorAction SilentlyContinue
                break
            }
        }

        # Stream final: cualquier output que quedo en el log
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

        # Obtener exit code del job
        $ec = 0
        try {
            $results = Receive-Job $job -ErrorAction SilentlyContinue
            if ($results -and $results.Count -gt 0) {
                $ec = [int]$results[-1]
            }
        } catch { }
        Remove-Job $job -Force -ErrorAction SilentlyContinue

        # ---- Cleanup: matar procesos devin huerfanos del job ----
        # Stop-Job/Remove-Job matan el PowerShell del job pero NO siempre
        # matan a devin.exe (child process). Si devin se colgó (root cause
        # original), sigue vivo consumiendo RAM y bloqueando sesiones
        # futuras. Buscamos y matamos cualquier devin.exe con --prompt-file
        # que sea hijo de un job PowerShell ya muerto.
        try {
            Get-CimInstance Win32_Process -Filter "Name='devin.exe'" -ErrorAction SilentlyContinue |
                Where-Object { $_.CommandLine -match 'prompt-file' } |
                ForEach-Object {
                    $parent = Get-Process -Id $_.ParentProcessId -ErrorAction SilentlyContinue
                    if (-not $parent) {
                        Write-Host "[Cleanup] Matando devin huerfano PID $($_.ProcessId) (parent ya muerto)"
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
