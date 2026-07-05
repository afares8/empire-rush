# run_overnight.ps1 - Controlador del overnight de Empire Rush.
#
# LOOP INFINITO (igual que D:\tec\overnight\run_overnight.ps1):
#   - Cada "ciclo" = N rondas (default 5) + 1 fine-tuning en la ultima
#     ronda del ciclo.
#   - Al terminar el ciclo, vuelve a empezar automaticamente (ciclo 2,
#     ciclo 3, ...). Se detiene SOLO con Ctrl+C en la ventana del
#     controlador.
#   - Cada ronda tiene un numero global unico (ronda 1, 2, 3, ... sin
#     resetear entre ciclos) para que logs/snapshots/branches no
#     colisionen.
#   - Fine-tuning SOLO en la ultima ronda de cada ciclo (default ronda
#     5, 10, 15, ...). El fine-tuning analiza las ultimas N rondas,
#     extrae lecciones, actualiza LEARNINGS.md y produce/actualiza
#     FINAL_REPORT.md.
#   - Auto-merge por ronda (commitea + PR + merge a main) igual que el
#     original.
#   - Timeout por sesion: 90 min (igual que D:\tec\overnight).
#
# Uso:
#   powershell -NoProfile -ExecutionPolicy Bypass -File run_overnight.ps1
#   powershell -NoProfile -ExecutionPolicy Bypass -File run_overnight.ps1 -RoundsPerCycle 5 -IterationsPerRound 1 -PauseSeconds 30
#   powershell -NoProfile -ExecutionPolicy Bypass -File run_overnight.ps1 -AutoMerge:$false
#
# Para detener: Ctrl+C en la ventana del controlador.

param(
    [int]$RoundsPerCycle          = 5,
    [int]$IterationsPerRound      = 1,
    [int]$PauseSeconds            = 30,
    [int]$SessionTimeoutMinutes   = 45,
    [string]$WorkDir              = "D:\empire-rush",
    [string]$PromptFile           = "",
    [string]$FinetunePromptFile   = "",
    [bool]$AutoMerge              = $true
)

$scriptDir         = Split-Path -Parent $MyInvocation.MyCommand.Path
$promptFile        = if ([string]::IsNullOrWhiteSpace($PromptFile))         { Join-Path $scriptDir "prompt.txt" }            else { $PromptFile }
$finetunePrompt    = if ([string]::IsNullOrWhiteSpace($FinetunePromptFile)) { Join-Path $scriptDir "finetune_prompt.txt" }  else { $FinetunePromptFile }
$sessionPs1        = Join-Path $scriptDir "session.ps1"
$finetunePs1       = Join-Path $scriptDir "finetune.ps1"
$logDir            = Join-Path $scriptDir "logs"
New-Item -ItemType Directory -Force -Path $logDir | Out-Null

# ---- Guard anti-duplicado ----
$expectedParent = Split-Path -Parent $scriptDir
$workDirReal    = if (Test-Path $WorkDir) { (Resolve-Path $WorkDir).Path } else { $WorkDir }
$expectedReal   = if (Test-Path $expectedParent) { (Resolve-Path $expectedParent).Path } else { $expectedParent }
if ($workDirReal -ne $expectedReal) {
    Write-Host "==============================================================" -ForegroundColor Red
    Write-Host " ERROR: Controller lanzado desde el directorio equivocado." -ForegroundColor Red
    Write-Host "        Script dir : $scriptDir" -ForegroundColor Red
    Write-Host "        WorkDir     : $WorkDir" -ForegroundColor Red
    Write-Host "        Esperado    : $expectedParent" -ForegroundColor Red
    Write-Host " Lanza desde: $expectedParent\overnight\run_overnight.ps1" -ForegroundColor Yellow
    Write-Host "==============================================================" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $promptFile))      { Write-Error "Falta prompt.txt en $scriptDir"; exit 1 }
