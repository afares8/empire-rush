@echo off
REM ============================================================
REM  start.bat - Lanzador del Devin Overnight Controller (Empire Rush)
REM  Uso:
REM    start.bat                  -> 5 rondas, 1 iter/ronda, 30s pausa, auto-merge ON
REM    start.bat 5 1              -> 5 rondas, 1 iter/ronda, 30s pausa
REM    start.bat 5 1 45           -> 5 rondas, 1 iter/ronda, 45s pausa
REM    start.bat 5 1 45 "D:\empire-rush"  -> idem, directorio custom
REM  Fine-tuning: SOLO en la ultima ronda (ronda 5).
REM  Auto-merge: commitea + PR + merge a main por ronda (si hay remote + gh).
REM  NO es loop infinito: corre N rondas y sale.
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
echo  Devin Overnight Controller - EMPIRE RUSH
echo  --------------------------------------------
echo  Rondas totales    : %ROUNDS%
echo  Iteraciones/ronda : %ITERS%
echo  Pausa             : %PAUSE%s
echo  Directorio        : %WDIR%
echo  Fine-tuning       : en la ultima ronda (ronda %ROUNDS%)
echo  Auto-merge        : ON (si hay remote + gh)
echo  NO es loop infinito: corre %ROUNDS% rondas y sale.
echo.

if "%WDIR%"=="" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0run_overnight.ps1" -TotalRounds %ROUNDS% -IterationsPerRound %ITERS% -PauseSeconds %PAUSE%
) else (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0run_overnight.ps1" -TotalRounds %ROUNDS% -IterationsPerRound %ITERS% -PauseSeconds %PAUSE% -WorkDir "%WDIR%"
)

echo.
echo Controller finalizado. Presiona una tecla para cerrar.
pause >nul
