# Trade Empire Rush — notas para agentes y equipo

## Stack

- **Engine**: Godot 4.3 (stable, standard = GDScript, NO .NET).
- **Lenguaje**: GDScript (no C#) para el MVP.
- **Export MVP**: HTML5 (web) — iteración rápida en navegador.
- **Export futuro**: Android → iOS (misma base de Godot).
- **Repo**: `D:\empire-rush` (git).

## Godot — instalación portable

Godot **no** está instalado globalmente en esta máquina. El primer
item del ROADMAP (`GODOT-1`) es descargar Godot 4.3 portable a
`D:\empire-rush\godot\godot.exe`.

Descarga recomendada (Godot 4.3 stable, Standard, Windows 64-bit):
- URL: `https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_win64.exe.zip`
- Es un .zip con un único .exe. Renombrar a `godot.exe` y poner en
  `D:\empire-rush\godot\`.
- **NO** instalar con installer: el portable es suficiente y no
  requiere admin.

Comandos Godot headless útiles:
```powershell
# Validar proyecto
D:\empire-rush\godot\godot.exe --headless --path D:\empire-rush --check-only
# Abrir editor (interactivo)
D:\empire-rush\godot\godot.exe --path D:\empire-rush
# Export HTML5 (requiere export_presets.cfg)
D:\empire-rush\godot\godot.exe --headless --path D:\empire-rush --export-release "HTML5" D:\empire-rush\exports\html5\index.html
# Correr el juego desde CLI
D:\empire-rush\godot\godot.exe --path D:\empire-rush
```

## Estructura del repo

```
D:\empire-rush\
  project.godot          # config del proyecto Godot
  BLUEPRINT.md           # diseño completo del juego (fuente de verdad del diseño)
  ROADMAP.md             # backlog priorizado (fuente de verdad de qué construir)
  AGENTS.md              # este archivo
  LEARNINGS.md           # memoria acumulativa del fine-tuning overnight
  README.md              # cómo usar el overnight
  .gitignore
  scenes/                # escenas Godot (.tscn)
    Main.tscn
    Player.tscn
    ...
  scripts/
    autoload/            # singletons (GameManager, Economy)
    game/                # lógica del juego (player, camera, npc, pickup, shelf, ...)
    ui/                  # HUD, menús, tienda, ranking
  assets/
    sprites/             # PNG/SVG placeholders
    audio/               # SFX/música placeholders
    fonts/
  exports/
    html5/               # output del export HTML5
  godot/
    godot.exe            # Godot portable (gitignored)
  overnight/
    prompt.txt           # prompt de build
    finetune_prompt.txt  # prompt de fine-tuning
    session.ps1          # una iteración de build
    finetune.ps1         # una sesión de fine-tuning
    run_overnight.ps1    # controlador (5 rondas, finetune en la 5ta)
    start.bat            # lanzador
    noop_guard.ps1       # guard contra iteraciones no-op
    logs/                # logs de cada sesión (gitignored)
    snapshots/           # snapshot por iteración
```

## Convenciones de código GDScript

- **Singletons** (autoloads): `GameManager` (estado global del juego,
  zonas, empleados) y `Economy` (cash, gems, empire_value,
  reputación). Definidos en `project.godot` `[autoload]`.
- **Nombres de archivos**: snake_case para `.gd` (ej:
  `game_manager.gd`), PascalCase para escenas y clases (ej:
  `Player.tscn`, `class_name Player`).
- **Señales**: declarar al top del script con `signal name(args)`.
- **Tipos**: usar tipado estático siempre (`var x: int = 0`,
  `func foo(a: float) -> void:`).
- **Comentarios**: en español, concisos. Solo el "por qué", no el
  "qué" (el código dice el qué).
- **NO agregar emojis** al código ni a la UI del juego salvo
  explícito.

## Loop adictivo — la regla de oro

El loop debe sentirse bien **cada 5–10 segundos**. Si una iteración
construye una feature pero el loop no se siente satisfactorio al
probarlo, la iteración NO está completa. Prioridad:

1. **Satisfacción táctil**: recoger dinero debe tener feedback
   visual + sonoro inmediato.
2. **Progreso visible**: cada acción cambia algo en pantalla.
3. **Meta cercana**: siempre hay un pad de desbloqueo a la vista.
4. **Crecimiento exponencial**: los números suben, se siente poder.

## Testing — cómo probar el MVP

No hay suite de tests unitarios tradicional para un juego Godot MVP.
La "verificación" de cada item es:

1. **Headless run**: `godot.exe --path D:\empire-rush` corre el
   juego. Si crashea al arrancar, el item falla.
2. **Export HTML5**: `godot.exe --headless --path D:\empire-rush
   --export-release "HTML5" exports/html5/index.html` debe generar
   `index.html` sin errores. Si el export falla, el item falla.
3. **Smoke manual**: abrir `exports/html5/index.html` en navegador
   (o el editor) y verificar el criterio de cierre del item.

Cada snapshot debe reportar: "Headless run OK", "Export HTML5 OK",
y el resultado del smoke del item cerrado.

## Anti-patrones (NO hacer)

- **No** agregar 10 features a medias. 1 feature completa > 10 a
  medias.
- **No** agregar contenido (capa 3) antes de que el loop (capa 2)
  funcione y se sienta bien.
- **No** agregar monetización real (IAP, ads reales) en el MVP —
  solo placeholders de UI.
- **No** agregar chat libre, violencia, contenido adulto, apuestas,
  ni loot boxes agresivas. Apto para todas las edades.
- **No** hacer el mapa gigante al principio. 1 mapa pequeño con 10
  zonas desbloqueables es el tope del MVP.
- **No** usar C# ni .NET para el MVP. GDScript puro.
- **No** instalar Godot con installer. Portable en `godot/`.
- **No** commitear `godot/godot.exe` ni `.godot/` (gitignored).
- **No** usar assets con licencia restrictiva. Placeholders
  ColorRect/Simple shapes son OK para el MVP.

## Progresión de capas (OBLIGATORIA)

El ROADMAP está ordenado por capas de cimiento → superficie. Si hay
items pendientes en la capa N, no toques la capa N+1 salvo que el
item de la N+1 destraba varios de la N (justifícalo en el snapshot).

1. **Capa 1 — Engine + proyecto base** (Godot instalado, proyecto
   válido, Main.tscn).
2. **Capa 2 — Loop base** (player, cámara, pickup, estante, cliente,
   dinero, pad, HUD, primer minuto).
3. **Capa 3 — Contenido MVP** (3 negocios + taller + almacén).
4. **Capa 4 — Automatización + upgrades + empleados**.
5. **Capa 5 — Eventos + ranking + monetización MVP + save + juice**.
6. **Capa 6 — Export HTML5 + landing + métricas**.

## Snapshot OBLIGATORIO en cada iteración

Escribe `overnight/snapshots/iter_<n>_<timestamp>.txt` al final de
CADA iteración, SIN EXCEPCIÓN. Si no escribes snapshot, la iteración
NO cuenta como completada (el noop_guard la marca como no-op).

Formato del snapshot:
```
# Snapshot — Iteración <n> (ronda <r>)
Fecha: <timestamp>
Item(s) trabajados: <IDs del ROADMAP>
Estado: <completado | en progreso | bloqueado>

## Cambios
- <archivo>: <qué cambió>

## Verificación
- Headless run: OK / FAIL
- Export HTML5: OK / FAIL / N/A
- Smoke del item: <resultado>

## Próximo item sugerido
<ID> — <título>
```
