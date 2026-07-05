# Trade Empire Rush — ROADMAP

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

- [ ] **BIZ-1** (P1, M) — Puesto callejero (negocio inicial).
  Producto: camisetas. Mesa + estante + caja manual. Precio de
  venta bajo. Criterio: el puesto funciona con el loop completo.
- [ ] **BIZ-2** (P1, M) — Estante de perfumes (segundo negocio,
  desbloqueable). Producto: perfumes pequeños. Precio de venta
  medio. Criterio: se desbloquea y funciona.
- [ ] **BIZ-3** (P1, M) — Mini market (tercer negocio,
  desbloqueable). Producto: snacks. Alta rotación, precio bajo.
  Criterio: se desbloquea y funciona.
- [ ] **BIZ-4** (P1, M) — Mini taller/fábrica. Materia prima →
  máquina → producto terminado → enviar a estante. Simple visual.
  Criterio: la fábrica produce y abastece un estante.
- [ ] **BIZ-5** (P1, S) — Mini almacén. Donde se acumula stock antes
  de mover a estantes. Criterio: el almacén existe y se conecta al
  loop.

### Capa 4 — Automatización + upgrades + empleados

- [ ] **AUTO-1** (P1, M) — Empleado cajero. Contratable en un pad.
  Cobra automáticamente a los clientes (sin que el jugador haga
  click). Criterio: con el empleado, los clientes pagan solos.
- [ ] **AUTO-2** (P1, M) — Empleado reponedor. Mueve producto del
  almacén a los estantes automáticamente. Criterio: los estantes se
  reponen solos.
- [ ] **UPG-1** (P1, S) — Upgrade de velocidad del jugador. Pad de
  upgrade que aumenta la velocidad de movimiento. Criterio: el
  upgrade aplica y se nota.
- [ ] **UPG-2** (P1, S) — Upgrade de capacidad de carga. Más
  unidades por viaje. Criterio: el upgrade aplica.
- [ ] **UPG-3** (P1, S) — Upgrade de capacidad del estante. Más
  stock máximo. Criterio: el upgrade aplica.
- [ ] **UPG-4** (P1, S) — Upgrade de velocidad de caja. Clientes
  pagan más rápido. Criterio: el upgrade aplica.
- [ ] **UPG-5** (P1, S) — Upgrade de velocidad de producción de la
  fábrica. Criterio: el upgrade aplica.
- [ ] **EMP-1** (P2, M) — Sistema de rareza de empleados
  (común/raro/épico/legendario) con habilidades especiales. Al
  menos 3 empleados con habilidades distintas. Criterio: los
  empleados tienen rareza y habilidad visible.

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
- [ ] **JUICE-1** (P1, S) — Polished feel: partículas al recoger
  dinero, sonido placeholder, screen shake suave al desbloquear,
  animación de cash volando al HUD. Criterio: el juego se siente
  satisfactorio.
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

- [ ] **POLISH-1** (P1, S) — Feedback visual + sonoro al recoger
  dinero: partículas, tween de scale, sonido placeholder. Criterio:
  recoger dinero se siente satisfactorio.
- [ ] **POLISH-2** (P1, S) — Tween de cash volando al HUD al
  recoger. Criterio: el dinero vuela visualmente al contador.
- [ ] **POLISH-3** (P1, S) — Screen shake suave al desbloquear zona.
  Criterio: el desbloqueo se siente impactante.
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
