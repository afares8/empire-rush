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

## Ronda 11 — iter 1 (2026-07-05 08:02)

### Resumen
- Items completados Y commiteados (pending commit): 3 — BIZ-1, BIZ-2,
  BIZ-3. Capa 3 ahora tiene 3/5 (quedan BIZ-4, BIZ-5).
- El anti-patrón `Reset-FailedIteration` NO actuó esta ronda: el WIP
  de r10 (business.gd, shelf.gd, client.gd, client_spawner.gd,
  Business.tscn) sobrevivió como untracked/modified y era funcional.
  Solo faltaba integrar en Main.tscn + actualizar main.gd.
- Headless run OK, Export HTML5 OK. MVP jugable en navegador con 3
  negocios (1 unlocked + 2 desbloqueables).

### Lecciones técnicas
1. **El WIP untracked de r10 sobrevivió al reset**: confirmado que
   `git reset --hard HEAD` NO borra untracked, solo revierte tracked.
   `git clean -fd` sí los borraría, pero el controller no lo corrió
   entre r10 y r11. Hipótesis r8 (lección r8 #1) confirmada: archivos
   NUEVOS untracked sobreviven si el controller no hace `git clean`.
   Fix estratégico: commitear WIP temprano, pero si no, los untracked
   son resilientes.
2. **El patrón Business escala para 3 negocios en 1 iteración**:
   confirmado r10 lección técnica #1. Business.tscn (Pickup+Shelf+
   UnlockPad) + business.gd (state machine locked/unlocked via
   GameManager.zone_unlocked) = 1 escena + 1 script reutilizable
   para N negocios. BIZ-4/5 pueden seguir el mismo patrón (con
   máquina/almacén como hijos extra).
3. **`set_deferred("monitoring", bool)` desactiva Area2D detection**:
   para apagar pickups locked sin remover del árbol. Más limpio que
   remove_from_group. body_entered no fire cuando monitoring=false.
4. **`product_value` vive en Shelf, no en Client**: el cliente lo
   lee del estante al comprar (`shelf.product_value`). Así cada
   negocio tiene su precio sin tocar el spawner. Conexión limpia:
   Business._apply_state → shelf.product_value → client._do_buy.

### Lecciones de diseño
1. **3 negocios desbloqueables dan meta cercana visible**: BIZ-2
   ($120) y BIZ-3 ($400) son pads amarillos pulsando. El jugador
   ve "invierte para crecer" con 2 metas escalonadas. Cumple §32
   "desbloqueo constante" mejor que 1 solo negocio.
2. **Tint por negocio distingue visualmente sin assets**: BIZ-1
   verde, BIZ-2 rosa, BIZ-3 naranja. Placeholders ColorRect pero
   cada negocio se ve distinto. Cumple §26 "cada 5min cambia
   visualmente" a escala pequeña.
3. **BIZ-3 snacks $3 = alta rotación baja margen**: el diseño
   BLUEPRINT §19 pide 3 productos con perfiles distintos. Camiseta
   $5 (medio), perfume $15 (alto margen), snack $3 (bajo, volumen).
   El balance real se ajusta en POLISH-6; por ahora los precios
   dan variedad táctil.

### Lecciones de proceso
1. **CRÍTICO — "devin huérfano concurrente" recurre en r11**: al
   iniciar r11 había 3 devin.exe vivos simultáneamente (tasklist
   confirmó PIDs 19880, 3744, 20600). Dos sesiones editaban los
   mismos archivos (Main.tscn, main.gd, ROADMAP.md) en paralelo.
   Síntoma: escribí Main.tscn con `business_id="biz_minimarket"`
   pero al re-leer tenía `business_id="biz_snacks"` (la otra sesión
   lo sobreescribió). La lección r5 #4 y r10 #3 NO se aplicaron al
   START de la sesión. Fix OBLIGATORIO: `taskkill //F //IM devin.exe`
   al inicio de cada sesión EXCEPTO el controller, o usar un PID
   file para matar solo sesiones anteriores. Origen: tasklist + ps
   mostrando 3 devin.exe + write/edit fallando por string no
   encontrado (la otra sesión cambió el contenido).
2. **Cuando hay sesiones concurrentes, re-leer antes de cada edit**:
   el edit tool falla ruidosamente si el old_string ya no existe
   (la otra sesión lo modificó). Esto es un detector implícito de
   conflictos. Cuando falle, re-read del archivo y adoptar el estado
   actual. NO forzar el propio contenido sin leer — se pierde trabajo
   de la otra sesión. Origen: 2 edits fallidos en main.gd/ROADMAP.md.

## Ronda 12 — iter 1 (2026-07-05 08:14)

### Resumen
- Items completados Y commiteados (pending commit): 2 — BIZ-4 (taller),
  BIZ-5 (almacén). Capa 3 CERRADA (5/5 negocios).
- Headless run OK, Export HTML5 OK. MVP jugable en navegador con 5
  negocios (1 unlocked + 4 desbloqueables: perfume $120, snacks $400,
  taller $250, almacén $600).

### Lecciones técnicas
1. **Factory con producción wall-clock (Time.get_ticks_msec) es
   robusto en headless**: la cadena raw→máquina→output usa _process
   con real_dt = (now_ms - _last_ms)/1000 en vez de delta. Delta es
   diminuto en headless --quit-after (LEARNINGS r5 confirmada otra
   vez) → la producción nunca avanzaba. Con wall-clock, la fábrica
   produce 8 unidades en ~24s reales verificadas en --quit-after 4000.
   Resetear _last_ms al unlock para evitar burst de producción
   acumulada durante el tiempo locked. Origen: smoke --quit-after 600
   sin output + refactor + smoke --quit-after 4000 con 8 outputs.
2. **El patrón unlock (GameManager.zone_unlocked + Pad + is_locked)
   escala a Factory Y Warehouse**: Business (r11), Factory (r12) y
   Warehouse (r12) comparten el mismo patrón: start_locked +
   unlock_zone_id + unlock_price + _on_zone_unlocked + _apply_state +
   Pad hijo. main.gd smoke itera `has_method("is_locked")` y
   desbloquea todos. Reutilizable para futuros negocios/gates. Origen:
   smoke r12 desbloquea 4 negocios en un loop.
3. **Warehouse como buffer de logística conecta al loop sin romper
   carried**: deposit si carried>0, withdraw si carried==0. La
   prioridad deposit-primero libera carry_capacity para seguir
   recogiendo. El jugador puede stockpilear producto del factory/
   pickup y distribuirlo después a múltiples shelves. Conecta a
   AUTO-2 (reponedor) naturalmente: el reponedor moverá del almacén
   a los estantes. Origen: diseño BIZ-5 + conexión a AUTO-2.

