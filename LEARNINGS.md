# LEARNINGS — memoria acumulativa del fine-tuning

> Este archivo es append-only por ronda. La sesión de fine-tuning
> (ronda 5) extrae lecciones de las 5 rondas de build y las appende
> aquí. La siguiente ronda (si se corre otro overnight) lo lee antes
> de trabajar y es más inteligente.

## Ronda 0 — Setup inicial

- El proyecto arranca con esqueleto Godot + overnight listo. Sin
  código de juego todavía. La ronda 1 debe empezar por GODOT-1
  (descargar Godot portable) — sin Godot no se puede testear nada.
- Godot NO está instalado globalmente. El primer item del ROADMAP
  es bloqueante para todo lo demás.
- Stack confirmado: Godot 4.3 standard (GDScript), export HTML5
  para MVP, luego Android/iOS.
