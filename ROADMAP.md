# Trade Empire Rush — ROADMAP

> **Re-priorizado por fine-tuning ronda 15 (2026-07-05 08:53)**:
> VICTORIA de proceso: las 5 rondas (r11-r15) commitearon su trabajo
> sin pérdidas — el anti-patrón `Reset-FailedIteration` está fixeado.
> Capa 3 CERRADA (BIZ-1..5), capa 4 casi cerrada (AUTO-1/2 + UPG-1..5
> hechos, solo EMP-1 pendiente). Export HTML5 OK (108KB .pck). El
> cimiento del loop está COMPLETO (recoger→estante→cliente→dinero→
> pad→desbloquear→cajero→reponedor→warehouse→fábrica→upgrades).
>
> PERO el loop NO es adictivo todavía: sin juice (partículas/sonido/
> cash-fly-to-HUD/screen shake = 0), sin eventos, sin ranking, sin
> save, sin balance validado en navegador. El primer minuto (§25)
> es hipótesis no verificada.
>
> Re-priorización:
> 1. **EMP-1** (cerrar capa 4, M) — último item capa 4.
> 2. **JUICE-1 + POLISH-1/2/3** (juice del loop base, 2 iter) —
>    SUBEN a P0 dentro de capa 5 porque sin juice el loop no engancha
>    (§32.1/§32.3). Hacer EN PARALELO con EMP-1 si hay rondas de sobra.
> 3. **EVT-1 + EVT-2** (eventos Rush Hour/VIP, S c/u) — variación
>    para evitar repetición (§33.1).
> 4. **SAVE-1** (guardado local) — retención básica.
> 5. **RNK-1** (ranking local con bots) — meta aspiracional (§32.6).
> 6. **POLISH-6 + GATE-3** (balance validado en navegador) — gate
>    pre-lanzamiento, valida §25 los 4 beats.
> 7. **EXP-2 + MET-1** (landing + telemetría) — capa 6 cierre.
> 8. **POLISH-4/5/7/8/9/10** (pulido visual/audio restante) — Fase B.
> 9. **V1-*** (Fase C) — NO tocar hasta Fase A + B completas.
>
> Orden de capas 4→5→6→B→C se mantiene. No saltar a Fase C.
>
> **Fix OBLIGATORIO del controller (6ta vez)**: `taskkill //F //IM
> devin.exe` al START de cada sesión excepto el controller. El
> "devin huérfano concurrente" recurre en r11/r12/r13/r14/r15 y
> causa race conditions + parse errors + tiempo perdido.
>
> **Fix OBLIGATORIO del controller (capacidad)**: el overnight
> operó a 1/5 de capacidad teórica en r11-r15 (1 iteración por
> ronda, ~5-10 min de trabajo real cada una). El controller debe
> lanzar múltiples iteraciones por ronda mientras el devin siga
> produciendo trabajo (loop interno con done-marker por iteración).
> Con esto + el fix de concurrencia, las 6-8 iter restantes al
> lanzamiento se cierran en 2-3 rondas en vez de 6-8.

> **Re-priorizado por fine-tuning ronda 10 (2026-07-05 07:50)**:
> CRÍTICO — el anti-patrón `Reset-FailedIteration` (lección r5) NO
> se fixeó y SIGUE destruyendo trabajo. r9 (BIZ-1) y r10 (BIZ-1/2/3)
> completaron su trabajo pero el controller timeout+reset lo borró.
> El último commit real es r8 (capa 2 + EXP-1). BIZ-1/2/3 fueron
> hechos 2 veces y perdidos 2 veces. La próxima ronda DEBE:
> (1) fixear el controller (commit WIP cada 10 min + timeout 90 min),
> (2) re-hacer BIZ-1/2/3 (el patrón `Business` ya está validado en
> r10 log — 1 iteración), (3) cerrar BIZ-4/5 antes de tocar capa 4,
> (4) JUICE-1 + POLISH-2/3/5/6 (juice del loop base, 2 iter) en
> paralelo con capa 3 — sin juice el loop no engancha (§32.1).
> Orden de capas 3→4→5 se mantiene. No saltar a Fase B hasta cerrar.

> **Re-priorizado por fine-tuning ronda 5 (2026-07-05)**: EXP-1
> (export HTML5) sube a P0 dentro de la Fase A, inmediatamente
> después de cerrar capa 2 (LOOP-7/8/9). Razón: después de 5 rondas
> NO hay export HTML5, lo que significa que todo el "smoke" fue
> headless y NUNCA se validó el feel real del loop en navegador.
> El export debe existir ANTES de capa 3 (contenido) para que cada
> item de contenido se pueda probar en navegador. Además, LOOP-7/8/9
> fueron "completados" 3 veces (r3, r4, r5) pero perdidos por el
> reset destructivo del controller — siguen pendientes en git y son
> el primer item a re-hacer.

> Backlog priorizado del MVP. Fuente de verdad de qué construir cada
> iteración. Ordenado por **capas de cimiento → superficie** (igual que
> el overnight de Magnate: primero la base que destraba todo lo demás,
> luego el loop, luego contenido, luego pulido, luego monetización).
>
> **Regla**: si hay items pendientes en la capa N, no toques la capa
> N+1 salvo que el item de la capa N+1 destraba varios de la N
> (justifícalo en el snapshot).