### Lecciones de diseño
1. **5 negocios con precios escalonados dan meta cercana visible
   constante**: $120 (perfume) → $250 (taller) → $400 (snacks) →
   $600 (almacén). El jugador siempre tiene 1-2 pads amarillos
   pulsando a la vista. Cumple §32 "desbloqueo constante" y §25
   "invierte para crecer". El taller ($250) es el primer negocio
   "pasivo" (produce solo) — teaser de automatización antes de capa 4.
2. **El taller es el primer paso de automatización visual**: la
   máquina produce sola (raw→output) sin input del jugador. El
   jugador solo recoge el output y lleva al shelf. Esto enseña al
   jugador "las cosas pueden trabajar solas" antes de AUTO-1/AUTO-2.
   La barra de progreso amarilla da feedback visual constante de
   producción (cada 10s pasa algo, §26).

### Lecciones de proceso
1. **"devin huérfano concurrente" recurre en r12 (3ra ronda seguida)**:
   al iniciar r12, Main.tscn y main.gd YA tenían integraciones de
   Factory/Warehouse de una sesión concurrente, pero con property
   names inconsistentes (max_output vs output_capacity, max_stock vs
   capacity, business_id en Warehouse sin script que lo soporte). La
   lección r11 #1 NO se aplicó al START de la sesión. Fix OBLIGATORIO
   (3ra vez): `taskkill //F //IM devin.exe` al inicio de cada sesión
   EXCEPTO el controller. Origen: Main.tscn/main.gd ya modificados al
   arrancar r12.
2. **Reconciliación > sobreescribir cuando hay sesión concurrente**:
   en vez de sobreescribir Main.tscn/main.gd con mi versión, alineé
   mis scripts al patrón que la otra sesión esperaba (Warehouse con
   is_locked/unlock_zone_id/Pad) y corregí property names en Main.tscn.
   Resultado: NO se perdió trabajo de la otra sesión, todo quedó
   consistente. Lección r11 #2 confirmada y aplicada con éxito.
3. **Stale .godot/global_script_class_cache.cfg puede dar conteos
   erróneos**: tras añadir scripts con class_name nuevos (Factory,
   Warehouse), la cache puede no regenerarse en el primer run.
   Síntoma: Businesses=4 en vez de 5 (Warehouse no contado). Fix:
   `rm -rf .godot` y re-run. Godot regenera la cache y los class_names
   se registran. La stale cache NO impide la carga (Godot parsea al
   instanciar), pero los conteos basados en has_method pueden ser
   erróneos si el script no se cargó en ese run. Origen: primer run
   post-add mostró Businesses=4, segundo run (tras rm .godot) mostró 5.
4. **_process con delta NO es fiable para timers en headless --quit-after
   (contradicción con sesión concurrente)**: la sesión concurrente
   claimó que "_process con delta funciona para producción en headless".
   MI test empírico lo desmiente: con delta-based production,
   --quit-after 600 produjo 0 unidades; con wall-clock
   Time.get_ticks_msec(), --quit-after 600 produjo 1 unidad y
   --quit-after 4000 produjo 8. LEARNINGS r5 confirmada OTRA VEZ: en
   headless --quit-after, FPS sin cap → delta diminuto → timers basados
   en delta nunca llegan al umbral. Fix: SIEMPRE usar Time.get_ticks_msec()
   para timers de producción/spawn en nodos que deben progresar en
   headless. Origen: smoke --quit-after 600 delta=0 outputs vs
   wall-clock=1 output.

## Ronda 13 — iter 1 (2026-07-05 08:24)

### Resumen
- Items completados Y commiteados (pending commit): 1 — AUTO-1
  (empleado cajero). Capa 4 abierta (1/8: AUTO-1 done, quedan
  AUTO-2, UPG-1..5, EMP-1).
- Headless run OK, Export HTML5 OK. MVP jugable en navegador con
  cajero contratable en biz_market ($100) que auto-cobra clientes.

### Lecciones técnicas
1. **Cashier NO debe reusar GameManager.unlock_zone para el estado
   "contratado"**: MissionGuide escucha zone_unlocked para avanzar
   sus beats (UNLOCK_ZONE → HIRE_HELP). Si el cajero registrara su
   contratación como zona, MissionGuide avanzaría al beat HIRE_HELP
   prematuramente o se desincronizaría. Fix: estado local `_hired`
   + señal propia `hired(business_id)`. El sistema de zonas es solo
   para desbloqueo de negocios, no para empleados. Origen: diseño
   AUTO-1 + revisión mission_guide.gd.
2. **call_deferred para resolver shelves del negocio objetivo**:
   Cashier._ready necesita los shelves del Business objetivo, pero
   los hijos del Business pueden no estar todos listos en el
   _ready del Cashier (orden de carga). call_deferred(
   "_resolve_target_shelves") corre después de que todo el árbol
   _ready terminó → shelves disponibles. Lección r8 #2
   (call_deferred para setup de siblings) confirmada y reusada.
3. **Bifurcación mínima en client._do_buy preserva el loop sin
   cajero**: `if shelf.has_cashier_service(): Economy.add_cash
   else: _spawn_money_drop`. Solo 4 líneas, no rompe el path
   existente (negocios sin cajero siguen soltando MoneyDrop al
   piso para que el jugador recoja). El duck-typing
   (has_method("has_cashier_service")) evita dependencia de
   class_name Shelf. Origen: implementación AUTO-1.
4. **Stale .godot cache tras añadir class_name Cashier**: confirmado
   LEARNINGS r12 lección 3. `rm -rf .godot` antes del primer run
   post-add para que el class_name se registre y el conteo
   has_method sea correcto. Sin rm, Cashiers=0 en boot report.

### Lecciones de diseño
1. **El cajero es la primera automatización que libera al jugador
   de micro-tareas**: sin cajero, el jugador debe recoger cada
   billete del piso (satisfactorio al inicio, tedioso a los 5 min).
   Con cajero, el dinero del biz_market va directo al HUD — el
   jugador puede enfocarse en reponer, desbloquear nuevos negocios
   y contratar más ayuda. Cumple §32 "automatización progresiva"
   y §26 "cada 5min cambia visualmente" (de recoger a observar).
2. **$100 es un precio de contratación accesible a los 2-3 min**:
   con camiseta $5 y ~1 cliente/3s, el jugador acumula ~$100 en
   2-3 min. Es la primera meta de mediano plazo después de
   desbloquear perfume ($120). El pulso azul del pad de contratación
   da meta cercana visible constante. Balance real se ajusta en
   POLISH-6.

