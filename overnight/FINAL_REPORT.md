# Trade Empire Rush — Informe Final del Overnight (rondas 6–10)

> Fine-tuning ronda 10 (2026-07-05 07:50). Cubre las 5 rondas desde
> el último fine-tuning (r5). El prompt template dice "5 rondas" —
> este informe analiza las rondas 6 a 10 inclusive.

## Fase alcanzada

- **Fase al final de la ronda 10**: **A (construyendo MVP)**.
- **Justificación**: Capa 1 (GODOT-1/2/3), Capa 1.5 (EXP-1 export
  HTML5) y Capa 2 (LOOP-1..9) están completas y commiteadas en r8.
  Capa 3 (contenido MVP) se intentó en r9 (BIZ-1) y r10 (BIZ-1/2/3)
  pero TODO el trabajo se perdió por el anti-patrón
  `Reset-FailedIteration` del controller. El último commit real es
  `5655653 overnight: ronda 8 iter 1 (WIP)`. No hay `business.gd` ni
  `Business.tscn` en disco. La capa 3 está en 0% en git.
- **¿Avanzó A → B → C correctamente?**: NO — se quedó en A. No
  avanzó a B (pulido) porque ni siquiera cerró capa 3 (contenido).
- **¿Se saltó la Fase B (pulido)?**: NO aplica — no llegó a B. Pero
  el riesgo existe: si la próxima ronda salta a juice/eventos antes
  de cerrar BIZ-1..5, estaría saltándose el contenido base (anti-
  patrón "contenido antes del loop" invertido: "juice antes del
  contenido").

## Estado del MVP

### Lo que se construyó (commiteado en git, verificado)

- **Capa 1 — Engine + proyecto base**: Godot 4.3 portable en
  `godot/godot.exe`, `project.godot` válido, autoloads `Economy` +
  `GameManager`, `Main.tscn` arranca sin crash.
- **Capa 1.5 — Gate export HTML5**: `export_presets.cfg` (preset
  "HTML5"), `exports/html5/index.html` + index.js (331KB) +
  index.wasm (35MB) + index.pck (62KB). Export-release funciona sin
  errores. Templates web instaladas en
  `%APPDATA%/Godot/export_templates/4.3.stable/`.
- **Capa 2 — Loop base (9 items)**:
  - LOOP-1: Player (CharacterBody2D, WASD, accel/friction, bob +
    squash/stretch placeholder).
  - LOOP-2: Cámara (GameCamera, smoothing exponencial + look-ahead).
  - LOOP-3: Pickup (Area2D, stock regenera, recoger con E, carry
    capacity 3, indicador visual CarriBox).
  - LOOP-4: Shelf (Area2D, fill con E consume carried, API
    take_item/has_stock, señal stock_changed).
  - LOOP-5: Client (FSM to_shelf→browse→to_exit, suelta MoneyDrop)
    + ClientSpawner (spawn cada 3s, max 5, asigna shelf aleatorio).
  - LOOP-6: MoneyDrop (Area2D, value, pop-in tween, Economy.add_cash
    al recoger).
  - LOOP-7: UnlockPad (Area2D, zone_id, price, pulso amarillo,
    prompt E, API try_unlock, señal unlocked).
  - LOOP-8: HUD (CanvasLayer, CashLabel/EmpireLabel/MissionLabel,
    pop de scale al cambiar cash).
  - LOOP-9: MissionGuide (Node, 4 beats: FILL_SHELF→COLLECT_MONEY→
    UNLOCK_ZONE→HIRE_HELP, avanza por señales, no bloquea input).

### Lo que NO se construyó (pendiente en ROADMAP)

- **Capa 3 — Contenido MVP**: BIZ-1 (puesto ropa), BIZ-2 (perfumes),
  BIZ-3 (mini market), BIZ-4 (taller/fábrica), BIZ-5 (almacén).
  BIZ-1/2/3 se implementaron 2 veces (r9, r10) pero se perdieron.
- **Capa 4 — Automatización**: AUTO-1 (cajero), AUTO-2 (reponedor),
  UPG-1..5 (upgrades), EMP-1 (rareza empleados).
- **Capa 5 — Eventos + ranking + monetización + save + juice**:
  EVT-1/2/3, RNK-1, MON-1/2, SAVE-1, OFF-1, JUICE-1/2.
- **Capa 6 — Landing + métricas**: EXP-2 (landing), MET-1 (telemetría).
- **Fase B — Pulido**: POLISH-1..10 (todos pendientes).
- **Fase C — Versión 1.0+**: V1-1..23 (todos pendientes).

### Export HTML5

- **Estado**: OK
- **Ruta**: `exports/html5/index.html`
- **Verificado**: 2026-07-05 07:50 — headless `--quit-after 60` OK
  (Player, 2 Pickups, 2 Shelves, ClientSpawner, HUD, MissionGuide,
  2 Pads cargan sin crashes).

### Cómo probarlo

```powershell
# Headless (valida boot sin crash)
D:\empire-rush\godot\godot.exe --headless --path D:\empire-rush --quit-after 60

# Smoke con DEVIN_SMOKE=1 (pre-llena estantes, da cash, desbloquea pad)
$env:DEVIN_SMOKE=1; D:\empire-rush\godot.exe --headless --path D:\empire-rush --quit-after 60

# Abrir en navegador (MVP jugable)
start D:\empire-rush\exports\html5\index.html

# Re-exportar HTML5
D:\empire-rush\godot\godot.exe --headless --path D:\empire-rush --export-release "HTML5" D:\empire-rush\exports\html5\index.html
```

## ¿Es adictivo desde el primer minuto? (honesto)

- **Loop se siente**: **PARCIAL**. El cimiento está conectado en
  código (recoger→estante→cliente→dinero→recoger→pad→desbloquear)
  y funciona en headless + navegador, pero le falta todo el "feel".
- **Satisfacción táctil**: **MALA**. Recoger dinero no tiene
  partículas ni sonido (solo un pop-in tween del MoneyDrop). El
  cash no vuela al HUD. No hay screen shake al desbloquear. La
  regla de oro del AGENTS.md ("satisfacción táctil al recoger
  dinero") NO se cumple.
- **Progreso visible**: **PARCIAL**. El HUD muestra cash/EV en
  tiempo real, pero solo hay 1 negocio activo (ropa, $5) y 2 pads.
  No hay sensación de "el imperio crece". Los pads tienen pulso
  amarillo pero no glow fuerte.
- **Meta cercana siempre visible**: **PARCIAL**. MissionGuide
  muestra texto guía, pero el 4to beat (HIRE_HELP) no tiene
  empleado real. Solo 2 pads ($50, $120) — después de desbloquear
  los 2, no hay meta cercana visible.
- **Primer minuto (§25)**:
  - 0–10s "Llena tu primer estante": **PARCIAL** — el texto aparece
    pero el jugador debe descubrir que hay que ir al Pickup, recoger
    con E, ir al Shelf, llenar con E. Sin flechas ni highlight.
  - 10–20s "Recoge tu dinero": **PARCIAL** — el cliente suelta
    MoneyDrop, pero sin partículas ni sonido el feedback es débil.
  - 20–35s "Invierte para crecer": **OK** — el pad tiene pulso +
    prompt E + precio visible. Es lo mejor del loop actual.
  - 35–60s "Contrata ayuda": **FAIL** — no hay empleado (AUTO-1
    pendiente). El beat HIRE_HELP queda colgado.
- **Cómo se siente (§26)**: **LENTO y MONÓTONO**. Con 1 negocio y
  clientes cada 3s, no hay caos. "Cada 10 segundos pasa algo" se
  cumple a medias (llega un cliente, suelta dinero) pero sin juice
  no se siente satisfactorio. "Cada 1 minuto desbloquea algo" SÍ se
  cumple (pad $50 alcanzable en ~1 min).
- **Qué es adictivo (§32)**: **Dinero visible** SÍ (MoneyDrop
  físico + HUD). **Desbloqueo constante** PARCIAL (solo 2 pads).
  **Progreso visual inmediato** NO (sin partículas, sin cambios
  visuales al mejorar). **Automatización** NO. **Eventos** NO.
- **Qué cansa (§33)**: **Repetición excesiva** — con 1 negocio el
  loop es recoger→estante→esperar cliente→recoger dinero, sin
  variación. **Todo se ve igual** — placeholders ColorRect sin
  diferenciación visual entre negocios (porque solo hay 1).
- **Veredicto**: **"Necesita 3–5 rondas más de pulido + contenido
  en X"**. El MVP NO es adictivo todavía. El cimiento es sólido
  (código limpio, headless-safe, export verde) pero le falta:
  (1) contenido (3 negocios + taller + almacén), (2) juice
  (partículas, sonido, fly-to-HUD, screen shake), (3) empleados
  (para cerrar el 4to beat del primer minuto), (4) balance. NO
  lanzar todavía.

## Cómo puedo mejorar el MVP (recomendaciones accionables)

Ordenadas por impacto/esfuerzo (impacto en adicción/retención):

1. **Re-hacer BIZ-1/2/3 (3 negocios) en 1 iteración** — El patrón
   `Business` (Node2D contenedor con product_value, start_locked,
   unlock_zone_id) ya está validado en r10 log. 3 negocios rompen
   la monotonía y dan desbloqueo constante. — **Esfuerzo: S** (1
   iter, ya hecho 2 veces).
2. **FIX del controller (commit WIP cada 10 min + timeout 90 min)**
   — Sin esto, toda iteración futura se pierde. Es el bloqueante
   #1. — **Esfuerzo: S** (fix de `session.ps1`/`run_overnight.ps1`).
3. **JUICE-1: partículas + sonido al recoger dinero** — La regla
   de oro del AGENTS.md. Es lo que más impacta la "satisfacción
   táctil". Sonido placeholder + 5 partículas + tween scale. —
   **Esfuerzo: S**.
4. **POLISH-2: tween de cash volando al HUD al recoger** — Refuerza
   "dinero visible" (§32.3). El jugador ve de dónde viene el cash. —
   **Esfuerzo: S**.
5. **AUTO-1: empleado cajero** — Cierra el 4to beat del primer
   minuto (HIRE_HELP). La transición "yo trabajo → mi imperio
   trabaja" (§32.5) es lo que engancha a mediano plazo. —
   **Esfuerzo: M**.
6. **BIZ-4: mini taller/fábrica** — Añade la mecánica de producción
   (materia prima → máquina → producto). Rompe la repetición de
   solo recoger/vender. — **Esfuerzo: M**.
7. **POLISH-6: balance de precios** — Ajustar para meta corta cada
   1–2 min (§32.2). Hoy $50 y $120 son alcanzables rápido pero sin
   curva exponencial. — **Esfuerzo: S**.
8. **POLISH-4: glow/pulso fuerte en pads de desbloqueo** — Los pads
   son la meta cercana visible (§32.2). Hoy tienen pulso amarillo
   débil. Un glow fuerte + escala pulsante los hace irresistibles. —
   **Esfuerzo: S**.
9. **SAVE-1: guardado local** — Sin save, el jugador pierde todo al
   cerrar. `user://save.json` vía FileAccess. — **Esfuerzo: S**.
10. **EVT-1: evento "Rush Hour" (60s, 2x clientes)** — Eventos
    sorpresa (§32.7) rompen la monotonía. 60s de caos controlado. —
    **Esfuerzo: S**.
11. **POLISH-7: spawn rate de clientes ajustado** — Hoy 1 cada 3s
    es lento. Para "caos" en segundo 35–60 necesita 2x o 3x. —
    **Esfuerzo: S**.
12. **RNK-1: ranking simple local (30 bots)** — Competencia
    aspiracional (§32.6). Ver a otros "jugadores" con Empire Value
    más alto motiva. — **Esfuerzo: M**.
13. **UPG-1: upgrade de velocidad del jugador** — Primera mejora
    permanente visible. Refuerza "progreso visual inmediato" (§32.1). —
    **Esfuerzo: S**.
14. **BIZ-5: mini almacén** — Conecta el loop con logística básica.
    Donde se acumula stock antes de mover a estantes. — **Esfuerzo: S**.
15. **POLISH-1: feedback visual + sonoro al llenar estante** —
    Llenar un estante hoy no tiene feedback. Un pop + sonido al
    llenar refuerza el loop recoger→estante. — **Esfuerzo: S**.

## Qué más puedo hacer (roadmap a versión 1.0 y más allá)

### Versión 1.0 (post-MVP) — Fase C

Cerrar el MVP primero (BIZ-1..5 + AUTO-1/2 + JUICE-1 + SAVE-1 +
EVT-1 + RNK-1 + EXP-2 + balance + smoke visual en navegador). Luego:

- **V1-1: Farmacia** (negocio nuevo, §8 Negocio 3) — cuidado
  personal, vitaminas ficticias, higiene, belleza.
- **V1-2: Electrónica** (§8 Negocio 5) — celulares, audífonos,
  consolas ficticias, tablets.
- **V1-3: Fábrica avanzada** (§8 Negocio 6 expandido) — materia
  prima → máquina → caja → camión.
- **V1-4: Bodega + logística + camión** (§8 Negocio 7) — cajas,
  pallets, camiones, rutas.
- **V1-5: Puerto + contenedores** (§6 Etapa 5) — llegada de
  contenedores, descarga, distribución.
- **V1-6: Segunda ciudad** (§6 Etapa 7) — sucursales, gerentes
  regionales, logística inter-ciudad.
- **V1-7: Ligas semanales completas** (§10) — 8 ligas, 30–50
  jugadores, premios semanales.
- **V1-8: Sistema de estatus/títulos** (§11) — 9 títulos que
  desbloquean ropa/oficina/vehículos.
- **V1-9: Personalización del personaje** (§12).
- **V1-10: Empleados premium** (§13, §30 D) — cajero rápido, gerente
  experto, influencer, etc.
- **V1-14: Monetización real IAP** (§30 A–H) — gems, remove ads,
  starter pack.
- **V1-15: Ads recompensados reales (AdMob)**.
- **V1-16: Daily Login + Daily Missions + Weekly Goals** (§38).
- **V1-17: Eventos globales** (§36) — Global Trade Fair, Black
  Friday Rush, Factory Madness.
- **V1-21: Export Android (APK/AAB) + Google Play Console**.
- **V1-22: Export iOS + App Store Connect**.
- **V1-23: Guardado en la nube** (sync entre dispositivos).

### Versión 2.0

- Farmacia + electrónica + fábrica avanzada + puerto + contenedores
  (si no se cerraron en 1.0).
- Segunda ciudad + clanes + visitar imperios + eventos globales.
- Empleados raros + skins premium + IA para eventos diarios (§18).
- Suscripción VIP opcional (§30 H).
- Mall / centro comercial (§8 Negocio 8) — comprar locales, rentar.

### Versión 3.0

- Países (Dubai, Tokio, Miami, París, Panamá, Estambul — §6 Etapa 8).
- Bienes raíces + franquicias.
- Ranking mundial avanzado + ligas + temporadas por país.
- Conglomerados (clanes) + colaboración entre jugadores.
- Personalización avanzada de marca.

### Lanzamiento mobile (Android/iOS)

Pasos concretos una vez cerrado el MVP web:

1. **Export presets Android**: en Godot, crear preset "Android"
   (platform Android). Requiere Android SDK + JDK + keystore.
2. **Keystore**: generar con `keytool -genkey -v -keystore
   empire.keystore -alias empire -keyalg RSA -keysize 2048
   -validity 10000`. Guardar seguro (NO commitear).
3. **Google Play Console**: cuenta de desarrollador ($25 una vez).
   Subir AAB (Android App Bundle, no APK) a Play Console Internal
   Testing → Closed Testing → Open Testing → Production.
4. **App Store Connect**: cuenta Apple Developer ($99/año). Subir
   IPA vía Xcode/Transporter o App Store Connect API. Requiere
   macOS para firmar.
5. **IAP (in-app purchases)**: Godot no tiene IAP nativo → usar
   plugin `GodotGooglePlayBilling` (Android) + `GodotAppleIap`
   (iOS). Configurar productos en Play Console / App Store Connect.
6. **Ads reales**: integrar AdMob vía plugin Godot (ej:
   `Poing-Studios/admob`). Solo recompensados al inicio (§30.1).
7. **Ranking real**: backend simple (Firebase / Supabase) para
   sync de Empire Value entre dispositivos. Empezar con
   Realtime Database (free tier).
8. **Login**: Google Play Games Services (Android) + Game Center
   (iOS) para auth sin fricción. O Firebase Auth anónimo + upgrade
   a email/Google.
9. **Cloud save**: sync de `user://save.json` a Firebase/Supabase.
   Conflict resolution: last-write-wins al inicio, luego merge por
   timestamp.
10. **Comunidad**: empezar con ranking global + perfiles públicos
    (§34). Clanes (§34 Conglomerates) en 2.0+.
11. **Store listings**: screenshots, icono, descripción ASO
    (App Store Optimization), video trailer. Apto para todas las
    edades (PEGI 3 / Everyone) — sin violencia, sin apuestas, sin
    contenido adulto (§16).
12. **Soft launch**: lanzar en 1–2 países pequeños (ej: Panamá,
    Uruguay) para medir retención D1/D7/D30 antes de global.

## Métricas a medir desde el día 1

Según BLUEPRINT §23. Implementar con telemetría local (MET-1,
consola) primero, luego remote (Firebase Analytics / Mixpanel):

- **Tutorial completion** (MissionGuide DONE step): % de jugadores
  que llegan a HIRE_HELP. Meta: >80%.
- **Tiempo de primera sesión**: timestamp al entrar + al salir.
  Meta: >8 min.
- **Sesiones por día**: count de opens por día (requiere SAVE-1).
- **Retención D1/D3/D7**: % de jugadores que vuelven día 1/3/7.
  Meta: D1 >35%, D7 >10%.
- **Ads vistos por usuario activo/día**: count de ads recompensados
  vistos. Meta: mínimo 3.
- **Compras por usuario** (post-IAP): ARPU.
- **Nivel donde abandonan**: último beat de MissionGuide alcanzido
  + último negocio desbloqueado. Identifica fricción.
- **Zonas más desbloqueadas**: count de unlocks por zone_id.
- **Eventos más jugados**: count de EVT-1/2/3 completados.
- **Empleados más usados**: count de contrataciones por empleado.

Implementación: un singleton `Metrics` (autoload) que loguea a
`user://metrics.json` + `print()` en consola. Cada evento llama
`Metrics.track("event_name", payload)`. En 1.0+, subir a backend.

## Riesgos y mitigaciones

- **Riesgo #1 — Controller destruye trabajo (CRÍTICO)**: el
  anti-patrón `Reset-FailedIteration` ha tirado ~270 min de compute
  (r3/r4/r5 + r6/r9/r10). **Mitigación**: fixear `session.ps1` para
  commitear WIP cada 10 min + subir timeout a 90 min + `git reset`
  solo al START de cada ronda (después de commitear WIP previo).
  Sin este fix, el overnight es inútil.
- **Riesgo #2 — Devin huérfano concurrente**: 3 devin.exe vivos
  en r10 sobrescribiendo archivos. **Mitigación**: `taskkill //F
  //IM devin.exe` al START de cada sesión.
- **Riesgo #3 — MVP no es adictivo**: el loop funciona pero no
  engancha. **Mitigación**: priorizar JUICE-1 + contenido (BIZ-1..5)
  antes de features avanzadas. Smoke visual en navegador cada
  iteración (no solo headless).
- **Riesgo #4 — Saltar Fase B (pulido)**: tentación de ir a eventos
  /ranking antes de pulir el feel. **Mitigación**: gate explícito:
  no tocar capa 5 hasta que capa 3+4 estén cerradas Y el loop se
  sienta bien en navegador (smoke manual humano).
- **Riesgo #5 — Performance web**: el .wasm es 35MB. En mobile
  web puede ser lento. **Mitigación**: medir FPS en navegador
  de gama baja (ej: Chrome mobile emulation). Optimizar si <30 FPS.
- **Riesgo #6 — Balance roto**: sin playtesting, los precios
  ($50/$120) pueden ser muy fáciles o muy duros. **Mitigación**:
  POLISH-6 + smoke manual midiendo tiempo al primer desbloqueo.
- **Riesgo #7 — Sin save = sin retención**: el jugador pierde todo
  al cerrar. **Mitigación**: SAVE-1 antes de lanzar.
- **Riesgo #8 — Export mobile rompe el MVP**: añadir Android/iOS
  puede romper el export web. **Mitigación**: mantener el preset
  HTML5 verde en cada iteración, separar builds.

## Próximos pasos recomendados (esta semana)

1. **FIX del controller** (bloqueante #1, no es item de ROADMAP):
   editar `overnight/session.ps1` para commitear WIP cada 10 min +
   `overnight/run_overnight.ps1` para timeout 90 min + `git reset`
   al START de cada ronda + `taskkill //F //IM devin.exe` al START.
   Sin esto, la próxima ronda overnight perderá el trabajo otra vez.
2. **Re-hacer BIZ-1/2/3** (1 iteración, patrón `Business` validado
   en r10 log): 3 negocios (ropa $5, perfume $15, market $3) con
   pickups/shelves hijos + reutilizar pads existentes como gate.
3. **JUICE-1 + POLISH-2**: partículas + sonido placeholder al
   recoger dinero + tween de cash volando al HUD. Es lo que más
   impacta la "satisfacción táctil" de la regla de oro.
4. **BIZ-4 (taller) + BIZ-5 (almacén)**: cerrar capa 3.
5. **AUTO-1 (empleado cajero)**: cierra el 4to beat del primer
   minuto (HIRE_HELP).
6. **Smoke visual en navegador**: abrir `exports/html5/index.html`
   y validar el primer minuto contra §25. Si no engancha, iterar
   POLISH-6/7 (balance + spawn rate) antes de seguir.
