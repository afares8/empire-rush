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

## Ronda 8 — iter 1 (2026-07-05 06:14)

- **`main.gd` sobrevivió al reset de r7 pero las escenas/scripts nuevos
  no**: al iniciar r8, `scripts/ui/` no existía, `UnlockPad.tscn`/
  `HUD.tscn` no existían, pero `main.gd` YA tenía la verificación de
  HUD/MissionGuide/pads + el DEVIN_SMOKE pad test. Esto significa que
  el reset del controller no es totalmente destructivo — parece que
  solo borra archivos untracked NUEVOS, no los tracked modificados.
  Hipótesis: `git reset --hard HEAD` revierte tracked files pero
  `git clean -fd` borra untracked. Si main.gd fue editado (tracked),
  el reset lo revirtió... pero NO fue revertido aquí. Posible que r7
  sí commiteara main.gd en un WIP commit que luego se merged/kept.
  Lección: hacer commit temprano de archivos tracked modificados
  (main.gd, ROADMAP.md) para que sobrevivan resets; los archivos
  NUEVOS son los vulnerables.
- **`call_deferred` para setup de nodos que dependen de siblings**:
  MissionGuide necesita el HUD (sibling bajo Main). En _ready el orden
  de carga de siblings no está garantizado para @onready del otro.
  `call_deferred("_setup")` corre después de que todo el árbol _ready
  terminó → HUD ya está listo. Robusto y simple.
- **Signal `money_collected` en Economy**: para distinguir "ingreso
  por recoger dinero" de "gasto por desbloqueo" sin que MissionGuide
  avance en el beat equivocado. add_cash(amount>0) emite money_collected;
  spend_cash no. Reutilizable para JUICE-1 (fly-to-HUD solo al recoger).
- **Capa 2 cerrada en 1 iteración (LOOP-7/8/9 juntos)**: a pesar de
  que LOOP-7 es M, los 3 items comparten Main.tscn + verificación,
  hacerlos juntos es más eficiente que 3 iter separadas (r7 ya lo
  había demostrado antes del timeout). El timeout de 45 min sigue
  siendo el riesgo — esta iter completó en ~10 min de trabajo real.
- **Próximo bloqueante real: EXP-1 (export HTML5)**. Sin export, todo
  el smoke sigue siendo headless y no valida feel. EXP-1 debe ser el
  siguiente item P0 antes de capa 3.

## Ronda 10 — Fine-tuning (2026-07-05 07:50)

### Resumen de las rondas 6–10
- Items completados Y commiteados: 0 nuevos (r8 ya estaba commiteado
  desde antes; r6/r7/r9/r10 se perdieron por timeout+reset)
- Items "completados" pero PERDIDOS por reset destructivo: 4 —
  BIZ-1 (r9), BIZ-1/BIZ-2/BIZ-3 (r10). El anti-patrón
  `Reset-FailedIteration` de LEARNINGS r5 lección 1 SIGUE ACTIVO:
  3 de 5 rondas (r6, r9, r10) tuvieron su trabajo completado
  destruido por el controller timeout+reset. La lección r5 NO fue
  aplicada al controller.
- Items no tocados: BIZ-4, BIZ-5, toda capa 4 (AUTO/UPG/EMP),
  toda capa 5 (EVT/RNK/MON/SAVE/OFF/JUICE), toda capa 6 (EXP-2/MET)
- Export HTML5: OK — `exports/html5/index.html` + index.pck (62KB)
  + index.wasm (35MB) generados y commiteados en r8. Headless run
  OK verificado en este fine-tuning (2026-07-05 07:50): Player,
  2 Pickups, 2 Shelves, ClientSpawner, HUD, MissionGuide, 2 Pads
  cargan sin crashes.
- Loop adictivo se siente: PARCIAL — el cimiento está verde y
  jugable en navegador, pero sin juice, sin contenido (solo 2
  pickups/2 shelves, no 3 negocios), sin empleados, sin eventos,
  sin balance. El primer minuto guiado (MissionGuide) existe en
  código pero no validado en navegador.

### Lecciones de proceso
1. **CRÍTICO — El anti-patrón `Reset-FailedIteration` NO se fixeó
   entre r5 y r10**: la lección r5 lección 1 decía explícitamente
   que el controller debe commitear WIP ANTES del timeout-kill.
   NO se aplicó. Resultado: r6, r9, r10 completaron su trabajo
   (logs muestran "Iteration complete" + verificación OK) pero el
   controller timeout a 45 min mató el proceso ANTES del commit
   → `git reset --hard` + `git clean -fd` borró todo. ~135 min
   de compute tirados otra vez (r9 ~45min + r10 ~45min + r6 ~45min).
   Origen: logs r6/r9/r10 con `[CONTROLLER-TIMEOUT]` + `git log`
   (último commit es r8) + `ls scripts/game/` (no business.gd).
   Fix OBLIGATORIO: el controller (`session.ps1`/`run_overnight.ps1`)
   debe hacer `git add -A && git commit -m "WIP ronda N iter M"`
   cada 10 min de trabajo, no solo al final. Subir timeout a 90 min.