if (-not (Test-Path $finetunePrompt))  { Write-Error "Falta finetune_prompt.txt en $scriptDir"; exit 1 }
if (-not (Test-Path $sessionPs1))      { Write-Error "Falta session.ps1 en $scriptDir"; exit 1 }
if (-not (Test-Path $finetunePs1))     { Write-Error "Falta finetune.ps1 en $scriptDir"; exit 1 }
if (-not (Test-Path $WorkDir))         { Write-Error "No existe el directorio de trabajo: $WorkDir"; exit 1 }

function Stop-ProcessTree([int]$rootPid) {
    if ($rootPid -le 0) { return }
    try {
        $toKill = @($rootPid)
        $queue = New-Object System.Collections.Generic.Queue[int]
        $queue.Enqueue($rootPid)
        while ($queue.Count -gt 0) {
            $cur = $queue.Dequeue()
            $children = Get-CimInstance Win32_Process -Filter "ParentProcessId=$cur" -ErrorAction SilentlyContinue
            foreach ($c in $children) {
                $toKill += $c.ProcessId
                $queue.Enqueue($c.ProcessId)
            }
        }
        foreach ($p in $toKill) {
            try { Stop-Process -Id $p -Force -ErrorAction SilentlyContinue } catch {}
        }
        Write-Host "  Arbol de procesos matado (raiz PID $rootPid, $($toKill.Count) procesos)."
    } catch {
        Write-Host "  No se pudo matar el arbol PID $rootPid : $_"
    }
}

