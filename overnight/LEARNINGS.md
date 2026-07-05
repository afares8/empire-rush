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

## Ronda 5 — Fine-tuning (2026-07-05 04:37)

### Resumen de las 5 rondas
- Items completados (y commiteados): 9 — GODOT-1/2/3, LOOP-1 a LOOP-6
- Items "completados" pero PERDIDOS por reset destructivo: 3 —
  LOOP-7, LOOP-8, LOOP-9 (r3, r4, r5 los hicieron pero el controller
  tiró el trabajo)
- Items no tocados: todos los de capas 3–6 (BIZ, AUTO, UPG, EVT,
  RNK, MON, SAVE, OFF, JUICE, EXP, MET)
- Export HTML5: FAIL — no existe `export_presets.cfg`, `exports/html5/`
  solo tiene `.gitkeep`
- Loop adictivo se siente: NO — falta HUD (cash invisible), falta pad
  de desbloqueo (no hay meta cercana), falta primer minuto guiado,
  falta juice, falta export jugable

### Lecciones de proceso
1. **CRÍTICO — `Reset-FailedIteration` destruye trabajo completado**:
   `git reset --hard HEAD` + `git clean -fd` borra TODO el trabajo
   de una sesión cuando el controller marca timeout, incluso si el
   devin YA terminó la feature. r3, r4, r5 hicieron LOOP-7/8/9 cada
   una (logs muestran resúmenes completos + "Iteration complete")
   pero el marker no se escribió a tiempo → timeout → reset →
   trabajo perdido. ~135 min de compute tirados. Fix: el controller
   debe hacer un WIP commit ANTES de reset (preservar trabajo), o
   mover `Reset-FailedIteration` a solo `git stash` + branch de
   rescate, NUNCA `git clean -fd` sobre archivos nuevos.
   Origen: logs r3/r4/r5 + `git log` (solo r1/r2 commiteados) +
   `ls scripts/ui/` (no existe) + ROADMAP (LOOP-7/8/9 siguen [ ]).

2. **El done-marker es frágil y no refleja "trabajo hecho"**:
   session.ps1 escribe el marker solo si `Test-IterationProducedWork`
   pasa (snapshot nuevo O ROADMAP cambiado). Pero el devin bufferiza
   output y el pipeline `& devin | ForEach-Object` se queda colgado
   esperando stdout incluso después de que devin terminó su tarea.
   El watchdog (idle 120s) debería matarlo pero a veces no detecta
   bien "terminó vs hung". Resultado: devin terminó, el marker no se
   escribió, el controller esperó 45 min y reseteó. Fix: escribir el
   marker desde DENTRO del prompt del devin (instrucción explícita:
   "al terminar, escribe el archivo $DEVIN_DONE_MARKER") en vez de
   depender del wrapper PowerShell que pelea con el buffer de devin.

3. **3 rondas repitieron el mismo item (LOOP-7) sin avanzar**:
   como cada reset volvía al commit r1, r3, r4 y r5 empezaron todas
   desde "LOOP-7 pendiente" y lo rehicieron desde cero. El ROADMAP
   no reflejaba el progreso real porque los cambios se perdían. Fix:
   el controller debe commitear WIP cada iteración (Save-IterationWork)
   ANTES de que el timeout dispare el reset, no después. Hoy
   Save-IterationWork solo corre si `$ok=true`, que es justo el caso
   que falla.

4. **Anti-patrón "devin huérfano concurrente" reccurió en r3**:
   un devin.exe de una sesión anterior seguía vivo ~2h editando los
   mismos archivos. El watchdog de session.ps1 agregó cleanup pero
   el problema se originó porque el controller anterior no mató bien
   el árbol. Lección ya estaba pero se repitió → el cleanup debe ser
   más agresivo al START de cada sesión (matar todos los devin.exe
   huérfanos antes de lanzar el nuevo).