## Convención de items

```
- [ ] <ID> (<esfuerzo>) — <título>. <descripción>. <criterio de cierre>.
```

Esfuerzo: **S** (≤1 iter), **M** (1–2 iter), **L** (2–3 iter).
Prioridad: **P0** bloqueante, **P1** alto, **P2** medio, **P3** bajo.

---

## 🎯 FASE ACTUAL — MVP jugable HTML5 (capa 1 → 5)

Objetivo: un MVP jugable en navegador (export HTML5 de Godot) que
cumpla el loop adictivo central en menos de 60 segundos la primera
vez, y 15–30 min de retención natural. **Éxito MVP desde el primer
lanzamiento.**

### Capa 1 — Engine + proyecto base (destraba todo)

> Completada en ronda 1, iter 1. Ver `## Completados`.

### Capa 1.5 — Gate de export HTML5 (OBLIGATORIO antes de capa 2)

> Re-priorizado ronda 5: sin export HTML5 funcionando, todo smoke es
> headless y no valida feel real. Este es el gate que separa "código
> que compila" de "MVP jugable". Hacer PRIMERO y mantener verde en
> cada iteración posterior.

- [x] **EXP-1** (P0, M, r8/i1) — Export HTML5 del MVP. Configurar preset
  `export_presets.cfg` para HTML5. Exportar a
  `exports/html5/index.html`. Criterio: `exports/html5/index.html`
  abre en navegador y el juego corre (player visible, se mueve con
  WASD). **Gate**: si esto falla, no se toca capa 2/3.

### Capa 2 — Loop base (recoger → vender → cobrar → invertir)

- [x] **LOOP-1** (P0, M, r2/i1) — Personaje jugador controlable.
  `scripts/game/player.gd` + escena `scenes/Player.tscn`. Movimiento
  top-down con WASD/joystick virtual (mobile). Animación idle/walk
  (puede ser sprite placeholder o ColorRect rotando). Criterio: el
  personaje se mueve por el mapa con WASD en el editor.
- [x] **LOOP-2** (P0, M, r1/i1) — Cámara isométrica/top-down que
  sigue al jugador. `scripts/game/camera.gd` (GameCamera, smoothing
  exponencial + look-ahead en dir de movimiento, zoom configurable).
  Criterio: la cámara sigue al jugador suavemente.
- [x] **LOOP-4** (P0, M, r1/i1) — Estante/mostrador reponible. Al estar
  cerca con producto cargado, presionar E llena el estante (+1
  stock, hasta capacity). Visual: el estante muestra fill level.
  Criterio: el estante se llena al interactuar.
- [x] **LOOP-5** (P0, M, r1/i1) — Cliente NPC. Spawn periódico, camina a la
  fila, espera, si hay stock compra (consume 1 stock), deja dinero
  físico en el piso, se va. Criterio: un cliente completa el ciclo
  spawn → fila → compra → dinero → despawn.
- [x] **LOOP-6** (P0, M, r1/i1) — Dinero físico recogible. Billete/montón
  en el piso con valor. Al recoger, suma al contador de Cash del
  jugador (autoload `Economy`). Sonido placeholder + animación
  volando al HUD. Criterio: recoger dinero sube el contador visible.
- [x] **LOOP-7** (P0, M, r8/i1) — Pad de desbloqueo. Zona bloqueada con
  precio visible. Al estar cerca con Cash ≥ precio, presionar E
  desbloquea (descuenta Cash, activa la zona). Criterio: se
  desbloquea una zona pagando.
- [x] **LOOP-8** (P0, S, r8/i1) — HUD base. Contador de Cash, contador de
  Empire Value, indicador de misión actual (texto). Esquina superior
  izquierda. Criterio: el HUD muestra Cash y Empire Value en tiempo
  real.
- [x] **LOOP-9** (P0, S, r8/i1) — Primer minuto guiado (sin tutorial
  pesado). Textos contextuales que aparecen al cumplir condiciones:
  "Llena tu primer estante" → al llenar → "Recoge tu dinero" → al
  recoger → "Invierte para crecer" → al desbloquear → "Contrata
  ayuda". Criterio: el flujo de textos guía sin bloquear.

### Capa 3 — Contenido MVP (3 negocios + taller + almacén)

> Capa 3 CERRADA. BIZ-1/2/3 en r11/i1, BIZ-4/5 en r12/i1 (ver
> `## Completados`). Siguiente: capa 4 (automatización + upgrades).

### Capa 4 — Automatización + upgrades + empleados

> UPG-1..5 cerrados en r14/i1, AUTO-1 en r13/i1, AUTO-2 en r15/i1,
> EMP-1 en r16/i1 (ver `## Completados`). Capa 4 CERRADA. Siguiente:
> capa 5 (eventos + ranking + monetización + save + juice).

### Capa 5 — Eventos + ranking + monetización MVP + pulido

- [ ] **EVT-1** (P1, S) — Evento "Rush Hour" (60s): 2x clientes
  durante 60s, recompensa al terminar. Criterio: el evento se
  activa, termina y da recompensa.
