# LEARNINGS — memoria acumulativa del fine-tuning overnight

> Lecciones accionables de cada ronda. Respeta cada una como
> restricción. Actualízalo al final de cada iteración con lo aprendido.

## Ronda 1

- **Godot 4.3 `--check-only` instancia autoloads y corre `_ready` de
  la main scene**: no es un check puramente estático. Sirve como
  verificación de boot sin crash, pero significa que un error en
  `_ready` aparece aquí. Útil como gate.
- **Godot portable en `godot/godot.exe`**: `--version` responde
  `4.3.stable.official.77dcf97d8`. NO commitear el .exe (gitignored).
- **Autoloads `Economy` y `GameManager`** ya están registrados en
  `project.godot`. Reutilizarlos; no crear singletons duplicados.
- **Inputs ya mapeados** en `project.godot`: `move_up/down/left/right`
  (WASD), `interact` (E), `pause` (ESC). Reutilizar; no redefinir.

## Ronda 2

- **`--quit-after <frames>`** es la forma limpia de correr headless y
  salir sin colgar el shell (mejor que `--check-only` que a veces
  deja el proceso corriendo si la main scene tiene `_process`).
- **ColorRect como placeholder visual**: usar `offset_left/top/
  right/bottom` para definir tamaño y posición centrada (más fiable
  que `size` + `position` que a veces se resetea al instanciar).
  Para nodos hijos de CharacterBody2D, el offset relativo al padre
  funciona bien.
- **CharacterBody2D + `move_and_slide`** para top-down sin gravedad:
  setear `velocity` directamente y llamar `move_and_slide()` en
  `_physics_process`. `Input.get_vector` ya normaliza si se le pasa
  a `move_toward` pero conviene normalizar diagonales a mano.
- **Animación placeholder sin sprites**: bob senoidal en `_physics_process`
  + squash/stretch con `create_tween()` al iniciar caminar da feel
  táctil sin assets. Frecuencia del bob escalada con velocidad
  actual/velocidad máx se siente natural.
- **Verificación de spawn en `_ready` de Main**: `get_node_or_null`
  + print confirma que la escena instanciada cargó sin errores de
  referencias (`@onready` fallaría ruidosamente si un hijo no existe).
- **M items = 1 por iteración**: respetar la regla. LOOP-1 solo,
  bien hecho, deja el árbol verde para LOOP-2/LOOP-3 la próxima.

## Ronda 1 (iter LOOP-2)

- **Camera2D + smoothing manual**: desactivar
  `position_smoothing_enabled` y hacer lerp exponencial a mano en
  `_physics_process` da control total sobre look-ahead. El smoothing
  built-in pelea con el offset manual.
- **`--quit-after 60` es el gate ideal para items con `_physics_process`**:
  corre 60 frames y sale limpio, valida que _ready + _physics_process
  no crashean sin colgar el shell.
- **Re-búsqueda de nodos en `_physics_process`**: si un nodo
  referenciado puede no estar en _ready (orden de carga), re-hacer
  `get_node_or_null` en _physics_process es barato y robusto.
- **Env vars vs ROADMAP pueden discrepar**: el controller puede
  reiniciar el contador de ronda. Siempre usar `DEVIN_OVERNIGHT_ROUND`
  / `DEVIN_OVERNIGHT_ITER` como fuente de verdad para el snapshot,
  no el número que dice el ROADMAP.