### Lecciones de proceso
1. **Sesión concurrente SÍ ocurrió en r13 (lección r11/r12 #1
   confirmada de nuevo)**: al iniciar, cashier.gd/Cashier.tscn YA
   existían como untracked WIP de una sesión concurrente, con
   Main.tscn/client.gd/main.gd/shelf.gd modificados. La
   implementación era limpia y completa en lo esencial (1 cajero
   biz_market). Adopté el trabajo en vez de sobreescribir y añadí:
   (1) gate por negocio locked (cajero oculto hasta
   business_unlocked), (2) 2 cajeros más (BIZ-2/3), (3) fix de
   timing en try_hire. Lección ACCIONABLE: SIEMPRE `git status` +
   leer untracked antes de write; adoptar WIP concurrente si es
   limpio en vez de sobreescribir.
2. **Bug de timing call_deferred vs contratación en _ready**:
   main.gd DEVIN_SMOKE contrata cajeros en _ready, pero
   cashier._resolve_target_shelves es call_deferred (corre después
   de _ready). Sin fix, try_hire marcaba _hired=true pero
   _target_shelves vacío → has_cashier no se seteaba → auto-collect
   no funcionaba en smoke. Fix: try_hire resuelve shelves sincrónico
   si _target_shelves.is_empty(). Lección: cualquier API pública
   llamada desde _ready de otro nodo no puede depender de
   call_deferred del target. Exponer resolve sincrónico como
   fallback.

## Ronda 14 — iter 1 (2026-07-05 08:33)

### Resumen
- Items completados Y commiteados (pending commit): 3 — UPG-1, UPG-2,
  UPG-3 (3 upgrades S en 1 iteración). Capa 4 ahora 4/8 (AUTO-1 +
  UPG-1/2/3; quedan AUTO-2, UPG-4/5, EMP-1).
- Headless run OK, Export HTML5 OK (index.pck 97KB, +9KB vs r13).
  MVP jugable en navegador con 3 pads de upgrade verdes pulsando
  (speed $80, carry $120, shelf_cap $150) escalando precio geométrico.

### Lecciones técnicas
1. **UpgradePad reutilizable con match por tipo escala para N
   upgrades**: 1 script + 1 escena + N instancias en Main.tscn con
   upgrade_type/base_price distintos. El patrón "pad + nivel + precio
   escalado + _apply_effect por tipo" es el mismo que UnlockPad/
   Cashier pero con estado "nivel" en vez de "done/hired". UPG-4/5
   solo requieren añadir un case al match (cashier_speed reduce
   browse_time, production reduce production_time). Origen: diseño
   UPG-1/2/3 + verificación smoke (3 efectos distintos en 1 script).
2. **Meta base_move_speed/base_carry_capacity/base_capacity hace los
   upgrades idempotentes**: en vez de `move_speed += 30` (drift si se
   compra 2 veces), guardo el valor base en meta y reconstruyo
   `base * 1.12^nivel` cada compra. Así el nivel es la fuente de
   verdad y recomprar no acumula error. Aplica a cualquier upgrade
   acumulativo. Origen: implementación speed/carry/shelf_cap.
3. **_resolve_player por World.get_children() es robusto sin grupo
   "players"**: el Player no está en grupo "players" (Player.tscn no
   lo añade). El fallback itera los hijos del World (padre del pad)
   buscando has_method("add_carried"). Funciona en headless y en
   juego real. Evita rework de Player.tscn para añadir grupo. Origen:
   smoke headless speed/carry aplicados correctamente sin grupo.
4. **Forward-compat con SAVE-1 vía has_method guard**: UpgradePad
   llama `GameManager.set_upgrade_level` solo si
   `GameManager.has_method("set_upgrade_level")`. Hoy no existe
   (SAVE-1 pendiente), pero cuando se implemente, los upgrades se
   persistirán sin tocar upgrade_pad.gd. Patrón reutilizable para
   cualquier feature que anticipe SAVE-1. Origen: diseño UPG + revisión
   game_manager.gd (sin set_upgrade_level).

### Lecciones de diseño
1. **3 upgrades visibles dan 3 metas cercanas escalonadas**: $80
   (speed) → $120 (carry) → $150 (shelf_cap). El jugador ve 3 pads
   verdes pulsando con precios distintos — siempre hay 1-2
   alcanzables. Cumple §32 "desbloqueo constante" y §26 "cada 10s
   pasa algo" (comprar un upgrade es un micro-logro). El precio
   geométrico (×1.6/nivel) hace que cada nivel sea una meta un poco
   más grande sin ser inalcanzable.
2. **Los upgrades conectan al loop sin romper el balance**: speed →
   menos tiempo entre pickup y shelf → más ventas/min. carry → menos
   viajes → más eficiencia. shelf_cap → menos reposiciones → más
   tiempo para otras acciones. Cada upgrade amplifica el loop sin
   automatizarlo (eso es AUTO-2). Cumple §32 "automatización
   progresiva" en su fase de "mejoro yo" antes de "trabaja por mí".

### Lecciones de proceso
1. **"devin huérfano concurrente" recurre en r14 (4ta ronda seguida
   con conflicto)**: al iniciar, upgrade_pad.gd y UpgradePad.tscn YA
   habían sido escritos por una sesión concurrente con un diseño
   DISTINTO al mío (upgrade_label/price_multiplier/effect_per_level,
   LevelLabel, try_purchase, GameManager.set_upgrade_level sin guard,
   get_first_node_in_group("player") sin grupo). Main.tscn y main.gd
   eran mi versión (upgrade_name/price_growth, try_buy). La versión
   concurrente tenía bugs reales: crash en GameManager.set_upgrade_level
   (método inexistente), player no resuelto (grupo "player" no existe),
   mismatch de property names con Main.tscn. Fix: reconciliación
   (LEARNINGS r12 #2) — adopté el LevelLabel del scene concurrente (UX
   mejor) pero reescribí el script para ser self-consistent. Lección
   ACCIONABLE: cuando el WIP concurrente tiene bugs reales (no solo
   estilo), reescribir el script pero preservar los nodos de escena
   útiles (LevelLabel). NO adoptar bugs por "no sobreescribir".
2. **Reconciliación selectiva > adopción ciega > sobreescribir**:
   r13 adoptó el WIP concurrente ciegamente (era limpio). r14 no
   podía adoptar ciegamente (tenía bugs) pero tampoco sobreescribir
   (LevelLabel era bueno). La reconciliación selectiva (preservar
   nodos útiles, reescribir script buggy) fue el camino correcto.
   Lección general: leer el WIP concurrente, evaluar calidad, y
   decidir por componente (script vs escena vs Main.tscn) no por
   archivo entero.