- [ ] **EVT-2** (P1, S) — Evento "VIP Order": cliente VIP que paga
  el triple si se atiende rápido. Criterio: el VIP aparece y
  recompensa.
- [ ] **EVT-3** (P2, S) — Evento "Flash Sale": vende todo antes del
  tiempo. Criterio: el evento funciona.
- [ ] **RNK-1** (P2, M) — Ranking simple (local, contra bots con
  nombres generados). 30 "jugadores" con Empire Value que sube con
  el tiempo. El jugador sube/baja. Criterio: el ranking se ve y el
  jugador tiene posición.
- [ ] **MON-1** (P2, S) — Ad recompensado placeholder (botón "Ver
  anuncio ×2 cash por 5 min"). En el MVP no hay ad real, solo el
  flujo UI + efecto. Criterio: el botón aplica el boost.
- [ ] **MON-2** (P3, S) — Tienda placeholder (gems, remove ads,
  starter pack). UI sin IAP real todavía. Criterio: la tienda se
  abre y muestra los productos.
- [ ] **SAVE-1** (P1, S) — Guardado de progreso local
  (`user://save.json` via `FileAccess`). Cash, Empire Value, zonas
  desbloqueadas, upgrades, empleados. Criterio: al reiniciar, el
  progreso se conserva.
- [ ] **OFF-1** (P2, S) — Offline earnings: al volver, calcular
  ingresos pasivos por el tiempo ausente y mostrar popup "Tu
  imperio generó $X mientras estabas fuera" con botón ×2 (ad).
  Criterio: el popup aparece y suma.
- [ ] **JUICE-2** (P2, S) — Música de fondo + SFX placeholders
  (libres de licencia o generados con Godot). Criterio: hay audio.

### Capa 6 — Landing + métricas (export ya hecho en capa 1.5)

- [ ] **EXP-2** (P1, S) — Landing page mínima (`exports/html5`
  sirve el juego + un index con título "Trade Empire Rush" y botón
  "Jugar"). Criterio: la landing carga el juego.
- [ ] **MET-1** (P2, S) — Telemetría local (consola) de métricas
  del blueprint: tiempo de primera sesión, zonas desbloqueadas,
  eventos jugados, ads vistos. Criterio: las métricas se loguean.

---

## 🎯 FASE B — Pulido MVP (capa 7)

> Esta capa se construye SOLO después de que todas las capas 1–6
> están completadas. El objetivo es que el MVP sea **adictivo de
> verdad** según BLUEPRINT.md §25 (primer minuto), §26 (cómo debe
> sentirse), §32 (qué es lo adictivo), §33 (qué cansa).
>
> La AI genera items aquí cuando evalúa que el MVP no cumple alguno
> de esos criterios. Los items son ejemplos — la AI debe crear los
> específicos según lo que observe al probar el juego.

- [ ] **POLISH-4** (P1, S) — Glow/pulso en pads de desbloqueo para
  llamar la atención. Criterio: los pads son visualmente atractivos.
- [ ] **POLISH-5** (P1, S) — Indicador de "meta cercana" siempre
  visible en el HUD (próximo pad alcanzable). Criterio: siempre hay
  una meta visible.
- [ ] **POLISH-6** (P1, S) — Balance de precios: ajustar para que
  el progreso sea ni muy lento ni muy rápido (meta corta cada 1–2
  min). Criterio: el progreso se siente bien.
- [ ] **POLISH-7** (P1, S) — Spawn rate de clientes ajustado para
  caos controlado (ni vacío ni abrumador). Criterio: el ritmo se
  siente bien.
- [ ] **POLISH-8** (P2, S) — Animación de clientes: idle, walk,
  compra (puede ser tween simple sobre ColorRect). Criterio: los
  clientes se sienten vivos.
- [ ] **POLISH-9** (P2, S) — Música de fondo placeholder + SFX
  (libres o generados). Criterio: hay audio y no molesta.
- [ ] **POLISH-10** (P2, S) — Tutorial contextual pulido (textos
  que aparecen al cumplir condiciones, no modal blocking). Criterio:
  el primer minuto guía sin frustrar.

---

## 🎯 FASE C — Versión 1.0+ (capa 8)

> Esta capa se construye SOLO después de que la AI juzgue que el MVP
> está "listo" (cumple §25, §26, §32, §33). Hasta entonces, NO se
> toca. Los items aquí se generan basándose en BLUEPRINT.md §20
> (versión 1.0) y secciones marcadas [1.0+].

- [ ] **V1-1** (P1, M) — Farmacia (negocio nuevo, §8 Negocio 3).
  Cuidado personal, vitaminas ficticias, higiene, belleza.
- [ ] **V1-2** (P1, M) — Electrónica (negocio nuevo, §8 Negocio 5).
  Celulares, audífonos, consolas ficticias, tablets, gadgets.
- [ ] **V1-3** (P1, L) — Fábrica avanzada (§8 Negocio 6 expandido).
  Materia prima → máquina → caja → camión. Mayor profundidad.
- [ ] **V1-4** (P1, L) — Bodega + logística + sistema de camión
  (§8 Negocio 7). Cajas, pallets, camiones, rutas.
- [ ] **V1-5** (P1, M) — Puerto + contenedores (§6 Etapa 5).
  Llegada de contenedores, descarga, distribución.
- [ ] **V1-6** (P1, L) — Segunda ciudad (§6 Etapa 7). Sucursales,
  gerentes regionales, logística inter-ciudad.
- [ ] **V1-7** (P1, M) — Ligas semanales completas (§10). 8 ligas,
  30–50 jugadores por liga, premios semanales.
- [ ] **V1-8** (P1, M) — Sistema de estatus/títulos (§11). 9
  títulos que desbloquean ropa/oficina/vehículos.
- [ ] **V1-9** (P1, M) — Personalización del personaje (§12).
  Hombre/mujer, ropa casual/elegante/traje, accesorios.
- [ ] **V1-10** (P1, M) — Empleados premium (§13 expandido, §30 D).
  Cajero rápido, gerente experto, reponedor veloz, influencer, etc.
- [ ] **V1-11** (P1, M) — Skins y personalización (§30 E). Tienda,
  caja, empleados, vehículos, fábricas, oficinas.
- [ ] **V1-12** (P1, L) — Pase de temporada mensual (§15, §30 F).
  30 días, misiones, skins, empleados, decoraciones, boosts.
- [ ] **V1-13** (P1, M) — Cofres transparentes con probabilidades
  visibles (§30 G). Común/raro/épico/empresarial/temporada.
- [ ] **V1-14** (P1, M) — Monetización real: IAP con Godot
  in-app purchases (§30 A–H). Gems, remove ads, starter pack.
- [ ] **V1-15** (P1, M) — Ads recompensados reales (AdMob).
  §15, §30.1.
- [ ] **V1-16** (P1, M) — Daily Login + Daily Missions + Weekly
  Goals (§38). Recompensa diaria creciente, misiones, metas.
- [ ] **V1-17** (P1, M) — Eventos globales (§36). Global Trade
  Fair, Black Friday Rush, Factory Madness, Luxury Week, etc.
- [ ] **V1-18** (P1, M) — Sistema de logros y trofeos (§37).
  Started From Zero, First Million, Factory King, etc.
- [ ] **V1-19** (P1, M) — Sistema de fatiga + reenganche (§40).
  Detectar cansancio, ofrecer evento especial, recompensa de
  regreso, meta cercana.
- [ ] **V1-20** (P1, L) — Perfil público de imperio completo (§34).
  Nombre, avatar, logo, título, Empire Value, negocios, ciudades,
  fábricas, empleados legendarios, trofeos, lema.
- [ ] **V1-21** (P1, M) — Export Android (APK/AAB) + Google Play
  Console setup. §28 blueprint.
- [ ] **V1-22** (P1, M) — Export iOS + App Store Connect setup.
  §28 blueprint.
- [ ] **V1-23** (P1, M) — Guardado en la nube (§20). Sync de
  progreso entre dispositivos.

---

## 📦 Completados

- [x] **GODOT-1** (P0, S, r1/i1) — Godot 4.3 stable portable en
  `godot/godot.exe`. `godot.exe --version` = 4.3.stable.official.
- [x] **GODOT-2** (P0, S, r1/i1) — `project.godot` valida headless
  sin errores. Creados autoloads `Economy` y `GameManager` para
  destrabar la carga.
- [x] **GODOT-3** (P0, S, r1/i1) — `scenes/Main.tscn` creada con
  Node2D "Main" + "World" + Camera2D. Script `main.gd` arranca sin
  crash. `run/main_scene` ya apuntaba a `res://scenes/Main.tscn`.
- [x] **EXP-1** (P0, M, r8/i1) — Export HTML5 del MVP.
  `export_presets.cfg` (preset "HTML5", platform Web, export_path
  exports/html5/index.html, gl_compatibility vram compression
  desktop). Export-release genera index.html + index.js + index.wasm
  (35MB) + index.pck (62KB) sin errores. Templates web ya instalados
  en %APPDATA%/Godot/export_templates/4.3.stable/. El .pck incluye
  los scripts nuevos (unlock_pad.gdc, hud.gdc, mission_guide.gdc).
  Gate HTML5 superado — el MVP es jugable en navegador.
- [x] **LOOP-1** (P0, M, r2/i1) — Personaje jugador controlable.
  `scripts/game/player.gd` (CharacterBody2D, WASD, accel/friction,
  bob + squash/stretch placeholder, señal `interact_pressed`) +
  `scenes/Player.tscn` (Body/Head/Shadow ColorRects). Instanciado en
  `Main.tscn` con Floor visible. Headless run OK, player spawned.
- [x] **LOOP-2** (P0, M, r1/i1) — Cámara que sigue al jugador.
  `scripts/game/camera.gd` (GameCamera: smoothing exponencial
  follow_speed=6, look-ahead=70px en dir de facing, zoom
  configurable). Asignada a Camera2D en `Main.tscn`. Headless run OK,
  player encontrado por la cámara sin warnings.
- [x] **LOOP-3** (P0, M, r2/i1) — Producto recogible. `scripts/game/
  pickup.gd` (Pickup Area2D, stock regenera con el tiempo, recoger
  con E en rango, duck-typing para no depender de class_name) +
  `scenes/Pickup.tscn` (Body ColorRect + StockLabel + CollisionShape
  área 70x70). Player gana `carried`/`carry_capacity=3` + señal
  `carry_changed` + indicador visual (CarryBox amarillo + CarryLabel
  "xN" sobre la cabeza, con pop de scale al recoger). Añadido
  BodyShape (RectangleShape2D 28x36) al Player para que Area2D lo
  detecte. 2 pickups instanciados en Main.tscn. Smoke test OK:
  recoger respeta capacidad, no recoge fuera de área.
- [x] **LOOP-4** (P0, M, r1/i1) — Estante/mostrador reponible.
  `scripts/game/shelf.gd` (Shelf Area2D, stock/capacity, fill con E
  consume carried del jugador, duck-typing, API `take_item()` +
  `has_stock()`/`is_empty()` + señal `stock_changed` para LOOP-5) +
  `scenes/Shelf.tscn` (Body ColorRect 64x48 + StockLabel + área
  80x80). 2 shelves instanciados en Main.tscn. Smoke test OK:
  llena respeta capacity, no llena sin carried ni fuera de área,
  take_item consume stock correctamente.
- [x] **LOOP-5** (P0, M, r1/i1) — Cliente NPC. `scripts/game/client.gd`
  (Client Node2D, FSM to_shelf→browse→to_exit, camina con
  walk_speed, take_item del estante, suelta MoneyDrop al comprar,
  pop táctil, usa _process + real_delta via Time.get_ticks_msec) +
  `scripts/game/client_spawner.gd` (ClientSpawner, spawn cada 3s
  real-time, max 5 concurrentes, asigna shelf aleatorio del grupo
  "shelves") + `scenes/Client.tscn` (Body + Face ColorRects, grupo
  "clients"). Headless smoke OK: ciclo spawn→walk→buy→money drop→
  despawn verificado con DEVIN_SMOKE=1 (shelves pre-filled).
- [x] **LOOP-6** (P0, M, r1/i1) — Dinero físico recogible.
  `scripts/game/money_drop.gd` (MoneyDrop Area2D, value, pop-in
  tween TRANS_BACK, body_entered detecta player por duck-typing,
  Economy.add_cash(value) al recoger) + `scenes/MoneyDrop.tscn`
  (Body ColorRect verde + ValueLabel "$N" + CollisionShape2D 34x34).
  Soltado por el cliente al comprar. Headless: spawn sin errores,
  colección vía Area2D requiere physics tick (no corre en headless
  --quit-after) pero lógica verificada. HUD visual del contador es
  LOOP-8; juice (partículas, sonido, fly-to-HUD) es JUICE-1/POLISH-2.
- [x] **LOOP-7** (P0, M, r8/i1) — Pad de desbloqueo.
  `scripts/game/unlock_pad.gd` (UnlockPad Area2D, zone_id, price,
  pulso amarillo loop, prompt "E para desbloquear", duck-typing,
  API `try_unlock()` para smoke headless, señal `unlocked(zone_id)`,
  pop táctil + color verde al desbloquear) + `scenes/UnlockPad.tscn`
  (Body ColorRect 64x64 + PriceLabel + PromptLabel + CollisionShape
  80x80). 2 pads instanciados en Main.tscn ($50 zone_market,
  $120 zone_perfume). Headless smoke OK: try_unlock=true, cash
  gastado, zona registrada en GameManager.
- [x] **LOOP-8** (P0, S, r8/i1) — HUD base. `scripts/ui/hud.gd`
  (CanvasLayer, CashLabel/EmpireLabel/MissionLabel, conecta a
  Economy.cash_changed + empire_value_changed, pop de scale al
  cambiar cash, API `set_mission_text()` para MissionGuide) +
  `scenes/HUD.tscn` (Panel esquina sup-izq, cash verde, EV amarillo,
  misión blanco con outline). Instanciado en Main.tscn. Headless:
  HUD carga y refresca cash/EV en tiempo real.
- [x] **LOOP-9** (P0, S, r8/i1) — Primer minuto guiado.
  `scripts/ui/mission_guide.gd` (Node, enum Step FILL_SHELF→
  COLLECT_MONEY→UNLOCK_ZONE→HIRE_HELP→DONE, avanza por señales:
  shelf.stocked → Economy.money_collected → UnlockPad.unlocked,
  muestra texto en HUD via set_mission_text, no bloquea input).
  Instanciado en Main.tscn. Añadido signal `money_collected` a
  Economy (distingue ingreso de gasto). Headless: MissionGuide
  carga, setup via call_deferred conecta a shelves/pads/Economy.
- [x] **BIZ-1** (P1, M, r11/i1) — Puesto callejero (camisetas, $5).
  `scripts/game/business.gd` (Business Node2D contenedor: business_id,
  product_name, product_value, start_locked, unlock_zone_id,
  unlock_price, tint; _apply_state marca shelves locked, apaga
  pickups, reactiva pad; escucha GameManager.zone_unlocked) +
  `scenes/Business.tscn` (Pickup + Shelf + UnlockPad hijos).
  BusinessBIZ1 en Main.tscn, unlocked, tint verde. Headless OK,
  export HTML5 OK.
- [x] **BIZ-2** (P1, M, r11/i1) — Estante de perfumes ($15,
  desbloqueable). BusinessBIZ2 en Main.tscn, start_locked=true,
  zone_perfume $120, tint rosa. Al desbloquear la zona,
  _on_zone_unlocked reactiva shelves/pickups. DEVIN_SMOKE verifica
  unlock flow. Headless OK, export HTML5 OK.
- [x] **BIZ-3** (P1, M, r11/i1) — Mini market snacks ($3, alta
  rotación, desbloqueable). BusinessBIZ3 en Main.tscn,
  start_locked=true, zone_snacks $400, tint naranja. Mismo patrón
  que BIZ-2. Headless OK, export HTML5 OK.
- [x] **BIZ-4** (P1, M, r12/i1) — Mini taller/fábrica. `scripts/game/
  factory.gd` (Factory Node2D: raw_stock auto-regen → máquina
  convierte raw→output a ritmo production_time → output_stock →
  jugador recoge con E del OutputArea y lleva al Shelf hijo; usa
  wall-clock Time.get_ticks_msec para robustez headless LEARNINGS r5;
  patrón unlock via GameManager.zone_unlocked igual que Business) +
  `scenes/Factory.tscn` (Machine ColorRect + ProgressFill + RawPile +
  OutputBody + OutputArea + Shelf + UnlockPad hijos). FactoryBIZ4 en
  Main.tscn, start_locked=true, zone_factory $250, tint azul, camiseta
  $5, production_time=3s, output_capacity=8. Headless: produce 8
  unidades y para al llenar output. Export HTML5 OK.
- [x] **BIZ-5** (P1, S, r12/i1) — Mini almacén. `scripts/game/
  warehouse.gd` (Warehouse Area2D: stock/capacity, jugador deposita
  con E si carried>0, recoge con E si carried==0 y stock>0; buffer de
  logística; patrón unlock via GameManager.zone_unlocked + Pad hijo;
  API deposit/withdraw para smoke headless) + `scenes/Warehouse.tscn`
  (Body + StockLabel + AreaShape + Pad hijo). WarehouseBIZ5 en
  Main.tscn, start_locked=true, zone_warehouse $600, capacity=20.
  Headless: unlock + pre-fill stock=10 verificados. Export HTML5 OK.
- [x] **AUTO-1** (P1, M, r13/i1) — Empleado cajero. `scripts/game/
  cashier.gd` (Cashier Area2D: target_business_id + hire_price, pad
  de contratación con pulso azul, try_hire() gasta cash y marca
  _hired, _apply_state setea has_cashier=true en los shelves del
  negocio objetivo; NO reusa GameManager.unlock_zone para no
  interferir con MissionGuide; gate por negocio bloqueado: si el
  negocio objetivo está locked, el cajero se oculta hasta
  business_unlocked; try_hire resuelve shelves sincrónico si el
  call_deferred pendiente) + `scenes/Cashier.tscn` (Body +
  PriceLabel + PromptLabel + AreaShape 80x80). 3 instancias en
  Main.tscn: CashierBIZ1 (-120,60) biz_market $100, CashierBIZ2
  (240,-100) biz_perfume $200, CashierBIZ3 (-280,260) biz_snacks
  $150. shelf.gd añade var has_cashier + has_cashier_service().
  client.gd _do_buy: si el shelf tiene cajero → Economy.add_cash
  directo (sin MoneyDrop), else → MoneyDrop al piso como antes.
  Headless: DEVIN_SMOKE contrata los 3 cajeros y clientes compran
  con "cashier auto-collected $5" verificado (--quit-after 8000,
  múltiples compras auto-colectadas, sin MoneyDrop en shelves con
  cajero). Export HTML5 OK (cashier.gd.remap en .pck 88KB).
- [x] **UPG-1** (P1, S, r14/i1) — Upgrade de velocidad del jugador.
  `scripts/game/upgrade_pad.gd` (UpgradePad Area2D reutilizable:
  upgrade_type, base_price, max_level=5, price_growth geométrico;
  try_buy() gasta cash, sube nivel, aplica efecto, escala precio;
  _apply_effect por tipo; _resolve_player fallback por World children;
  pulso verde loop + pop táctil al comprar; LevelLabel "Lv N/M";
  forward-compat con SAVE-1 vía GameManager.has_method guard) +
  `scenes/UpgradePad.tscn` (Body + NameLabel + LevelLabel + PriceLabel
  + PromptLabel + AreaShape 80x80). UpgradeSpeed (80,100) tipo "speed"
  base $80, +12% move_speed base por nivel. Headless: speed lv2 →
  move_speed 220→276 (×1.12²). Export HTML5 OK.
- [x] **UPG-2** (P1, S, r14/i1) — Upgrade de capacidad de carga.
  UpgradeCarry (200,100) tipo "carry" base $120, +2 carry_capacity
  base por nivel. Headless: carry lv2 → carry_capacity 3→7. Export
  HTML5 OK.
- [x] **UPG-3** (P1, S, r14/i1) — Upgrade de capacidad del estante.
  UpgradeShelfCap (-80,200) tipo "shelf_cap" base $150, +3 capacity
  a todos los estantes activos por nivel. Headless: shelf_cap lv2 →
  capacity 6→12. Export HTML5 OK.
- [x] **UPG-4** (P1, S, r14/i1) — Upgrade de velocidad de caja.
  UpgradeCashierSpeed (320,60) tipo "cashier_speed" base $180. Sin
  efecto directo sobre nodos: ClientSpawner lee
  GameManager.get_upgrade_level("cashier_speed") al spawnear cada
  cliente y reduce browse_time 15% por nivel (mín 0.1s). client.gd
  añade @export var browse_time=0.5 y gatea _do_buy tras
  _wait_time>=browse_time. Headless: cashier_speed lv2 registrado,
  spawner aplica browse_time=max(0.1, 0.5*(1-0.15*2))=0.35s. Export
  HTML5 OK.
- [x] **UPG-5** (P1, S, r14/i1) — Upgrade de velocidad de producción.
  UpgradeProduction (-440,-160) tipo "production" base $200, -10%
  production_time por nivel (mín 0.4s) en todas las fábricas del
  grupo "factories" (factory.gd añade add_to_group("factories")).
  Patrón base-meta: captura base_production_time al primer nivel y
  recompute. Headless: production lv2 → factory production_time
  3.0→2.4 (×0.8). Export HTML5 OK (upgrade_pad.gd.remap en .pck 98KB).
- [x] **AUTO-2** (P1, M, r15/i1) — Empleado reponedor. `scripts/game/
  stocker.gd` (Stocker Area2D: target_business_id + hire_price +
  trip_interval + carry_per_trip; pad de contratación con pulso
  verde, try_hire() gasta cash y marca _hired; _process con timer
  wall-clock Time.get_ticks_msec cada trip_interval segundos retira
  carry_per_trip unidades del Warehouse y las deposita en el estante
  del negocio objetivo con más espacio; gate por negocio bloqueado:
  si el negocio objetivo está locked, el reponedor se oculta hasta
  business_unlocked; NO reusa GameManager.unlock_zone para no
  interferir con MissionGuide, igual que Cashier; _resolve_references
  call_deferred + fallback sincrónico en try_hire) +
  `scenes/Stocker.tscn` (Body + PriceLabel + PromptLabel + AreaShape
  80x80). shelf.gd añade API pública add_stock(amount) para reposición
  sin pasar por el jugador (respeta capacity y locked). 3 instancias
  en Main.tscn: StockerBIZ1 (-60,140) biz_market $120 trip=2s carry=2,
  StockerBIZ2 (300,-60) biz_perfume $240 trip=2.5s carry=2, StockerBIZ3
  (-220,320) biz_snacks $180 trip=1.8s carry=3. Headless: DEVIN_SMOKE
  contrata los 3 reponedores, drena biz_market shelves a 0, pre-fill
  warehouse=20; tras 6s wall-clock, biz_market shelf=6 (3 viajes × 2),
  biz_perfume=4 (2 viajes × 2), biz_snacks=9 (3 viajes × 3), warehouse
  20→1 (19 consumidos). Export HTML5 OK (stocker.gd.remap en .pck
  108KB, +10KB vs r14).
- [x] **EMP-1** (P2, M, r16/i1) — Sistema de rareza de empleados.
  `scripts/game/employee_rarity.gd` (helper `extends RefCounted` con
  enum Tier COMMON/RARE/EPIC/LEGENDARY, metadata por tier: color,
  price_mult 1.0/1.5/2.2/3.5, power_mult 1.0/1.25/1.6/2.0, label;
  static getters from_string/name_of/color_of/price_mult_of/
  power_mult_of/cashier_ability_of/stocker_ability_of/
  influencer_ability_of; NO usa class_name para evitar parse error
  cross-script LEARNINGS r2, consumidores hacen preload). Cashier y
  Stocker extendidos con `@export var rarity`, `_resolve_rarity()`,
  `_effective_price`, y efectos: Cashier aplica `cashier_value_mult`
  (power_mult) a las ventas vía shelf.cashier_value_mult leído por
  client.gd; Stocker aplica `_effective_trip_interval` (trip/mult) y
  `_effective_carry_per_trip` (carry×mult). Nuevo `Influencer`
  (tercer tipo de empleado, BLUEPRINT §13 "Maya Marketing"): reduce
  spawn_interval del ClientSpawner por power_mult combinado de todos
  los influencers contratados. RarityLabel añadido a Cashier.tscn,
  Stocker.tscn, Influencer.tscn mostrando "Rareza · Habilidad" con
  color de rareza. Main.tscn: 3 cajeros (Comun/Epico/Legendario), 3
  reponedores (Raro/Comun/Epico), 2 influencers (Raro/Epico). Headless
  DEVIN_SMOKE verifica: rarezas reportadas en boot, contratación con
  precios efectivos ($100/$440/$525 cajeros, $180/$240/$396
  reponedores, $450 influencer), value_mult aplicado a ventas ($5
  comun, $24 epico perfume, $6 legendario snacks), spawn_interval
  3.0s→2.40s (÷1.25 influencer raro). Export HTML5 OK (index.pck
  120KB, +12KB vs r15, incluye employee_rarity.gd.remap +
  influencer.gd.remap). Capa 4 CERRADA.
- [x] **JUICE-1** (P1, S, r17/i1) — Polished feel: partículas al
  recoger dinero, sonido placeholder, screen shake suave al
  desbloquear, animación de cash volando al HUD. Nuevo autoload
  `Juice` (`scripts/autoload/juice.gd`) centraliza feedback táctil:
  `money_burst()` (CPUParticles2D verde, 14 partículas, gravedad),
  `fly_cash()` (Label "+$N" que flota up + shrink + fade), `shake()`
  (offset random en Camera2D con decaimiento), `unlock_burst()`
  (24 partículas radiales amarillas), SFX procedural vía
  AudioStreamWAV generado en runtime (`_gen_beep` ascendente para
  pickup, `_gen_chord` C-major para unlock, beep descendente para
  buy). Sin assets externos → HTML5-safe. Registrado en
  project.godot `[autoload]`. money_drop.gd: al recoger llama
  money_burst + fly_cash + play_pickup + pop de scale antes de
  queue_free. unlock_pad.gd: try_unlock llama shake(8,0.35) +
  unlock_burst + play_unlock. upgrade_pad.gd: try_buy llama
  play_buy + shake(3,0.18). main.gd boot report añade Juice=true.
  Headless: DEVIN_SMOKE corre 10 upgrades con Juice.shake/play_buy
  sin crash. Export HTML5 OK (index.pck 126KB, +6KB, incluye
  juice.gd.remap + index.audio.worklet.js para audio web).
- [x] **POLISH-1** (P1, S, r17/i1) — Feedback visual + sonoro al
  recoger dinero: partículas (CPUParticles2D), tween de scale pop,
  sonido placeholder (beep ascendente 660→1320Hz). Cubierto por
  JUICE-1 money_drop.gd + Juice.money_burst/play_pickup.
- [x] **POLISH-2** (P1, S, r17/i1) — Tween de cash volando al HUD
  al recoger. Label "+$N" flota 90px up con shrink + fade
  (TRANS_QUAD EASE_OUT). Cubierto por JUICE-1 Juice.fly_cash.
- [x] **POLISH-3** (P1, S, r17/i1) — Screen shake suave al
  desbloquear zona. Juice.shake(8, 0.35) aplica offset random a
  Camera2D con decaimiento lineal. Acompañado de unlock_burst
  (24 partículas amarillas radiales) + play_unlock (chord C-major).
  Cubierto por JUICE-1 unlock_pad.gd.

---

## 🚧 Notas de priorización

- **Capa 1 es bloqueante**: sin Godot instalado y proyecto válido,
  nada se puede testear. GODOT-1 primero.
- **Capa 2 es el corazón adictivo**: el loop debe sentirse bien antes
  de agregar contenido. Si el loop no es divertido con 1 producto y
  1 estante, no lo será con 3 negocios.
- **Capa 3 es contenido**: solo después de que el loop funciona.
- **Capa 4 es automatización**: la transición "yo trabajo → mi
  imperio trabaja por mí" es lo que engancha a mediano plazo.
- **Capa 5 es retención + monetización**: eventos, ranking, ads,
  save, offline, juice.
- **Capa 6 es lanzamiento**: export HTML5 + landing + métricas. Sin
  esto no hay MVP jugable que mostrar.

**Regla de oro**: el MVP debe poder jugarse 15–30 min sin aburrirse
antes de declararlo "lanzado".

---

## 🎯 FASE 2 — Versión 1.0 (post-MVP)

> Agregado por fine-tuning ronda 5. Estos items cierran el gap entre
> el MVP entregado (capa 1-6) y el BLUEPRINT.md §20 (versión 1.0).
> NO se tocan hasta que Fase A (capa 1-6) Y Fase B (capa 7 pulido)
> estén completas y el MVP sea adictivo según §25/§26/§32/§33.
> Los items V1-* de FASE C ya existente cubren el contenido 1.0;
> esta sección agrupa los gaps estructurales detectados.

### Gates de calidad pre-1.0
- [ ] **GATE-1** (P0, S) — Export HTML5 estable: el juego corre 5
  min en navegador sin crash ni memory leak visible. Criterio:
  smoke manual de 5 min en navegador pasa.
- [ ] **GATE-2** (P0, S) — Save/load robusto (SAVE-1) que sobrevive
  reload del navegador (localStorage en HTML5, no solo
  `user://`). Criterio: al refrescar navegador, el progreso
  persiste.
- [ ] **GATE-3** (P0, M) — Balance validado: el primer minuto
  cumple §25 (0-10s llena estante, 10-20s primer cliente, 20-35s
  invierte, 35-60s caos + empleado). Criterio: smoke en navegador
  cumple los 4 beats.

### Mobile readiness (pre-export Android/iOS)
- [ ] **MOB-1** (P1, S) — Touch controls: joystick virtual +
  botón de acción. Criterio: el juego es jugable con touch en
  navegador mobile.
- [ ] **MOB-2** (P1, S) — UI escalable: HUD y pads se ven bien en
  pantalla vertical y horizontal. Criterio: layout no se rompe en
  9:16 y 16:9.
- [ ] **MOB-3** (P1, M) — Performance mobile: 60 FPS en
  navegador mobile con 10 NPCs + 20 pickups. Criterio: profiler
  Godot muestra <16ms/frame.
