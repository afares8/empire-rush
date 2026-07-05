@echo off
REM ============================================================
REM  start.bat - Lanzador del Devin Overnight Controller (Empire Rush)
REM  LOOP INFINITO: 5 rondas + fine-tuning en la 5ta, luego reinicia.
REM  Uso:
REM    start.bat                  -> 5 rondas/ciclo, 1 iter/ronda, 30s pausa, auto-merge ON
REM    start.bat 5 1              -> 5 rondas/ciclo, 1 iter/ronda, 30s pausa
REM    start.bat 5 1 45           -> 5 rondas/ciclo, 1 iter/ronda, 45s pausa
REM    start.bat 5 1 45 "D:\empire-rush"  -> idem, directorio custom
REM  Fine-tuning: en la ultima ronda de cada ciclo (ronda 5, 10, 15, ...).
REM  Auto-merge: commitea + PR + merge a main por ronda (si hay remote + gh).
REM  LOOP INFINITO: al terminar el ciclo, reinicia automaticamente.
REM  Detener: Ctrl+C en la ventana del controlador.
REM ============================================================
setlocal

set ROUNDS=%1
set ITERS=%2
set PAUSE=%3
set WDIR=%4

if "%ROUNDS%"=="" set ROUNDS=5
if "%ITERS%"=="" set ITERS=1
if "%PAUSE%"=="" set PAUSE=30
if "%WDIR%"=="" set WDIR=D:\empire-rush

echo.
echo  Devin Overnight Controller - EMPIRE RUSH (LOOP INFINITO)
echo  --------------------------------------------
echo  Rondas por ciclo  : %ROUNDS%
echo  Iteraciones/ronda : %ITERS%
echo  Pausa             : %PAUSE%s
echo  Directorio        : %WDIR%
echo  Fine-tuning       : en la ultima ronda de cada ciclo (ronda %ROUNDS%, %ROUNDS%*2, ...)
echo  Auto-merge        : ON (si hay remote + gh)
echo  Timeout/sesion    : 90 min
echo  LOOP INFINITO     : al terminar el ciclo, reinicia automaticamente.
echo  Detener con Ctrl+C en esta ventana.
echo.

if "%WDIR%"=="" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0run_overnight.ps1" -RoundsPerCycle %ROUNDS% -IterationsPerRound %ITERS% -PauseSeconds %PAUSE%
) else (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0run_overnight.ps1" -RoundsPerCycle %ROUNDS% -IterationsPerRound %ITERS% -PauseSeconds %PAUSE% -WorkDir "%WDIR%"
)

echo.
echo Controller detenido (Ctrl+C). Presiona una tecla para cerrar.
pause >nul
