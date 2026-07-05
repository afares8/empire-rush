# Trade Empire Rush

> **"Empieza con nada. Construye un imperio."**
> Idle tycoon / management runner isométrico. MVP web (HTML5) → Android → iOS.
> Stack: **Godot 4.3** (GDScript) + export HTML5.

## Qué es esto

Este repo contiene el **proyecto Godot** del juego + el sistema
**overnight** que lo construye de forma autónoma en 5 rondas, con
fine-tuning en la 5ta ronda que produce un informe de mejoras y
próximos pasos.

El diseño completo del juego está en [`BLUEPRINT.md`](BLUEPRINT.md).
El backlog priorizado está en [`ROADMAP.md`](ROADMAP.md).
Las convenciones para agentes están en [`AGENTS.md`](AGENTS.md).

## Estructura

```
empire-rush/
  project.godot          # config Godot
  BLUEPRINT.md           # diseño completo del juego
  ROADMAP.md             # backlog priorizado por capas
  AGENTS.md              # convenciones Godot/GDScript + anti-patrones
  LEARNINGS.md           # memoria acumulativa del fine-tuning
  README.md              # este archivo
  scenes/                # escenas Godot (.tscn)
  scripts/               # GDScript (autoload, game, ui)
  assets/                # sprites, audio, fonts
  exports/html5/         # output del export HTML5
  godot/godot.exe        # Godot 4.3 portable (gitignored, lo baja la ronda 1)
  overnight/             # sistema overnight (ver overnight/README.md)
    prompt.txt
    finetune_prompt.txt
    session.ps1
    finetune.ps1
    run_overnight.ps1
    start.bat
    noop_guard.ps1
    logs/
    snapshots/
```

## Cómo lanzar el overnight

```bat
cd D:\empire-rush\overnight
start.bat
```

Esto corre **5 rondas** de build autónomo (1 iteración por ronda por
default) + fine-tuning en la 5ta ronda. Al final, lee
`overnight\FINAL_REPORT.md` para el informe de mejoras y próximos
pasos.

Para más opciones ver [`overnight/README.md`](overnight/README.md).

## Cómo probar el juego (después de las rondas)

```bat
:: Si el export HTML5 se generó:
start D:\empire-rush\exports\html5\index.html

:: Si prefieres el editor Godot:
D:\empire-rush\godot\godot.exe --path D:\empire-rush
```

## Estado

- **Ronda 0 (setup)**: esqueleto Godot + overnight listos. Sin código
  de juego todavía.
- **Rondas 1–5**: construidas por el overnight.
- **Fine-tuning (ronda 5)**: produce `FINAL_REPORT.md`.
