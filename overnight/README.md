# Trade Empire Rush — Overnight

Mini app de control que corre **5 rondas** de build autónomo sobre el
juego `D:\empire-rush` usando Devin en modo **bypass** (auto-aprueba
todas las herramientas) y modo **print** (no interactivo: hace el
trabajo y sale solo al terminar). En la **5ta ronda**, una sesión
extra de **fine-tuning** analiza los logs de las 5 rondas, extrae
lecciones, actualiza `LEARNINGS.md`, re-prioriza `ROADMAP.md` y
produce `overnight/FINAL_REPORT.md` con el informe de mejoras y
próximos pasos que el usuario pidió.

## Filosofía

Igual que el overnight de Magnate (`D:\tec\overnight`), pero adaptado
a un juego Godot:

1. **Cada ronda** = N iteraciones de build (default 1).
2. **Fine-tuning en la última ronda**: analiza los logs, extrae
   lecciones, append a `LEARNINGS.md`, re-prioriza `ROADMAP.md`, y
   produce `FINAL_REPORT.md` con "cómo puedo mejorar, qué más puedo
   hacer".
3. **Auto-merge por ronda**: commitea + PR + merge a `main` (si hay
   remote + gh). Revertible con `git revert -m 1 <sha>`.
4. **NO es loop infinito**: corre exactamente 5 rondas y sale. El
   usuario quería "5 rondas y a la quinta fine-tuning".

## Progresión por capas (prioridad del roadmap)

El roadmap está ordenado por **capas de cimiento → superficie**:

- **Capa 1 — Engine + proyecto base** (Godot instalado, project.godot,
  Main.tscn). Bloqueante para todo lo demás.
- **Capa 2 — Loop base** (player, cámara, pickup, estante, cliente,
  dinero, pad, HUD, primer minuto). El corazón adictivo.
- **Capa 3 — Contenido MVP** (3 negocios + taller + almacén).
- **Capa 4 — Automatización + upgrades + empleados**.
- **Capa 5 — Eventos + ranking + monetización MVP + save + juice**.
- **Capa 6 — Export HTML5 + landing + métricas**.

**Regla**: si hay items pendientes en la capa N, no se toca la capa
N+1 salvo que el item de la N+1 destraba varios de la N.

## Archivos

- `prompt.txt` — prompt de build (loop adictivo, capas, anti-patrones,
  entrega estructurada).
- `finetune_prompt.txt` — prompt del fine-tuning (analiza logs,
  extrae lecciones, actualiza LEARNINGS/ROADMAP, produce
  FINAL_REPORT.md).
- `session.ps1` — corre **una** iteración de build en ventana nueva,
  loguea, crea marker al terminar.
- `finetune.ps1` — corre **una** sesión de fine-tuning.
- `run_overnight.ps1` — controlador: 5 rondas + fine-tuning en la
  5ta + auto-merge + resumen final.
- `start.bat` — lanzador conveniente.
- `noop_guard.ps1` — guard contra iteraciones WIP no-op.
- `LEARNINGS.md` — memoria acumulativa del fine-tuning (append-only).
- `../BLUEPRINT.md` — diseño completo del juego.
- `../ROADMAP.md` — backlog priorizado por capas.
- `../AGENTS.md` — convenciones de Godot/GDScript y anti-patrones.
- `snapshots/` — un archivo por iteración (+ uno por fine-tuning).
- `logs/` — salida completa (stdout) de cada sesión de Devin.

## Uso

```bat
:: Defaults: 5 rondas, 1 iter/ronda, 30s pausa, auto-merge ON
start.bat

:: 5 rondas, 2 iter/ronda, 45s pausa
start.bat 5 2 45

:: 5 rondas, sin auto-merge (commits quedan en arbol para revisar)
powershell -NoProfile -ExecutionPolicy Bypass -File run_overnight.ps1 -AutoMerge:$false
```

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File run_overnight.ps1 -TotalRounds 5 -IterationsPerRound 1 -PauseSeconds 30 -WorkDir "D:\empire-rush"
```

## Salidas

- `logs\r<round>_iter_<n>_<timestamp>.log` — salida de cada iteración.
- `logs\r<round>_finetune_<timestamp>.log` — salida del fine-tuning.
- `logs\done_*.marker` — archivo que indica que la sesión terminó.
- `snapshots\iter_<n>_<timestamp>.txt` — snapshot de cada iteración.
- `snapshots\finetune_r<round>_<timestamp>.txt` — snapshot del
  fine-tuning.
- `LEARNINGS.md` — memoria acumulativa (append por ronda de
  fine-tuning).
- `FINAL_REPORT.md` — informe final con mejoras y próximos pasos
  (producido por el fine-tuning de la 5ta ronda).

## Revisión al terminar las 5 rondas

1. `cd D:\empire-rush && git log --oneline -20` — ver los merge
   commits de cada ronda.
2. `ls overnight\snapshots\` — ver snapshots de las 5 rondas.
3. Leer `overnight\FINAL_REPORT.md` — el informe final con:
   - Estado del MVP (qué se construyó, qué faltó).
   - ¿Es adictivo desde el primer minuto? (honesto).
   - Cómo puedo mejorar el MVP (recomendaciones accionables).
   - Qué más puedo hacer (roadmap a 1.0, 2.0, 3.0, mobile).
   - Métricas a medir desde el día 1.
   - Riesgos y mitigaciones.
   - Próximos pasos recomendados (esta semana).
4. Leer las secciones nuevas de `LEARNINGS.md`.
5. Probar el juego: abrir `exports/html5/index.html` en navegador (si
   el export se generó) o `D:\empire-rush\godot\godot.exe --path
   D:\empire-rush` en el editor.
6. Si una ronda rompió algo: `git revert -m 1 <merge-sha>`.

## Notas

- **NO es loop infinito**: corre 5 rondas y sale. Para correr más,
  lanzar de nuevo con `start.bat` (o cambiar `-TotalRounds`).
- **Fine-tuning solo en la última ronda**: las rondas 1–4 son puras
  de build. La ronda 5 es build + fine-tuning.
- **Auto-merge activado por defecto**: si hay remote `origin` y `gh`
  CLI, cada ronda queda como merge commit aislado y revertible. Sin
  remote, los commits quedan en branches locales.
- **Godot no está instalado**: la primera iteración de la ronda 1
  debe descargar Godot 4.3 portable a `D:\empire-rush\godot\godot.exe`
  (item GODOT-1 del ROADMAP). Es bloqueante.
- Modo `dangerous` auto-aprueba **todas** las herramientas.
- Si una sesión tarda mucho, el timeout (default 90 min) la mata y
  continúa con la siguiente.