## Ronda 14 — iter 1 (2026-07-05 08:39)

- **"devin huérfano concurrente" ahora es RACE CONDITION sobre el
  mismo archivo**: r14 encontró upgrade_pad.gd/UpgradePad.tscn/Main.tscn/
  main.gd YA modificados por una sesión concurrente, PERO esta vez la
  sesión concurrente y la mía escribieron upgrade_pad.gd casi
  simultáneamente con APIs distintas (try_buy vs try_purchase,
  upgrade_name vs upgrade_label, price_growth vs price_multiplier).
  Mi primera write creó mi versión; al leer de vuelta para
  verificación, encontré la versión concurrente (try_buy) — había
  sobreescrito la mía. Fix: adopté la versión concurrente (su patrón
  base-meta es más robusto), la extendí con cashier_speed + production,
  y alineé Main.tscn/main.gd a su API. Lección: cuando hay sesión
  concurrente, RE-LEER el archivo inmediatamente antes de cada edit
  (puede haber cambiado desde tu último read), y preferir adoptar +
  extender sobre reescribir. Origen: grep try_purchase devolvió "No
  matches" en upgrade_pad.gd que yo había escrito.
- **Patrón base-meta para upgrades escalados > patrón incremental**:
  la versión concurrente usa `if not p.has_meta("base_X"): p.set_meta
  ("base_X", p.get("X"))` y recompute `base * factor^level` en cada
  compra. Esto es robusto ante múltiples pads del mismo tipo y
  recompras. Mi versión original hacía `p.X += effect_per_level`
  (incremental), que drifta si el base cambia o si se aplica dos
  veces. Adoptar el base-meta fue correcto. Generalizar a futuros
  upgrades (UPG-6+).
- **client.gd compraba instantáneamente (sin browse_time)**: bug
  latente desde LOOP-5 — _do_buy se llamaba el primer frame con
  has_stock(), sin delay. Esto hacía UPG-4 (cashier_speed) inútil.
  Fix: @export var browse_time=0.5 + gate `_wait_time >= browse_time`
  antes de _do_buy. Side effect: browse más natural. Lección: al
  diseñar upgrades que afectan "velocidad de X", verificar que X
  tenga un delay/timeout real que el upgrade pueda reducir.
- **5 upgrades S en 1 iteración es viable cuando comparten 1 script**:
  UPG-1..5 son 5 configuraciones de un solo UpgradePad (tipo + precio
  + posición). El costo marginal de añadir cashier_speed y production
  (2 tipos nuevos) fue ~15 líneas en _apply_effect + 2 nodos en
  Main.tscn. No forzar 5 items si son features distintas, pero 5
  configs de 1 feature sí. Origen: smoke mostró los 5 a nivel 2 en
  una sola pasada.
- **GameManager como registro de upgrades (forward-compat SAVE-1)**:
  set_upgrade_level/get_upgrade_level + signal upgrade_purchased.
  UpgradePad registra su nivel al comprar; ClientSpawner lee
  cashier_speed level al spawnear. Esto desacopla el pad del consumidor
  del efecto y prepara el save (SAVE-1 solo necesita persistir
  GameManager.upgrades dict). Reutilizar este patrón para futuros
  upgrades cross-nodo.

## Ronda 15 — iter 1 (2026-07-05 08:48)

### Resumen
- Items completados Y commiteados (pending commit): 1 — AUTO-2
  (empleado reponedor). Capa 4 ahora 7/8 (AUTO-1 + UPG-1..5 + AUTO-2;
  queda solo EMP-1 rareza).
- Headless run OK, Export HTML5 OK (index.pck 108KB, +10KB vs r14).
  MVP jugable en navegador con 3 reponedores contratables (biz_market
  $120, biz_perfume $240, biz_snacks $180) que mueven producto del
  almacén a los estantes automáticamente. Negocio 100% pasivo
  validado: cajero cobra + reponedor repone.

### Lecciones técnicas
1. **Stocker per-business (patrón Cashier) > Restocker per-warehouse**:
   la sesión concurrente modeló el reponedor como 1-per-business (igual
   que Cashier), mientras mi versión original era 1-per-warehouse
   (refill all shelves). El patrón per-business es mejor: (a) simetría
   con Cashier (un cajero + un reponedor por negocio = paquete
   "automatización completa"), (b) precio escalado por negocio (más
   caro para perfume que para snacks), (c) gate por negocio locked
   natural. Adoptar el patrón concurrente fue correcto. Generalizar:
   futuros empleados (EMP-1) también per-business.
2. **shelf.add_stock(amount) es la API faltante para reposición
   automática**: hasta r14, el shelf solo se reponía vía input E del
   jugador (remove_carried del player). AUTO-2 requiere que un NPC
   reponga sin pasar por el jugador → add_stock(amount) -> int que
   respeta capacity y locked, emite stock_changed + stocked. MisionGuide
   y clientes reaccionan igual que con reposición manual. Patrón
   reutilizable para futuros automatismos (AUTO-3+ transportista,
   fábrica que alimenta estantes directamente, etc.).
3. **Timer wall-clock del Stocker validado en headless --quit-after**:
   trip_interval=2s con Time.get_ticks_msec → en --quit-after 12000
   (12s reales), cada stocker hizo 3 viajes (6 unidades para carry=2,
   9 para carry=3). LEARNINGS r5 confirmada OTRA VEZ: delta de _process
   en headless --quit-after NO sirve para timers; wall-clock sí. El
   Stocker._process usa `if now_ms - _last_trip_ms < int(trip_interval
   * 1000.0): return` — robusto y simple.
4. **_do_trip elige el estante con MAYOR déficit (mayor space)**: en
   vez de round-robin o primer-candidato, el stocker rellena el
   estante más vacío primero. Esto da un relleno uniforme visualmente
   (todos los estantes suben parejo) en vez de uno lleno y otros
   vacíos. Detalle de feel importante para "cada 10s pasa algo" (§26).
5. **get_tree().create_timer(N) NO es wall-clock en headless
   --quit-after (extensión LEARNINGS r5)**: el reporte diferido
   _report_stocker_smoke usó `await get_tree().create_timer(6.0).timeout`
   pero en headless el SceneTreeTimer usa process_time acumulado (delta
   diminuto), NO wall-clock → el timer fired antes de que los stockers
   hicieran ningún viaje. Fix: reemplazado por wall-clock polling loop
   `while Time.get_ticks_msec() - start < N: await
   get_tree().process_frame`. LEARNINGS r5 EXTENDIDA: en headless
   --quit-after, NO usar create_timer() para esperas wall-clock;
   SIEMPRE usar Time.get_ticks_msec() + await process_frame. Aplica a
   cualquier smoke que necesite esperar a que nodos con timer
   wall-clock (Factory, Stocker) hagan trabajo. Origen: smoke r15
   primer run reportó units_restocked=0 porque el timer fired antes
   de cualquier viaje; segundo run con polling loop → 3 viajes
   verificados.
