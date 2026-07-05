# Trade Empire Rush — ROADMAP

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

- [ ] **GODOT-1** (P0, S) — Descargar Godot 4.3 portable a
  `D:\empire-rush\godot\godot.exe`. Usar Godot 4.3 stable .NET o
  standard (sin .NET, GDScript puro para el MVP). Verificar con
  `godot.exe --version`. Si ya existe, saltar. Criterio: `godot.exe
  --version` responde desde `D:\empire-rush\godot\`.
- [ ] **GODOT-2** (P0, S) — Validar `project.godot` abriendo el
  proyecto headless: `godot.exe --headless --path D:\empire-rush
  --check-only`. Fixear cualquier error de config. Criterio: Godot
  carga el proyecto sin errores.
- [ ] **GODOT-3** (P0, S) — Crear `scenes/Main.tscn` (escena raíz
  vacía con un Node2D "World" y una Camera2D). Configurar
  `run/main_scene=res://scenes/Main.tscn` (ya está). Criterio:
  `godot.exe --path D:\empire-rush scenes/Main.tscn` abre sin errores.

### Capa 2 — Loop base (recoger → vender → cobrar → invertir)

- [ ] **LOOP-1** (P0, M) — Personaje jugador controlable.
  `scripts/game/player.gd` + escena `scenes/Player.tscn`. Movimiento
  top-down con WASD/joystick virtual (mobile). Animación idle/walk
  (puede ser sprite placeholder o ColorRect rotando). Criterio: el
  personaje se mueve por el mapa con WASD en el editor.
- [ ] **LOOP-2** (P0, M) — Cámara isométrica/top-down que sigue al
  jugador. `scripts/game/camera.gd`. Zoom out suficiente para ver
  puesto + zona bloqueada cercana. Criterio: la cámara sigue al
  jugador suavemente.
- [ ] **LOOP-3** (P0, M) — Producto recogible. Nodo "Pickup" en el
  mapa (sprite placeholder). Al estar el jugador cerca y presionar
  E (o auto-recoger por proximidad), el jugador "carga" 1 unidad.
  Indicador visual sobre el jugador de cuánto carga. Criterio: el
  jugador recoge producto y se ve el contador.
- [ ] **LOOP-4** (P0, M) — Estante/mostrador reponible. Al estar
  cerca con producto cargado, presionar E llena el estante (+1
  stock, hasta capacity). Visual: el estante muestra fill level.
  Criterio: el estante se llena al interactuar.
- [ ] **LOOP-5** (P0, M) — Cliente NPC. Spawn periódico, camina a la
  fila, espera, si hay stock compra (consume 1 stock), deja dinero
  físico en el piso, se va. Criterio: un cliente completa el ciclo
  spawn → fila → compra → dinero → despawn.
- [ ] **LOOP-6** (P0, M) — Dinero físico recogible. Billete/montón
  en el piso con valor. Al recoger, suma al contador de Cash del
  jugador (autoload `Economy`). Sonido placeholder + animación
  volando al HUD. Criterio: recoger dinero sube el contador visible.
- [ ] **LOOP-7** (P0, M) — Pad de desbloqueo. Zona bloqueada con
  precio visible. Al estar cerca con Cash ≥ precio, presionar E
  desbloquea (descuenta Cash, activa la zona). Criterio: se
  desbloquea una zona pagando.
- [ ] **LOOP-8** (P0, S) — HUD base. Contador de Cash, contador de
  Empire Value, indicador de misión actual (texto). Esquina superior
  izquierda. Criterio: el HUD muestra Cash y Empire Value en tiempo
  real.
- [ ] **LOOP-9** (P0, S) — Primer minuto guiado (sin tutorial
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

### Capa 6 — Export HTML5 + landing + métricas

- [ ] **EXP-1** (P0, M) — Export HTML5 del MVP. Configurar preset
  `export_presets.cfg` para HTML5. Exportar a
  `exports/html5/index.html`. Criterio: `exports/html5/index.html`
  abre en navegador y el juego corre.
- [ ] **EXP-2** (P1, S) — Landing page mínima (`exports/html5`
  sirve el juego + un index con título "Trade Empire Rush" y botón
  "Jugar"). Criterio: la landing carga el juego.
- [ ] **MET-1** (P2, S) — Telemetría local (consola) de métricas
  del blueprint: tiempo de primera sesión, zonas desbloqueadas,
  eventos jugados, ads vistos. Criterio: las métricas se loguean.

---

## 📦 Completados

(vacío — los items se mueven aquí al cerrarse)

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