2. **El timeout de 45 min es demasiado corto para items M/L**:
   r9 (BIZ-1, M) y r10 (BIZ-1/2/3, 3×M) completaron el trabajo
   en el log pero el controller las mató. r8 completó LOOP-7/8/9
   + EXP-1 en ~10 min de trabajo real pero el proceso total
   (incluyendo export de 35MB) superó 45 min. Fix: timeout 90 min
   mínimo, o separar export (lento) de la implementación.

3. **El "devin huérfano concurrente" recurre en r10**: 3 devin.exe
   vivos simultáneamente sobrescribiendo business.gd/Main.tscn. La
   lección r5 lección 4 NO se aplicó al START de la sesión. Fix:
   `taskkill //F //IM devin.exe` al inicio de cada sesión, no solo
   al final. Origen: r10 log "Problemas encontrados".

4. **r10 sobreescribió archivos untracked sin leerlos primero**: el
   intento previo de r10 dejó WIP untracked; la sesión re-launch
   sobreescribió business.gd/Business.tscn/Main.tscn sin leerlos.
   Recuperó vía reconstrucción desde snapshot. Lección: SIEMPRE
   `git status` + leer untracked antes de write. Origen: r10 log.

5. **El git_status del prompt es stale**: r7 log "git_status stale
   — 6 modified + 7 untracked". El controller no hace `git reset`
   al inicio de cada ronda, así que el WIP de la ronda anterior
   se acumula. Fix: `git reset --hard HEAD && git clean -fd` al
   START de cada ronda (después de commitear WIP de la anterior).

### Lecciones técnicas
1. **La abstracción `Business` (Node2D contenedor) escala bien**:
   r10 demostró que BIZ-1/2/3 se modelan como Business con
   `product_value`, `start_locked`, `unlock_zone_id` + pickups/
   shelves hijos. Reutiliza pads existentes como gate. La próxima
   ronda puede re-hacer BIZ-1/2/3 en 1 iteración siguiendo este
   patrón. Origen: r10 log + snapshot.
2. **`client_spawner.gd` debe filtrar shelves de negocios
   bloqueados**: r10 añadió refresh + filter cada intento. Sin
   esto, clientes van a shelves de negocios locked y se quedan
   esperando. Origen: r10 log.
3. **Export HTML5 es estable en r8**: `export_presets.cfg` +
   templates en `%APPDATA%/Godot/export_templates/4.3.stable/`
   funcionan. El .pck incluye scripts nuevos. El gate HTML5 está
   verde y se mantiene verde si no se rompe project.godot.
4. **Headless `--quit-after 60` sigue siendo el gate fiable**:
   verifica boot + _ready + _process sin crashes. NO valida
   _physics_process ni body_entered (lección r5 confirmada).

### Lecciones de diseño
1. **El loop base se siente "conectado" pero NO "adictivo"**:
   el cimiento (recoger→estante→cliente→dinero→recoger→pad→
   desbloquear) funciona en headless, pero sin juice (partículas,
   sonido, fly-to-HUD), sin contenido (solo 2 pickups/2 shelves),
   sin balance, el primer minuto NO engancha. Veredicto: PARCIAL.
2. **Falta contenido es la brecha más grande hacia "adictivo"**:
   con solo 1 negocio (ropa, $5) el loop es monótono. BIZ-1/2/3
   (3 negocios) se hicieron 2 veces pero se perdieron. La próxima
   ronda DEBE cerrar BIZ-1/2/3 + BIZ-4/5 antes de tocar juice.
3. **El primer minuto guiado (MissionGuide) existe pero no validado**:
   los 4 beats (FILL_SHELF→COLLECT_MONEY→UNLOCK_ZONE→HIRE_HELP)
   están en código pero HIRE_HELP no tiene empleado real (capa 4
   pendiente). El beat final queda colgado. Fix: o implementar
   AUTO-1 (empleado cajero) antes, o cambiar el 4to beat a
   "Desbloquea el segundo negocio".
4. **El MVP está a ~8–10 iter de ser "lanzado" de verdad**: BIZ-1/2/3
   (3 iter, ya hechos 2 veces pero perdidos) + BIZ-4/5 (2 iter) +
   AUTO-1/2 (2 iter) + JUICE-1/POLISH-1/2 (2 iter) + balance/smoke
   visual (1 iter). Con el fix del reset destructivo, la próxima
   ronda podría cerrar el MVP jugable en 1–2 ciclos de 5 rondas.

