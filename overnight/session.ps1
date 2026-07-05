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

        # ---- Watchdog: Start-Process con redirección + monitor de idle ----
        # Root cause del bug: devin.exe en modo -p a veces NO sale despues de
        # imprimir su resumen. El pipeline `& devin | ForEach-Object` se queda
        # bloqueado esperando que devin cierre stdout => el finally de
        # session.ps1 nunca se ejecuta => el marker nunca se crea => el
        # controller espera 90 min de timeout para matar el arbol.
        #
        # Fix: lanzar devin con Start-Process + -RedirectStandardOutput al log
        # file. Monitorear el tamaño del log file. Si devin no produce output
        # nuevo por N segundos (idle), asumir que termino y matarlo. Asi el
        # pipeline nunca se bloquea y el marker se crea inmediatamente.
        $errFile = [System.IO.Path]::ChangeExtension($LogFile, "err")
        $devinArgs = @(
            "--model", "glm-5.2",
            "--permission-mode", "dangerous",
            "-p",
            "--prompt-file", "`"$PromptFile`""
        )
        $devinProc = Start-Process -FilePath "devin" `
            -ArgumentList $devinArgs `
            -PassThru -NoNewWindow `
            -RedirectStandardOutput $LogFile `
            -RedirectStandardError $errFile

        $devinPid = $devinProc.Id
        Write-Host "Devin lanzado (PID $devinPid). Watchdog activo..."

        $lastLogSize = 0
        $lastActivity = Get-Date
        $idleThreshold = 60  # 60s sin output nuevo → asumir hung

        while (-not $devinProc.HasExited) {
            Start-Sleep -Seconds 3
            # Stream contenido nuevo del log a la consola
            if (Test-Path $LogFile) {
                try {
                    $currentSize = (Get-Item $LogFile).Length
                    if ($currentSize -gt $lastLogSize) {
                        # Hay output nuevo → reset idle timer
                        $lastActivity = Get-Date
                        # Leer y mostrar lineas nuevas
                        $allLines = Get-Content $LogFile -ErrorAction SilentlyContinue
                        if ($allLines) {
                            $linesSoFar = [int]($lastLogSize / 200)  # estimacion tosca
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
                Write-Host "[Watchdog] Devin sin output por ${idleSecs}s (>$idleThreshold). Asumiendo terminado. Matando PID $devinPid..."
                try { Stop-Process -Id $devinPid -Force -ErrorAction SilentlyContinue } catch {}
                Start-Sleep -Seconds 2
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

        $ec = if ($null -ne $devinProc.ExitCode) { $devinProc.ExitCode } else { 0 }
        # Si fue matado por watchdog (exit code negativo o null), tratar como exito
        # si produjo trabajo — el noop_guard lo verificara despues.
        if ($ec -lt 0 -or $null -eq $ec) { $ec = 0 }
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