function Invoke-AutoMerge([int]$round, [string]$workDir, [string]$roundStartCommit, [bool]$isFinetuneRound) {
    $origBranch   = "main"
    $branchCreated = $false
    $committed     = $false
    Push-Location $workDir
    try {
        $origBranch = (& git branch --show-current 2>&1).Trim()
        if ([string]::IsNullOrWhiteSpace($origBranch)) { $origBranch = "main" }

        $ghOk = $true
        try { $null = & gh --version 2>&1 } catch { $ghOk = $false }
        if (-not $ghOk) {
            Write-Host "  [AutoMerge] gh CLI no disponible. Saltando auto-merge."
            Write-Host "  [AutoMerge] Los cambios quedan en el arbol para commit manual."
            return
        }

        # Verifica si hay remote origin configurado
        $hasRemote = $false
        try {
            $remotes = & git remote 2>&1
            if ($remotes -match "origin") { $hasRemote = $true }
        } catch {}

        $status = & git status --porcelain 2>&1
        if (-not [string]::IsNullOrWhiteSpace($status)) {
            & git add -A 2>&1 | ForEach-Object { Write-Host $_ }
            if ($LASTEXITCODE -ne 0) {
                Write-Host "  [AutoMerge] git add -A fallo. Abortando."
                return
            }
            $leftoverMsg = "overnight: ronda $round - cambios finales"
            & git commit -m $leftoverMsg --no-verify 2>&1 | ForEach-Object { Write-Host $_ }
            if ($LASTEXITCODE -ne 0) {
                Write-Host "  [AutoMerge] git commit (leftover) fallo. Abortando."
                return
            }
            $committed = $true
        }

        $aheadCount = 0
        try {
            $aheadOut = & git rev-list --count "$roundStartCommit..HEAD" 2>&1
            if ($LASTEXITCODE -eq 0) {
                $aheadCount = [int]($aheadOut | Select-Object -Last 1).Trim()
            }
        } catch {}

        if ($aheadCount -le 0 -and -not $committed) {
            Write-Host "  [AutoMerge] No hay cambios ni commits nuevos. Saltando."
            return
        }

        $stamp  = Get-Date -Format "yyyyMMdd_HHmmss"
        $date   = Get-Date -Format "yyyy-MM-dd HH:mm"
        $branch = "overnight/r${round}_${stamp}"

        Write-Host "  [AutoMerge] Cambios detectados ($aheadCount WIP + leftover=$committed). Branch $branch..."

        & git checkout -b $branch 2>&1 | ForEach-Object { Write-Host $_ }
        if ($LASTEXITCODE -ne 0) { throw "git checkout -b fallo" }
        $branchCreated = $true

        if ($aheadCount -gt 0) {
            $commitMsg = @"
overnight: ronda $round ($date)

Cambios acumulados de $IterationsPerRound iteraciones de build.
Ver overnight/snapshots/ para detalle por iteracion.
Ver overnight/LEARNINGS.md para lecciones extraidas (ronda 5).

Generated with [Devin](https://cli.devin.ai/docs)

Co-Authored-By: Devin <158243242+devin-ai-integration[bot]@users.noreply.github.com>
"@
            & git reset --soft $roundStartCommit 2>&1 | ForEach-Object { Write-Host $_ }
            if ($LASTEXITCODE -eq 0) {
                & git commit -m $commitMsg 2>&1 | ForEach-Object { Write-Host $_ }
            }
        }

        if (-not $hasRemote) {
            Write-Host "  [AutoMerge] No hay remote 'origin'. Commits quedan en branch local $branch."
            Write-Host "  [AutoMerge] Para mergear manualmente: git checkout main && git merge $branch"
            return
        }

        $pushOk = $false
        for ($attempt = 1; $attempt -le 3; $attempt++) {
            Write-Host "  [AutoMerge] Push (intento $attempt/3)..."
            & git push -u origin $branch 2>&1 | Out-Host
            if ($LASTEXITCODE -eq 0) { $pushOk = $true; break }
            Start-Sleep -Seconds ($attempt * 10)
        }
        if (-not $pushOk) {
            Write-Host "  [AutoMerge] Push fallo. Cambios en branch local $branch."
            return
        }

        Write-Host "  [AutoMerge] Creando PR..."
        $prTitle = "Overnight Empire Rush ronda $round ($date)"
        $prBody = @"
## Resumen
Cambios acumulados de la ronda $round del overnight de Trade Empire Rush.

### Detalle
- Ver \`overnight/snapshots/\` para el detalle de cada iteracion.
- Ver \`overnight/LEARNINGS.md\` para las lecciones (ronda 5).
$(if ($isFinetuneRound) { "- Ver ``overnight/FINAL_REPORT.md`` para el informe final de mejoras y proximos pasos." })
### Para revertir
\`\`\`
git revert -m 1 <merge-commit-sha>
\`\`\`

Generated with [Devin](https://cli.devin.ai/docs)
"@
        $prOut = & gh pr create --title $prTitle --body $prBody --base $origBranch --head $branch 2>&1
        $prOut | Out-Host
        if ($LASTEXITCODE -ne 0) {
            Write-Host "  [AutoMerge] gh pr create fallo. Cambios en branch $branch."
            return
        }

        $prUrl = ($prOut | Where-Object { $_ -match 'pull' } | Select-Object -Last 1).Trim()
        $prNumber = ""
        if ($prUrl -match '/pull/(\d+)') { $prNumber = $Matches[1] }

        if ($prNumber) {
            Write-Host "  [AutoMerge] Mergendo PR #$prNumber a $origBranch..."
            & gh pr merge $prNumber --merge --delete-branch 2>&1 | Out-Host
            if ($LASTEXITCODE -ne 0) {
                Write-Host "  [AutoMerge] gh pr merge fallo. PR #$prNumber queda abierto."
                return
            }
            Write-Host "  [AutoMerge] PR #$prNumber mergeado a $origBranch."
        }

        & git checkout $origBranch 2>&1 | Out-Null
        & git pull origin $origBranch 2>&1 | Out-Host
        Write-Host "  [AutoMerge] Listo. $origBranch actualizado."
    }
    catch {
        Write-Host "  [AutoMerge] ERROR inesperado: $_"
    }
    finally {
        try {
            $curBranch = (& git branch --show-current 2>&1).Trim()
            if ($curBranch -ne $origBranch) {
                $curStatus = & git status --porcelain 2>&1
                if (-not [string]::IsNullOrWhiteSpace($curStatus)) {
                    & git reset --mixed 2>&1 | Out-Null
                }
                & git checkout $origBranch 2>&1 | Out-Null
            }
        } catch {
            Write-Host "  [AutoMerge] WARN: no se pudo restaurar $($origBranch): $_"
        }
        Pop-Location
    }
}

function Save-IterationWork([int]$round, [int]$iter, [string]$workDir) {
    Push-Location $workDir
    try {
        $status = & git status --porcelain 2>&1
        if ([string]::IsNullOrWhiteSpace($status)) {
            Write-Host "  [SaveIter] Ronda $round iter ${iter}: sin cambios nuevos. Skip WIP commit."
            return
        }
        & git add -A 2>&1 | ForEach-Object { Write-Host $_ }
        if ($LASTEXITCODE -ne 0) {
            Write-Host "  [SaveIter] git add -A fallo. NO se hizo WIP commit."
            return
        }
        $msg = "overnight: ronda $round iter $iter (WIP)"
        & git commit -m $msg --no-verify 2>&1 | ForEach-Object { Write-Host $_ }
        if ($LASTEXITCODE -ne 0) {
            Write-Host "  [SaveIter] git commit fallo. El trabajo queda staged."
            return
        }
        Write-Host "  [SaveIter] WIP commit creado (ronda $round iter $iter)."
    }
    catch {
        Write-Host "  [SaveIter] WARN: $_"
    }
    finally {
        Pop-Location
    }
}

function Reset-FailedIteration([string]$workDir) {
    Push-Location $workDir
    try {
        Write-Host "  [Reset] Limpiando arbol tras timeout (HEAD = ultimo WIP commit)..."
        & git reset --hard HEAD 2>&1 | Out-Host
        & git clean -fd 2>&1 | Out-Host
        Write-Host "  [Reset] Arbol restaurado a HEAD."
    }
    catch {
        Write-Host "  [Reset] WARN: no se pudo limpiar el arbol: $_"
    }
    finally {
        Pop-Location
    }
}

function Invoke-Session([string]$script, [hashtable]$extraArgs, [string]$label, [int]$timeoutMin) {
    $stamp      = Get-Date -Format "yyyyMMdd_HHmmss"
    $logFile    = $extraArgs['LogFile']
    if ([string]::IsNullOrWhiteSpace($logFile)) {
        $logFile = Join-Path $logDir "${label}_${stamp}.log"
    } else {
        $logDir2  = Split-Path -Parent $logFile
        $logBase  = [System.IO.Path]::GetFileNameWithoutExtension($logFile)
        $logFile  = Join-Path $logDir2 "${logBase}_${stamp}.log"
    }
    $extraArgs['LogFile'] = $logFile

    $doneMarker = $extraArgs['DoneMarker']
    if ([string]::IsNullOrWhiteSpace($doneMarker)) {
        $doneMarker = Join-Path $logDir "done_${label}_${stamp}.marker"
    }
    if (Test-Path $doneMarker) {
        try { Remove-Item $doneMarker -Force -ErrorAction Stop } catch {
            $staleBackup = "$doneMarker.stale_$(Get-Date -Format 'yyyyMMddHHmmss')"
            try { Move-Item $doneMarker $staleBackup -Force -ErrorAction Stop } catch {}
        }
    }

    $t0 = Get-Date
    Write-Host "[$($t0.ToString('HH:mm:ss'))] Abriendo ventana para $label (bypass, print)..."

    $procArgs = @(
        "-NoExit",
        "-ExecutionPolicy", "Bypass",
        "-NoProfile",
        "-File", $script
    )
    foreach ($k in $extraArgs.Keys) {
        $procArgs += "-$k"
        $procArgs += "$($extraArgs[$k])"
    }
    $proc = Start-Process powershell -PassThru -ArgumentList $procArgs
    $rootPid = if ($proc) { $proc.Id } else { 0 }

    Write-Host "[$($t0.ToString('HH:mm:ss'))] Ventana lanzada (PID $rootPid). Esperando $label..."
    $timeoutSec = $timeoutMin * 60
    $waited = 0
    $timedOut = $false
    $markerFound = $false
    while (-not $markerFound) {
        Start-Sleep -Seconds 10
        $waited += 10
        Write-Host ("`r  esperando... {0}s (timeout {1}s)   " -f $waited, $timeoutSec) -NoNewline
        if ($waited -ge $timeoutSec) { $timedOut = $true; break }
        if (Test-Path $doneMarker) {
            $markerTime = (Get-Item $doneMarker).LastWriteTime
            if (($markerTime - $t0).TotalMilliseconds -ge 100) {
                $markerFound = $true
            }
        }
    }
    Write-Host ""

    if ($timedOut) {
        Write-Host "[$((Get-Date).ToString('HH:mm:ss'))] TIMEOUT: $label excedio $timeoutMin min. Matando arbol..."
        Stop-ProcessTree $rootPid
        try { Set-Content -LiteralPath $doneMarker -Value "TIMEOUT at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -Encoding UTF8 -Force } catch {}
        try {
            $timeoutLine = "`n`n[CONTROLLER-TIMEOUT $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $label excedio $timeoutMin min."
            if (Test-Path $logFile) {
                Add-Content -LiteralPath $logFile -Value $timeoutLine -Encoding UTF8
            } else {
                Set-Content -LiteralPath $logFile -Value $timeoutLine -Encoding UTF8 -Force
            }
        } catch {}
    }

    $t1 = Get-Date
    $dur = ($t1 - $t0)
    $durStr = "{0}h {1}m {2}s" -f $dur.Hours, $dur.Minutes, $dur.Seconds
    $markerContent = ""
    if (Test-Path $doneMarker) { $markerContent = (Get-Content -LiteralPath $doneMarker -Raw -ErrorAction SilentlyContinue) }
    Write-Host "[$($t1.ToString('HH:mm:ss'))] $label finalizado (duracion $durStr). Marker: $markerContent"
    Write-Host "    Log: $logFile"
    return -not $timedOut
}

# ------------------------------------------------------------------
# Cuerpo principal: LOOP INFINITO de ciclos.
# Cada ciclo = N rondas + 1 fine-tuning en la ultima ronda del ciclo.
# Al terminar el ciclo, vuelve a empezar automaticamente.
# Se detiene SOLO con Ctrl+C en la ventana del controlador.
# ------------------------------------------------------------------
$controllerStart = Get-Date
Write-Host "=========================================================="
Write-Host " Devin Overnight Controller - EMPIRE RUSH (LOOP INFINITO)"
Write-Host "----------------------------------------------------------"
Write-Host " Rondas por ciclo       : $RoundsPerCycle"
Write-Host " Iteraciones por ronda  : $IterationsPerRound"
Write-Host " Fine-tuning en ronda   : $RoundsPerCycle de cada ciclo (5, 10, 15, ...)"
Write-Host " Pausa                  : $PauseSeconds s entre sesiones"
Write-Host " Timeout por sesion     : $SessionTimeoutMinutes min"
Write-Host " Directorio             : $WorkDir"
Write-Host " Prompt build           : $promptFile"
Write-Host " Prompt fine-tuning     : $finetunePrompt"
Write-Host " Auto-merge             : $AutoMerge"
Write-Host " Logs                   : $logDir"
Write-Host " Inicio                 : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host " >>> Para detener: Ctrl+C en esta ventana <<<"
Write-Host "=========================================================="
Write-Host ""

$globalRound = 0
$ciclo = 0

while ($true) {
    $ciclo++
    $cicloStart = Get-Date
    Write-Host "##########################################################"
    Write-Host "## CICLO $ciclo  (inicio $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))"
    Write-Host "## $RoundsPerCycle rondas + fine-tuning en la ultima"
    Write-Host "##########################################################"
    Write-Host ""

    for ($i = 1; $i -le $RoundsPerCycle; $i++) {
        $globalRound++
        $round = $globalRound
        $roundStart = Get-Date
        $isLastOfCycle = ($i -eq $RoundsPerCycle)
        Write-Host "##########################################################"
        Write-Host "## RONDA $round  (ciclo $ciclo, ronda $i/$RoundsPerCycle)  (inicio $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))"
        Write-Host "##########################################################"
        Write-Host ""

        # ---- Fase 0: sync con origin/main (si hay remote) ----
        Push-Location $WorkDir
        try {
            $hasRemote = $false
            try { $remotes = & git remote 2>&1; if ($remotes -match "origin") { $hasRemote = $true } } catch {}
            if ($hasRemote) {
                Write-Host "  [Fase 0] Sincronizando con origin/main..."
                & git fetch origin main 2>&1 | ForEach-Object { Write-Host "    $_" }
                $mergeOut = & git merge origin/main --no-edit 2>&1
                $mergeExit = $LASTEXITCODE
                $mergeOut | ForEach-Object { Write-Host "    $_" }
                if ($mergeExit -ne 0) {
                    Write-Host "  [Fase 0] Merge con origin/main tuvo conflictos. Abortando merge."
                    & git merge --abort 2>&1 | Out-Null
                }
            }
        } catch {
            Write-Host "  [Fase 0] WARN: $_"
        }
        finally { Pop-Location }

        # ---- Fase 1: N iteraciones de build ----
        Push-Location $WorkDir
        try { $roundStartCommit = (& git rev-parse HEAD 2>&1).Trim() } catch { $roundStartCommit = "" }
        finally { Pop-Location }
        Write-Host "  [Fase 1] Baseline de ronda: $roundStartCommit"

        $roundHadTimeout = $false
        for ($it = 1; $it -le $IterationsPerRound; $it++) {
            $label = "r${round}_iter_${it}"
            Write-Host "[$((Get-Date).ToString('HH:mm:ss'))] === Ronda $round - Iteracion $it / $IterationsPerRound ==="
            $ok = Invoke-Session -script $sessionPs1 `
                -extraArgs @{ Iteration = $it; Round = $round; WorkDir = $WorkDir; PromptFile = $promptFile; LogFile = (Join-Path $logDir "${label}.log"); DoneMarker = (Join-Path $logDir "done_${label}.marker") } `
                -label $label -timeoutMin $SessionTimeoutMinutes

            if ($ok) {
                Save-IterationWork -round $round -iter $it -workDir $WorkDir
            } else {
                Write-Host "  [Fase 1] Sesion fallo. Reseteando arbol a ultimo WIP commit..."
                Reset-FailedIteration -workDir $WorkDir
                $roundHadTimeout = $true
            }

            if ($it -lt $IterationsPerRound) {
                Write-Host "Pausando $PauseSeconds segundos..."
                Start-Sleep -Seconds $PauseSeconds
                Write-Host ""
            }
        }

        # ---- Fase 2: fine-tuning SOLO en la ultima ronda del ciclo ----
        $ftOk = $false
        if ($isLastOfCycle) {
            Write-Host ""
            Write-Host "[$((Get-Date).ToString('HH:mm:ss'))] === Ronda $round - FINE-TUNING (fin del ciclo $ciclo, analisis de las $RoundsPerCycle rondas) ==="
            $ftLabel = "r${round}_finetune"
            $ftLog   = Join-Path $logDir "${ftLabel}.log"
            $ftMark  = Join-Path $logDir "done_${ftLabel}.marker"
            $ftOk = Invoke-Session -script $finetunePs1 `
                -extraArgs @{ Round = $round; WorkDir = $WorkDir; PromptFile = $finetunePrompt; LogFile = $ftLog; DoneMarker = $ftMark; LogDir = $logDir } `
                -label $ftLabel -timeoutMin $SessionTimeoutMinutes

            if (-not $ftOk) {
                Write-Host "  [Fase 2] Fine-tuning fallo. Reseteando arbol a ultimo WIP commit..."
                Reset-FailedIteration -workDir $WorkDir
            }
        } else {
            Write-Host "  [Fase 2] Ronda $i < $($RoundsPerCycle): fine-tuning se salta (solo en la ultima ronda del ciclo)."
        }

        # ---- Fase 3: auto-merge por PR ----
        if ($AutoMerge) {
            Write-Host ""
            Write-Host "[$((Get-Date).ToString('HH:mm:ss'))] === Ronda $round - AUTO-MERGE ==="
            try {
                Invoke-AutoMerge -round $round -workDir $WorkDir -roundStartCommit $roundStartCommit -isFinetuneRound $isLastOfCycle
            }
            catch {
                Write-Host "  [AutoMerge] FALLO GRAVE: $_"
            }
        }

        $roundDur = (Get-Date) - $roundStart
        $roundDurStr = "{0}h {1}m {2}s" -f $roundDur.Hours, $roundDur.Minutes, $roundDur.Seconds
        Write-Host ""
        Write-Host "[$((Get-Date).ToString('HH:mm:ss'))] Ronda $round completada (duracion $roundDurStr, timeout=$roundHadTimeout, finetune=$($isLastOfCycle -and $ftOk))."
        if (-not $isLastOfCycle) {
            Write-Host "Pausando $PauseSeconds segundos antes de la siguiente ronda..."
            Start-Sleep -Seconds $PauseSeconds
        }
        Write-Host ""
    }

    # ---- Fin del ciclo: resumen + pausa antes del siguiente ciclo ----
    $cicloDur = (Get-Date) - $cicloStart
    $cicloDurStr = "{0}h {1}m {2}s" -f $cicloDur.Hours, $cicloDur.Minutes, $cicloDur.Seconds
    Write-Host "=========================================================="
    Write-Host " CICLO $ciclo COMPLETADO (duracion $cicloDurStr)"
    Write-Host "----------------------------------------------------------"
    Write-Host " Rondas ejecutadas: $RoundsPerCycle (rondas globales $(($ciclo-1)*$RoundsPerCycle+1) a $($ciclo*$RoundsPerCycle))"
    Write-Host " Fine-tuning: $(if ($ftOk) { 'OK' } else { 'FAIL/SKIP' })"
    $finalReport = Join-Path $scriptDir "FINAL_REPORT.md"
    if (Test-Path $finalReport) {
        Write-Host " Informe final actualizado: $finalReport" -ForegroundColor Green
        Write-Host " >>> LEE overnight\FINAL_REPORT.md <<<" -ForegroundColor Yellow
    }
    Write-Host " Logs en        : $logDir"
    Write-Host " Snapshots en   : $scriptDir\snapshots\"
    Write-Host " Lecciones en   : $scriptDir\LEARNINGS.md"
    Write-Host ""
    Write-Host " >>> REINICIANDO CICLO $($ciclo + 1) en $PauseSeconds segundos (Ctrl+C para detener) <<<" -ForegroundColor Cyan
    Write-Host "=========================================================="
    Start-Sleep -Seconds $PauseSeconds
    Write-Host ""
}

# ------------------------------------------------------------------
# Resumen final (solo se alcanza con Ctrl+C)
# ------------------------------------------------------------------
$totalDur = (Get-Date) - $controllerStart
$totalDurStr = "{0}h {1}m {2}s" -f $totalDur.Hours, $totalDur.Minutes, $totalDur.Seconds

Write-Host ""
Write-Host "=========================================================="
Write-Host " OVERNIGHT EMPIRE RUSH DETENIDO"
Write-Host "----------------------------------------------------------"
Write-Host " Ciclos completados : $ciclo"
Write-Host " Rondas totales     : $globalRound"
Write-Host " Duracion total     : $totalDurStr"
Write-Host " Fin                : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host " Logs en            : $logDir"
Write-Host " Snapshots en       : $scriptDir\snapshots\"
Write-Host " Lecciones en       : $scriptDir\LEARNINGS.md"
$finalReport = Join-Path $scriptDir "FINAL_REPORT.md"
if (Test-Path $finalReport) {
    Write-Host " Informe final      : $finalReport" -ForegroundColor Green
    Write-Host ""
    Write-Host " >>> LEE overnight\FINAL_REPORT.md para el informe de mejoras y proximos pasos <<<" -ForegroundColor Yellow
} else {
    Write-Host " Informe final      : (no se genero - revisa el log del fine-tuning)" -ForegroundColor Yellow
}
Write-Host "=========================================================="
Write-Host "=========================================================="