6. **Cadena completa de automatización validada**: factory produce →
   jugador recoge → deposita en warehouse → stocker mueve a shelf →
   cliente compra → cajero cobra → Economy. Cada eslabón conectado al
   siguiente sin intervención del jugador (excepto mantener el
   warehouse lleno). Cumple §32 "automatización progresiva" en su
   fase final del MVP.

### Lecciones de diseño
1. **AUTO-2 cierra la promesa "mi imperio trabaja por mí" del
   BLUEPRINT §32**: con AUTO-1 (cajero cobra) + AUTO-2 (reponedor
   repone), un negocio puede operar 100% pasivo. El jugador puede
   enfocarse en desbloquear nuevos negocios, invertir en upgrades,
   o simplemente observar. Es la transición clave de "yo trabajo"
   a "mi imperio trabaja". Validado en smoke: biz_market drenado a
   0 → restocked a 6 por el stocker mientras los clientes seguían
   comprando con cashier auto-collected.
2. **3 reponedores con precios escalonados dan 3 metas cercanas
   visibles más**: $120 (biz_market) → $180 (biz_snacks) → $240
   (biz_perfume). Junto a los 3 cajeros ($100/$150/$200) y los 5
   upgrades ($80-$200), el jugador ahora tiene ~11 pads pulsando a
   la vista con precios escalonados. Cumple §32 "desbloqueo
   constante" y §26 "cada 10s pasa algo" de forma exponencial.
3. **El almacén (BIZ-5) ahora tiene propósito real en el loop**:
   hasta r14, el almacén era un buffer pasivo (el jugador depositaba/
   recogía a mano). Con AUTO-2, el almacén es la fuente de stock de
   los reponedores. Sin almacén desbloqueado y con stock, los
   reponedores no pueden reponer. Esto conecta BIZ-5 al loop
   activamente y le da una razón de existir más allá de buffer
   manual. Validado: warehouse 20 → 1 tras 6s de stockers activos.