5. **Snapshots no se commitearon en r3/r4/r5**:
   `overnight/snapshots/` solo tiene 4 archivos, todos de antes de
   01:35. Los snapshots que r3/r4/r5 dicen haber escrito fueron
   borrados por `git clean -fd` (eran untracked). El noop_guard
   entonces NO tenía forma de ver "trabajo nuevo" y posiblemente
   marcó las sesiones como no-op → marker no escrito → timeout →
   reset. Loop vicioso. Fix: commitear snapshots DENTRO del prompt
   del devin (git add + commit explícito al final), no depender del
   controller post-hoc.

### Lecciones técnicas
1. **`groups` override en .tscn no aplica a nodos instanciados**
   (Godot 4.3): ShelfC con `groups=["zone_market"]` nunca entraba
   al grupo. Fix: usar NodePath a contenedor Node2D + activar
   `visible`/`process_mode`. Origen: r3 log. (Ya en LEARNINGS pero
   confirmado por 2 rondas independientes.)

2. **`theme_override_colors/font_color = X` como assignment target
   falla al parsear**: usar `add_theme_color_override`. Origen: r4.

3. **Headless `--quit-after` sigue sin correr `_physics_process`**:
   confirmado por r3/r4/r5 — todos los smoke tests de LOOP-7 usan
   `try_unlock()` público en vez de simular input E (que requiere
   physics tick). Esta limitación es estable y hay que diseñar
   alrededor de ella: exponer API pública en cada nodo del loop
   para testear headless.

4. **No hay `export_presets.cfg` después de 5 rondas**: EXP-1 (capa
   6) nunca se tocó porque el overnight se quedó en capa 2. Sin
   export HTML5, el MVP no es jugable en navegador y no se puede
   hacer smoke visual. Fix: priorizar EXP-1 ANTES de seguir con
   capa 3 — el export debe existir desde que el loop base funciona
   para poder probar el "feel" en navegador.

### Lecciones de diseño
1. **El loop base NO se siente adictivo en el estado actual**:
   recoger→vender→cobrar funciona en headless, pero sin HUD el cash
   es invisible (violación §32 "dinero visible"), sin pad no hay
   meta cercana (violación §25 segundo 20–35 "invierte para crecer"),
   sin primer minuto guiado el jugador no sabe qué hacer (violación
   §25). El loop está "conectado" en código pero no "se siente" en
   juego. Veredicto: PARCIAL — la mecánica existe, el feel no.

2. **Falta juice es la brecha más grande hacia "adictivo"**:
   BLUEPRINT §32.1 exige "progreso visual inmediato" y §26 exige
   "cada 10 segundos pasa algo". Hoy recoger dinero no tiene
   partículas, sonido, ni fly-to-HUD (JUICE-1/POLISH-2 pendientes).
   El MoneyDrop solo tiene un pop-in tween. Esto es lo que más
   impacta la percepción de "satisfacción táctil" de la regla de
   oro del AGENTS.md.

3. **El MVP está a ~6–8 iter de ser "lanzado" en navegador**:
   LOOP-7/8/9 (3 iter, ya hechos 3 veces pero perdidos) + EXP-1
   (1–2 iter) + JUICE-1/POLISH-1/2 (2 iter) + balance/smoke visual
   (1 iter). Con el fix del reset destructivo, la próxima ronda
   podría cerrar el MVP jugable en 1 ciclo de 5 rondas.

4. **El timeout de 45 min es demasiado corto para items M**: cada
   ronda hizo solo 1 iteración y los items M (LOOP-7, LOOP-8) no
   alcanzaban a commitear. Subir a 90 min o reducir scope a items S
   por iteración. Origen: los 3 timeouts consecutivos r3/r4/r5.

5. **El gate entre capas es débil**: el prompt dice "no toques capa
   N+1 si capa N no está completa", pero el gate es solo "headless
   run OK". Falta un gate de "export HTML5 OK" + "smoke en navegador
   OK" antes de avanzar de capa. Sin esos gates, el overnight
   acumula deuda técnica invisible (features que funcionan en
   headless pero crashean en navegador). Origen: 5 rondas sin
   export HTML5.

