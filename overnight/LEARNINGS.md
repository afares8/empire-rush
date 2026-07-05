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

## Ronda 2 (iter LOOP-3)

- **`class_name` cross-script NO se resuelve al parsear en algunos
  casos**: pickup.gd referenciaba `body is Player` pero Player
  (definido en player.gd) no estaba en scope al parsear → "Could
  not find type Player". Fix: duck-typing con `has_method(...)`.
  Evita `is TypeName` entre scripts del proyecto cuando hay riesgo
  de orden de carga; usa `has_method`/`get_class()`/nombre de nodo.
- **CharacterBody2D SIN CollisionShape2D no dispara `body_entered`
  en Area2D**: move_and_slide puede funcionar sin shape (o con
  warning), pero Area2D no detecta al body. Para cualquier nodo que
  deba ser detectado por Area2D (pickup, estante, pad), añadir
  CollisionShape2D al prefab.
- **`godot -s script.gd` NO carga autoloads**: Economy/GameManager
  no existen en ese modo, así que cualquier script que los referencie
  (como main.gd) falla al cargar. Para smoke tests de nodos del loop,
  instanciar los `.tscn` directamente (Player, Pickup) sin Main.gd,
  y usar `await physics_frame` (no `process_frame`) para señales
  físicas como body_entered.
- **`await physics_frame` > `await process_frame` para señales de
  física**: body_entered/body_exited y move_and_slide se resuelven
  en el step de física. process_frame puede no haber avanzado la
  física todavía.

## Ronda 1 (iter LOOP-5/LOOP-6)

- **`_physics_process` NO corre en headless `--quit-after`**: en
  Godot 4.3 headless con `--quit-after N`, solo `_process` se
  ejecuta, `_physics_process` nunca se llama. Esto invalida la
  lección anterior de Ronda 2 que decía que `--quit-after 60`
  validaba `_physics_process` — solo validaba que `_ready` no
  crasheara. Para nodos del loop que necesitan correr en headless
  (spawners, NPCs con movimiento directo), usar `_process`. Para
  nodos que usan `move_and_slide` (player), `_physics_process` es
  necesario pero no se puede testear en headless — testear en
  editor o navegador.
- **Headless `--quit-after` corre FPS sin cap → delta diminuto**:
  en headless mode, Godot no limita el FPS, así que cada frame
  tiene un delta muy pequeño (ej: 0.001s en vez de 0.0167s). Un
  timer basado en `delta` acumulado puede nunca llegar al umbral
  en `--quit-after N` frames. Fix: usar `Time.get_ticks_msec()`
  para tiempo real (wall-clock) en timers y movimiento de NPCs.
  Esto es robusto tanto en headless como en juego real.
- **`set_easing` no existe en Godot 4 — es `set_ease`**: 
  `PropertyTweener.set_easing()` → error "Nonexistent function".
  El método correcto es `set_ease(Tween.EASE_OUT)`. Verificar
  siempre los nombres de métodos de Tween contra la docs de Godot 4.
- **Area2D `body_entered` no fire en headless sin physics tick**:
  como `_physics_process` no corre, el mundo de física no hace
  step, y las señales `body_entered`/`body_exited` de Area2D nunca
  se disparan. El MoneyDrop (Area2D) no se puede testear headless.
  La colección de dinero se valida por lógica de código, no por
  smoke test headless. Para testear body_entered, usar script
  SceneTree con `await physics_frame` (que sí corre physics).