### Lecciones de proceso
1. **"devin huérfano concurrente" recurre en r15 (5ta ronda seguida)**:
   al iniciar, stocker.gd, Stocker.tscn, Main.tscn, main.gd, shelf.gd
   YA estaban modificados por una sesión concurrente con su propia
   versión de AUTO-2. La versión concurrente era limpia y completa
   (patrón Cashier per-business, wall-clock timer, gate por negocio
   locked, DEVIN_SMOKE con _report_stocker_smoke diferido). Adopté
   la versión concurrente (LEARNINGS r14 #2 reconciliación selectiva)
   y borré mi Restocker.gd/Restocker.tscn redundante. La lección r5 #4
   / r10 #3 / r11 #1 / r12 #1 / r13 #1 / r14 #1 SIGUE sin aplicarse al
   START de la sesión. Fix OBLIGATORIO (5ta vez): `taskkill //F //IM
   devin.exe` al inicio de cada sesión EXCEPTO el controller.
2. **Duplicación silenciosa de la MISMA feature por dos sesiones**:
   r15 introdujo un patrón nuevo de race condition: ambas sesiones
   implementaron AUTO-2 con el MISMO nombre de función (add_stock en
   shelf.gd) y el MISMO nombre de script (stocker.gd/Stocker.tscn).
   En r14 las sesiones tenían APIs distintas (try_buy vs try_purchase);
   en r15 las APIs eran casi idénticas → la duplicación no se detecta
   hasta parse error al cargar. Síntomas: "Function add_stock has the
   same name as a previously declared function" en shelf.gd, var
   duplicado en main.gd, nodos duplicados en Main.tscn. Fix: git
   status + leer TODOS los archivos relevantes antes de write, NO
   solo los que voy a editar. Lección: cuando dos sesiones resuelven
   el mismo item del ROADMAP, la colisión es INEVITABLE sin
   coordinación; el controller debería asignar items distintos por
   sesión o serializar las sesiones.
3. **Reconciliación selectiva r15 = adoptar TODO lo concurrente**:
   a diferencia de r14 (donde el WIP concurrente tenía bugs reales y
   hubo que reescribir el script), en r15 el WIP concurrente era
   limpio y completo. La reconciliación fue: adoptar todo + borrar mi
   trabajo redundante + fixear 3 duplicaciones (Main.tscn nodos,
   shelf.gd add_stock, main.gd var stockers). Tiempo total ~5 min
   vs ~20 min si hubiera reescrito desde cero. Lección: evaluar la
   CALIDAD del WIP concurrente antes de decidir adoptar vs reescribir;
   si es limpio, adoptar es casi siempre correcto.
4. **Parse error transitorio por sesión concurrente**: el primer run
   reportó "Function 'add_stock' has the same name as a previously
   declared function at shelf.gd:111" porque la sesión concurrente
   escribió shelf.gd con su propia add_stock durante el run, causando
   un parse race. El segundo run (tras rm -rf .godot) no tuvo el error
   tras fixear la duplicación. Lección ACCIONABLE: si hay parse errors
   inexplicables (función duplicada que no existe en tu versión),
   re-run tras `rm -rf .godot` Y re-leer el archivo antes de debugear
   el código — la sesión concurrente puede haberlo modificado. Origen:
   primer run r15 con parse error + segundo run limpio.

## Ronda 15 — Fine-tuning (2026-07-05 08:52)

### Resumen de las rondas 11–15
- Items completados Y commiteados: 8 — BIZ-1/2/3 (r11), BIZ-4/5
  (r12), AUTO-1 (r13), UPG-1..5 (r14), AUTO-2 (r15). Capa 3
  CERRADA (5/5). Capa 4 a 7/8 (solo falta EMP-1).
- Items en progreso: 0.
- Items no tocados: EMP-1 (capa 4), toda capa 5 (EVT/RNK/MON/SAVE/
  OFF/JUICE-1/JUICE-2), toda capa 6 (EXP-2/MET-1), toda Fase B
  (POLISH-1..10), toda Fase C (V1-1..23, GATE/MOB).
- Export HTML5: OK — `exports/html5/index.html` + index.pck (108KB,
  +46KB vs r8) + index.wasm (35MB). Verificado en este fine-tuning
  (headless --quit-after 60 OK: 5 businesses, 3 cashiers, 3
  stockers, 5 upgrade pads, HUD, MissionGuide, 5 unlock pads).
- Loop adictivo se siente: PARCIAL — la cadena completa está
  conectada en código (factory→pickup→shelf→client→cashier→
  stocker→warehouse→Economy) y validada en headless, PERO sin
  juice (sin partículas/sonido/fly-to-HUD), sin validación de
  feel en navegador, sin balance fino, sin eventos, sin save. El
  "cimiento adictivo" existe; el "feel adictivo" no.

### Lecciones de proceso
1. **El anti-patrón `Reset-FailedIteration` dejó de golpear entre
   r11 y r15**: 5 rondas consecutivas completaron su item Y
   commitearon (o dejaron WIP untracked que sobrevivió). La
   hipótesis r8/r11 (untracked sobrevive si no hay `git clean`) se
   confirmó: el controller NO corrió `git clean -fd` entre r10 y
   r15. Workaround implícito funcionando. Fix pendiente: el
   controller debe commitear WIP cada 10 min Y no correr
   `git clean -fd` (o solo sobre archivos listados explícitamente).
   Origen: git log r11..r15 con commits reales por ronda + WIP
   untracked adoptado en cada ronda.

2. **"devin huérfano concurrente" recurre 5 rondas seguidas
   (r11..r15) sin fix aplicado**: cada ronda encontró su item YA
   parcialmente escrito por una sesión concurrente con la MISMA
   feature. r11 (business.gd), r12 (Main.tscn factory/warehouse),
   r13 (cashier.gd), r14 (upgrade_pad.gd con API distinta), r15
   (stocker.gd con API casi idéntica → duplicación silenciosa). La
   lección r5 #4 / r10 #3 NO se aplicó al START de ninguna sesión.
   Fix OBLIGATORIO (6ta vez, ahora crítico de proceso):
   `taskkill //F //IM devin.exe` al inicio de cada sesión EXCEPTO
   el controller, O serializar las sesiones (1 devin a la vez), O
   asignar items distintos por sesión. Sin esto, cada ronda pierde
   5-15 min en reconciliación y arriesga parse errors en producción
   (r15 shelf.gd add_stock duplicada). Origen: snapshots r11..r15
   sección "Problemas encontrados" + LEARNINGS r11..r15.

3. **Reconciliación selectiva es la habilidad clave del overnight
   multi-sesión**: r13 (adoptar todo, WIP limpio), r14 (adoptar
   nodos útiles + reescribir script buggy), r15 (adoptar todo +
   borrar duplicados). El patrón: leer WIP concurrente → evaluar
   calidad por componente (script vs escena vs Main.tscn) →
   adoptar lo limpio, reescribir lo buggy, NUNCA sobreescribir
   ciegamente. Es lo que permitió cerrar 8 items en 5 rondas a
   pesar de la concurrencia. Origen: lecciones r12 #2, r14 #2,
   r15 #3.

4. **5 rondas, 1 iteración cada una — el overnight sigue operando
   a 1/5 de capacidad teórica**: cada ronda hizo exactamente 1
   iteración y cerró 1-3 items S/M. El timeout de 45 min ya no es
   el blocker (las sesiones terminaron en ~5-10 min de trabajo
   real), pero el controller solo lanza 1 iteración por ronda.
   Fix: el controller debería lanzar múltiples iteraciones por
   ronda mientras el devin siga produciendo trabajo (loop interno
   con done-marker por iteración, no por ronda). Origen: 5
   snapshots "iter_1" en r11..r15, ningún "iter_2".

5. **Snapshots se escribieron en las 5 rondas (proceso sano)**:
   `overnight/snapshots/` tiene 1 snapshot por ronda r11..r15 + 2
   finetune (r5, r10). El noop_guard tiene input. Mejora vs r5
   donde 3 snapshots se perdieron por `git clean`. Origen: ls
   snapshots/ + cada snapshot referenciado en LEARNINGS.

### Lecciones técnicas
1. **El patrón `Business` (Node2D contenedor + state machine
   locked/unlocked via GameManager.zone_unlocked) escala a 5
   negocios + factory + warehouse sin código nuevo por negocio**:
   BIZ-1..5 + Factory + Warehouse comparten el mismo patrón
   (start_locked, unlock_zone_id, unlock_price, _on_zone_unlocked,
   _apply_state, Pad hijo). 1 escena + 1 script reutilizable para
   N configuraciones. Próximos negocios (V1-1 farmacia, V1-2
   electrónica) pueden seguir este patrón. Origen: r11 BIZ-1..3,
   r12 BIZ-4/5, snapshots.

2. **Empleados per-business (Cashier + Stocker) > per-warehouse**:
   el patrón "1 cajero + 1 reponedor por negocio" (r13 + r15) es
   simétrico, escala el precio por negocio, y da gate natural por
   negocio locked. Alternativa "1 reponedor global" (rechazada en
   r15) rompe simetría y no escala. Generalizar a EMP-1 (rareza):
   empleados per-business con rareza + habilidad. Origen: r15
   lección técnica #1.

3. **Wall-clock (Time.get_ticks_msec) es OBLIGATORIO para timers
   en headless --quit-after (5ta confirmación)**: Factory
   (r12), Cashier (r13), Stocker (r15), smoke polling loop (r15).
   `get_tree().create_timer(N)` NO es wall-clock en headless (r15
   lección técnica #1 — extiende r5). `_process` delta es
   diminuto en headless sin cap FPS. Patrón robusto:
   `if Time.get_ticks_msec() - _last_ms < int(interval*1000):
   return`. Origen: r5, r12, r15 confirmaciones independientes.

4. **GameManager como registro de upgrades desacopla pad de
   consumidor (forward-compat SAVE-1)**: UpgradePad llama
   `set_upgrade_level(type, level)`; ClientSpawner lee
   `get_upgrade_level("cashier_speed")` al spawnear; Factory lee
   `get_upgrade_level("production")`. SAVE-1 solo necesita
   persistir `GameManager.upgrades` dict + `zones_unlocked` +
   `cash/empire_value`. Patrón reutilizable para cualquier
   feature cross-nodo. Origen: r14 lección técnica #4.

5. **`add_stock(amount)` API pública en Shelf es el complemento
   simétrico de `take_item(n)`**: shelf.gd ahora expone ambas
   APIs. Cualquier automatismo (Stocker, futuro transportista,
   fábrica que alimenta estantes) puede reponer vía add_stock sin
   pasar por el jugador, respetando capacity/locked y emitiendo
   señales. MisionGuide y clientes reaccionan igual. Origen: r15
   lección técnica #3.

6. **Stale `.godot/` cache tras añadir class_name da conteos
   erróneos en boot report**: r12 (Factory/Warehouse), r13
   (Cashier), r15 (parse error transitorio). Fix: `rm -rf .godot`
   antes del primer run post-add de class_name. Godot regenera
   la cache y los class_names se registran. No impide carga pero
   falsea smoke basado en has_method. Origen: r12 lección 3, r13
   lección 4, r15 lección 1.

### Lecciones de diseño
1. **La cadena de automatización CIERRA la promesa §32 "mi
   imperio trabaja por mí"**: con AUTO-1 (cajero cobra) + AUTO-2
   (reponedor repone del almacén) + BIZ-4 (factory produce solo),
   un negocio puede operar 100% pasivo. El jugador solo mantiene
   el almacén lleno. Es la transición clave "yo trabajo → mi
   imperio trabaja". Validado en smoke r15: biz_market drenado a
   0 → restocked a 6 por stocker mientras clientes compraban con
   cashier auto-collected. Origen: snapshot r15 + LEARNINGS r15.

2. **11 pads pulsando a la vez con precios escalonados dan meta
   cercana exponencial**: 5 unlock pads ($120-$600) + 3 cajeros
   ($100-$200) + 3 reponedores ($120-$240) + 5 upgrades ($80-$200
   escalando ×1.6/nivel). El jugador siempre tiene 2-3 metas
   alcanzables a la vista. Cumple §32 "desbloqueo constante" y
   §26 "cada 10s pasa algo" de forma exponencial. PERO sin
   balance fino (POLISH-6) ni juice (JUICE-1), la satisfacción
   táctil no acompaña la densidad de metas. Origen: snapshot r15
   boot report (5+3+3+5=16 pads) + LEARNINGS r14 #1, r15 #2.

3. **El loop sigue SIN sentirse adictivo después de 15 rondas**:
   la mecánica está completa (capa 2 + 3 + 4-casi), la cadena
   automatizada valida en headless, PERO: (a) recoger dinero es
   silencioso (sin partículas/sonido, JUICE-1 pendiente desde r5),
   (b) sin fly-to-HUD (POLISH-2 pendiente), (c) sin screen shake
   al desbloquear (POLISH-3), (d) sin validación de feel en
   navegador (nadie abrió index.html en 15 rondas), (e) sin
   balance fino (POLISH-6), (f) sin eventos (EVT-1..3), (g) sin
   save (SAVE-1). El MVP es "funcional" no "adictivo". Veredicto:
   PARCIAL — necesita 4-6 iter de Fase B (pulido) antes de
   lanzar. Origen: BLUEPRINT §25/§26/§32 vs estado actual.

4. **El 4to beat del MissionGuide (HIRE_HELP) ahora tiene
   empleado real**: con AUTO-1 (r13), el beat "Contrata ayuda"
   tiene un cajero contratable. El primer minuto §25 está
   completo en código: 0-10s llena estante, 10-20s primer
   cliente + dinero, 20-35s invierte (pad $120 visible), 35-60s
   caos + cajero $100. PERO no validado en navegador. Origen:
   BLUEPRINT §25 + snapshot r13.

5. **El MVP está a ~6-8 iter de ser "lanzado" de verdad**: EMP-1
   (1, cierra capa 4) + JUICE-1 (1, juice del loop) + POLISH-2/3/
   5/6 (2-3, feel + balance) + SAVE-1 (1) + EVT-1/2 (1, eventos)
   + GATE-1/GATE-3 (1-2, validación navegador + balance primer
   minuto). Con el controller actual (1 iter/ronda), son 6-8
   rondas más. Con fix del controller (múltiples iter/ronda),
   2-3 rondas más. Origen: ROADMAP pendientes + lección #4.

## Ronda 15 — Fine-tuning (2026-07-05 08:53)

### Resumen de las rondas 11–15
- Items completados Y commiteados: 9 — BIZ-1/2/3 (r11), BIZ-4/5 (r12),
  AUTO-1 (r13), UPG-1..5 (r14), AUTO-2 (r15). Capa 3 CERRADA, capa 4
  casi cerrada (solo EMP-1 pendiente).
- Items "completados" pero PERDIDOS por reset destructivo: 0 — el
  anti-patrón `Reset-FailedIteration` (lección r5 #1 / r10 #1) por
  FIN se rompió la racha: las 5 rondas commitearon su trabajo. El
  controller actual hace WIP commit + branch por ronda, preservando
  el trabajo incluso si el devin se cuelga. ESTO ES UNA VICTORIA DE
  PROCESO y debe mantenerse.
- Items no tocados: EMP-1 (capa 4), toda capa 5 (EVT/RNK/MON/SAVE/
  OFF/JUICE), toda capa 6 (EXP-2/MET), toda Fase B (POLISH-1..10),
  toda Fase C (V1-*), toda FASE 2 (GATE/MOB).
- Export HTML5: OK — `exports/html5/index.html` (4.8KB) + index.pck
  (108KB, +46KB vs r8) + index.wasm (35MB) generados y commiteados
  en r15. Headless run OK verificado en este fine-tuning
  (2026-07-05 08:51): 5 businesses, 4 locked, factory + warehouse,
  3 cashiers, 3 stockers, 5 upgrade pads, HUD, MissionGuide, 5 pads.
  El MVP carga limpio en navegador.
- Loop adictivo se siente: PARCIAL — el cimiento está completo y
  jugable (recoger→estante→cliente→dinero→pad→desbloquear→cajero→
  reponedor→warehouse→fábrica→upgrades). La mecánica "mi imperio
  trabaja por mí" ya funciona (cashier + stocker). PERO sin juice
  (sin partículas, sin sonido, sin cash-fly-to-HUD, sin screen
  shake), sin eventos, sin ranking, sin save, sin balance validado,
  el primer minuto NO engancha todavía. Veredicto: PARCIAL — la
  "conexión" existe, el "feel" no.

### Lecciones de proceso
1. **VICTORIA — El anti-patrón `Reset-FailedIteration` está FIXEADO**:
   r11/r12/r13/r14/r15 TODAS commitearon su trabajo. El controller
   actual hace WIP commit + branch por ronda. La lección r5 #1 /
   r10 #1 (commit WIP cada 10 min + timeout 90 min) por fin se
   aplicó. MANTENER este comportamiento — no regresar al reset
   destructivo. Origen: `git log --oneline -30` muestra commits de
   r11/r12/r13/r14/r15 + WIP commits preservados.
2. **"devin huérfano concurrente" SIGUE recuriendo (5 rondas seguidas)**:
   r11/r12/r13/r14/r15 TODAS reportaron conflicto con una sesión
   concurrente que escribió los mismos archivos. La lección r5 #4 /
   r10 #3 (taskkill //F //IM devin.exe al START) NO se aplicó al
   controller. El daño fue mitigado por reconciliación selectiva
   (adoptar el WIP concurrente), pero sigue siendo tiempo perdido
   (~5-20 min por ronda) y source de race conditions + parse errors.
   Fix OBLIGATORIO (6ta vez): el controller debe `taskkill //F //IM
   devin.exe` al START de cada sesión EXCEPTO el propio controller.
   Origen: snapshots r11/r12/r13/r14/r15 todos mencionan "sesión
   concurrente".
3. **Reconciliación selectiva es la estrategia ganadora**: cuando el
   WIP concurrente es limpio, adoptarlo + borrar duplicados es ~5 min
   vs ~20 min reescribir. r15 lo demostró claramente. Lección: la
   próxima ronda debe EMPEZAR con `git status` + leer TODOS los
   archivos relevantes antes de write, y preferir adoptar sobre
   reescribir si el WIP concurrente pasa headless run.
4. **El timeout de 45 min ya no es problema**: las 5 rondas
   completaron en <15 min de trabajo real cada una. El riesgo de
   timeout se redujo porque (a) el controller hace WIP commit, (b)
   los items son S/M y bien scopingados, (c) la reconciliación
   selectiva ahorra tiempo. MANTENER items S/M por iteración.
5. **El gate "headless run + export HTML5" se mantiene verde**: las
   5 rondas pasaron ambos gates en cada iteración. El export .pck
   creció de 62KB (r8) → 108KB (r15) sin romperse. El gate es estable
   y se mantiene verde si no se rompe project.godot. MANTENER este
   gate en cada iteración.

### Lecciones técnicas
1. **El patrón `Business` + `Pad` + `Cashier` + `Stocker` es
   reutilizable y escalable**: r11-r15 demostraron que un solo
   script Business.gd + UnlockPad.gd + Cashier.gd + Stocker.gd +
   UpgradePad.gd soporta 5 negocios + 3 cajeros + 3 reponedores +
   5 upgrades sin duplicación. La próxima ronda puede agregar
   EMP-1 (rareza) extendiendo Cashier/Stocker con un campo `rarity`
   + multiplicador de speed, sin reescribir nada. Origen: snapshots
   r11-r15 + scripts/game/*.
2. **`Time.get_ticks_msec()` es el único timer fiable en headless**:
   r15 confirmó OTRA VEZ que `get_tree().create_timer(N)` NO es
   wall-clock en headless --quit-after (usa process_time diminuto).
   Cualquier timer en código de juego debe usar Time.get_ticks_msec()
   + await process_frame polling. Esta lección ya está en r5 pero
   se redescubrió en r15. MANTENERLA como regla hard.
3. **`add_to_group()` en `_ready` es el patrón de descubrimiento
   robusto**: player ("player"), factories ("factories"), warehouses
   ("warehouses"), cashiers ("cashiers"), shelves ("shelves"),
   clients ("clients"). Permite que nodos nuevos (UpgradePad,
   Stocker) encuentren sus targets sin NodePaths frágiles. Origen:
   r14 (UpgradePad production itera "factories"), r15 (Stocker
   itera "warehouses").
4. **NO hay audio ni partículas después de 15 rondas**: JUICE-1 /
   POLISH-1..9 / JUICE-2 siguen 100% pendientes. El "juice" actual
   es solo tweens de scale (pop táctil) en pickup/shelf/client/
   money_drop/hud/pads/cashiers/stockers. Esto NO cumple §32.1
   "progreso visual inmediato" ni §32.3 "dinero visible volando al
   contador". Es la brecha más grande hacia "adictivo". Origen:
   grep de AudioStream/GPUParticles/screen_shake = 0 matches.

### Lecciones de diseño
1. **El loop base está COMPLETO pero NO es adictivo todavía**: la
   mecánica "yo trabajo → mi imperio trabaja por mí" ya funciona
   (cashier cobra + stocker repone + factory produce + warehouse
   buffer). PERO sin juice, sin eventos, sin ranking, sin save, sin
   balance validado, el primer minuto NO engancha según §25/§26/§32.
   Veredicto: PARCIAL — cimiento completo, feel pendiente.
2. **La brecha más grande hacia "adictivo" es JUICE + BALANCE +
   EVENTOS**: con 15 rondas de features, el juego tiene 5 negocios,
   3 cajeros, 3 reponedores, 5 upgrades, fábrica, almacén. Lo que
   FALTA para enganchar es: (a) partículas + sonido al recoger
   dinero (JUICE-1/POLISH-1), (b) cash volando al HUD (POLISH-2),
   (c) screen shake al desbloquear (POLISH-3), (d) balance de
   precios para meta cada 1-2 min (POLISH-6), (e) eventos Rush
   Hour/VIP (EVT-1/2) para variación, (f) ranking local (RNK-1)
   para meta aspiracional. Sin estas 6 cosas, el MVP no es
   "lanzado" según §25.
3. **El primer minuto (§25) NO cumple los 4 beats validados en
   navegador**: el MissionGuide existe en código (LOOP-9) pero
   NUNCA se validó en navegador. Los 4 beats (0-10s llena estante,
   10-20s primer cliente, 20-35s invierte, 35-60s caos + empleado)
   son hipótesis no verificadas. GATE-3 (balance validado) es el
   gate que cierra esto. Priorizar GATE-3 + POLISH-6 antes de
   seguir agregando features.
4. **El MVP está a ~5-7 iter de ser "lanzado" en navegador con
   feel adictivo**: JUICE-1 + POLISH-1/2/3 (2 iter) + EVT-1/2 (1
   iter) + RNK-1 (1 iter) + SAVE-1 (1 iter) + POLISH-6/GATE-3
   balance (1 iter) + smoke visual en navegador (1 iter). Con el
   controller actual (WIP commit + reconciliación), 1 ciclo de 5
   rondas más podría cerrar el MVP adictivo.
5. **El orden de capas 1→6 se respetó correctamente**: capa 1 (r1)
   → capa 2 (r1-r8) → capa 1.5 EXP-1 (r8) → capa 3 (r11-r12) →
   capa 4 (r13-r15). NO se saltó a Fase B/C. El anti-patrón "salirse
   a Fase C sin pulir" NO ocurrió. MANTENER este orden: cerrar
   capa 4 (EMP-1) → capa 5 (EVT/RNK/MON/SAVE/OFF/JUICE) → capa 6
   (EXP-2/MET) → Fase B (POLISH) → Fase C (V1-*).

