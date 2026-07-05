# Trade Empire Rush — Informe Final del Overnight (rondas 11–15)

> Fine-tuning ronda 15 (2026-07-05 08:53). Cubre las 5 rondas desde
> el último fine-tuning (r10). Total acumulado: 15 rondas overnight.

## Fase alcanzada
- **Fase al final de la ronda 15**: **A (construyendo MVP)** — capa 4
  casi cerrada (solo EMP-1 pendiente), capa 5/6/Fase B/Fase C sin tocar.
- **Justificación**: el overnight respetó el orden de capas. Tras
  cerrar capa 2 + EXP-1 (r8), hizo capa 3 (BIZ-1..5 en r11/r12) y
  capa 4 (AUTO-1/2 + UPG-1..5 en r13/r14/r15). Queda EMP-1 (capa 4)
  + toda capa 5 (eventos/ranking/monetización/save/offline/juice) +
  capa 6 (landing/métricas) antes de pasar a Fase B (pulido).
- **¿Avanzó A → B → C correctamente?**: NO avanzó a B todavía — está
  bien, sigue en A porque capa 4/5/6 no están cerriertas. El orden
  se respeta.
- **¿Se saltó la Fase B (pulido)?**: NO (todavía). No ha llegado a B.
  Riesgo: si la próxima ronda salta a Fase C (V1-*) sin cerrar capa 5
  + Fase B, sería anti-patrón CRÍTICO. El ROADMAP re-priorizado
  bloquea esto explícitamente.

## Estado del MVP
### Lo que se construyó (15 rondas acumuladas)

**Capa 1 — Engine + proyecto base** (r1):
- Godot 4.3 portable en `godot/godot.exe`.
- `project.godot` con autoloads `Economy` + `GameManager`.
- `scenes/Main.tscn` con World + Camera2D.

**Capa 1.5 — Gate export HTML5** (r8):
- `export_presets.cfg` preset "HTML5".
- `exports/html5/index.html` + index.pck (108KB) + index.wasm (35MB).

**Capa 2 — Loop base** (r1-r8): 9 items completados.
- Player (CharacterBody2D, WASD, bob + squash/stretch).
- Camera (smoothing exponencial + look-ahead).
- Pickup (Area2D, stock regen, recoger con E, carry capacity 3).
- Shelf (Area2D, fill con E, take_item, stock_changed).
- Client (FSM to_shelf→browse→buy→money drop→exit, browse_time 0.5s).
- ClientSpawner (spawn cada 3s, max 5, filtra shelves locked).
- MoneyDrop (Area2D, value, pop-in tween, Economy.add_cash).
- UnlockPad (zone_id, price, pulso amarillo, try_unlock).
- HUD (CashLabel/EmpireLabel/MissionLabel, pop de scale al cambiar cash).
- MissionGuide (FILL_SHELF→COLLECT_MONEY→UNLOCK_ZONE→HIRE_HELP→DONE).

**Capa 3 — Contenido MVP** (r11-r12): 5 items completados.
- BIZ-1 Puesto callejero (camisetas $5, unlocked, tint verde).
- BIZ-2 Perfumes ($15, locked, zone_perfume $120, tint rosa).
- BIZ-3 Mini market snacks ($3, alta rotación, locked, zone_snacks $400).
- BIZ-4 Mini taller/fábrica (raw→máquina→output, zone_factory $250,
  production_time 3s, output_capacity 8, Shelf hijo).
- BIZ-5 Mini almacén (buffer stock/capacity 20, deposit/withdraw con E,
  zone_warehouse $600).

**Capa 4 — Automatización + upgrades** (r13-r15): 7 items completados.
- AUTO-1 Cajero (3 instancias, cobra auto sin MoneyDrop, gate por
  negocio locked, $100/$200/$150).
- AUTO-2 Reponedor (3 instancias, retira del Warehouse y deposita en
  estante con más déficit, wall-clock timer, $120/$240/$180).
- UPG-1 Speed (+12% move_speed por nivel, base $80).
- UPG-2 Carry (+2 carry_capacity por nivel, base $120).
- UPG-3 ShelfCap (+3 capacity a todos los estantes, base $150).
- UPG-4 CashierSpeed (-15% browse_time por nivel, base $180).
- UPG-5 Production (-10% production_time por nivel en fábricas, base $200).

### Lo que NO se construyó (pendiente)

- **EMP-1** — Sistema de rareza de empleados (capa 4, M).
- **Capa 5 entera**: EVT-1/2/3 (eventos), RNK-1 (ranking), MON-1/2
  (ads/tienda placeholders), SAVE-1 (guardado), OFF-1 (offline
  earnings), JUICE-1/2 (juice + audio).
- **Capa 6**: EXP-2 (landing), MET-1 (telemetría).
- **Fase B (POLISH-1..10)**: feedback visual/sonoro, cash fly-to-HUD,
  screen shake, glow pads, meta cercana visible, balance, spawn rate,
  animación clientes, música, tutorial pulido.
- **Fase C (V1-1..23)**: farmacia, electrónica, fábrica avanzada,
  bodega+logística, puerto, segunda ciudad, ligas, títulos,
  personalización, empleados premium, skins, pase de temporada,
  cofres, IAP, ads reales, daily login, eventos globales, logros,
  fatiga, perfil público, export Android/iOS, cloud save.
- **FASE 2 (GATE-1..3, MOB-1..3)**: gates de calidad pre-1.0,
  mobile readiness.

### Export HTML5
- **Estado**: OK
- **Ruta**: `D:\empire-rush\exports\html5\index.html` (4.8KB) +
  `index.pck` (108KB) + `index.wasm` (35MB) + `index.js` (331KB).
- **Verificado**: 2026-07-05 08:51 en este fine-tuning. Headless run
  OK: 5 businesses, 4 locked, factory + warehouse, 3 cashiers, 3
  stockers, 5 upgrade pads, HUD, MissionGuide, 5 pads cargan sin crash.

### Cómo probarlo
```powershell
# Headless (valida boot sin crash)
D:\empire-rush\godot\godot.exe --headless --path D:\empire-rush --quit-after 60

# Smoke con DEVIN_SMOKE=1 (valida lógica del loop)
$env:DEVIN_SMOKE=1; D:\empire-rush\godot\godot.exe --headless --path D:\empire-rush --quit-after 12000

# Export HTML5 (regenera el build)
D:\empire-rush\godot\godot.exe --headless --path D:\empire-rush --export-release "HTML5" D:\empire-rush\exports\html5\index.html

# Abrir en navegador
start D:\empire-rush\exports\html5\index.html

# Editor interactivo
D:\empire-rush\godot\godot.exe --path D:\empire-rush
```

## ¿Es adictivo desde el primer minuto? (honesto)

- **Loop se siente**: **PARCIAL** — la mecánica está conectada en
  código (recoger→estante→cliente→dinero→pad→desbloquear→cajero→
  reponedor→warehouse→fábrica→upgrades) y validada en headless, pero
  NO se validó en navegador con un humano. El "feel" real es
  hipótesis no verificada.
- **Satisfacción táctil**: **PARCIAL** — hay pops de scale (tweens)
  en pickup/shelf/client/money_drop/hud/pads/cashiers/stockers. PERO
  **0 partículas, 0 sonido, 0 cash-fly-to-HUD, 0 screen shake**. La
  regla de oro del AGENTS.md ("recoger dinero debe tener feedback
  visual + sonoro inmediato") NO se cumple. Recoger dinero hoy es
  un pop silencioso de un ColorRect verde.
- **Progreso visible**: **PARCIAL** — el HUD muestra cash + empire
  value + misión. Los pads pulsan. Los estantes muestran stock. PERO
  no hay "tienda más bonita" ni "empleado más rápido" visualmente
  distinguible (todos son ColorRects del mismo tamaño con tint
  distinto). §32.1 exige "cada mejora debe verse" — los upgrades
  (UPG-1..5) NO tienen feedback visual al comprar más allá del pop
  del pad.
- **Meta cercana siempre visible**: **PARCIAL** — hay 5 pads de
  desbloqueo + 3 cajeros + 3 reponedores + 5 upgrades visibles en el
  mapa. PERO el HUD NO muestra "próximo pad alcanzable" (POLISH-5
  pendiente). El jugador tiene que buscar visualmente la meta.
- **Primer minuto (§25)**: **NO verificado** — los 4 beats (0-10s
  llena estante, 10-20s primer cliente, 20-35s invierte, 35-60s caos
  + empleado) son hipótesis. El MissionGuide existe en código pero
  nunca se probó en navegador con timing real. GATE-3 pendiente.
- **Cómo se siente (§26)**: **PARCIAL** — "rápido/satisfactorio/
  progresivo" parcialmente (hay pops, hay progresión de cash). "Lleno
  de recompensas pequeñas" NO (sin partículas/sonido). "Cada 10s
  pasa algo" NO validado. "Cada 1min desbloquea algo" depende del
  balance (no validado).
- **Qué es adictivo (§32)**:
  - §32.1 Progreso visual inmediato: PARCIAL (pops, sin partículas).
  - §32.2 Metas cortas/medianas/largas: PARCIAL (pads visibles, sin
    ranking ni meta gigante visible).
  - §32.3 Dinero visible: PARCIAL (MoneyDrop al piso + HUD pop, sin
    volar al contador ni sonido).
  - §32.4 Desbloqueo constante: OK (5 pads + 3 cajeros + 3
    reponedores + 5 upgrades + factory + warehouse).
  - §32.5 Automatización progresiva: OK (cashier + stocker + factory
    = "mi imperio trabaja por mí" funcional).
  - §32.6 Competencia aspiracional: NO (sin ranking RNK-1).
  - §32.7 Eventos sorpresa: NO (sin EVT-1/2/3).
- **Qué cansa (§33)**:
  - §33.1 Repetición excesiva: RIESGO ALTO — sin eventos ni
    variación, el loop es monótono después de 2-3 min.
  - §33.2 Progreso demasiado lento: RIESGO MEDIO — balance no
    validado; precios actuales ($50-$600 pads, $80-$200 upgrades)
    pueden ser muy lentos o muy rápidos.
  - §33.3 Demasiados anuncios: N/A (sin ads aún).
  - §33.4 Pagar se siente obligatorio: N/A (sin IAP aún).
  - §33.5 Falta de meta grande: RIESGO ALTO — sin ranking ni "próxima
    ciudad" visible, no hay meta gigante.
  - §33.6 Todo se ve igual: RIESGO MEDIO — los 5 negocios son
    ColorRects con tint distinto, sin mecánica distintiva visible.
- **Veredicto**: **"Necesita 5-7 rondas más de pulido en juice +
  eventos + ranking + save + balance antes de lanzar."** El cimiento
  es sólido y completo, pero el "feel" adictivo NO está. El MVP no
  es "éxito desde el primer lanzamiento" todavía. La buena noticia:
  lo que falta es pulido (capa 5 + Fase B), no rework — la base
  técnica es estable y el export HTML5 funciona.

## Cómo puedo mejorar el MVP (recomendaciones accionables)

Ordenadas por impacto/esfuerzo (mayor impacto primero, esfuerzo S/M/L):

1. **JUICE-1 + POLISH-1: partículas + sonido al recoger dinero** —
   es la regla de oro del AGENTS.md y la brecha #1 hacia "adictivo".
   Recoger dinero hoy es silencioso. Con CPUParticles2D + un
   AudioStreamPlayer placeholder (sintetizado o libre), el loop
   cambia completamente. — Esfuerzo **S** (1 iter).
2. **POLISH-2: tween de cash volando al HUD al recoger** — §32.3
   exige "dinero volando al contador". Un tween del MoneyDrop al
   CashLabel del HUD + pop del label al impactar. Satisfacción
   inmediata visible. — Esfuerzo **S**.
3. **POLISH-3: screen shake suave al desbloquear zona** — el
   desbloqueo es el momento más épico del loop. Hoy es un pop
   silencioso. Un shake de cámara (tween de offset) + flash de
   pantalla lo hace impactante. — Esfuerzo **S**.
4. **EVT-1: evento "Rush Hour" (60s, 2x clientes)** — variación
   para evitar §33.1 repetición. Un timer global cada 60-90s activa
   2x spawn rate + banner "RUSH HOUR" + recompensa al terminar. —
   Esfuerzo **S**.
5. **EVT-2: evento "VIP Order" (cliente VIP, 3x pago si rápido)** —
   cliente dorado que aparece cada 45s, paga 3x si se atiende antes
   de un timer. Variación + emoción. — Esfuerzo **S**.
6. **RNK-1: ranking local con 30 bots** — §32.6 competencia
   aspiracional. 30 bots con Empire Value que sube con el tiempo,
   jugador sube/baja. Panel en HUD esquina sup-der. Meta gigante
   visible. — Esfuerzo **M**.
7. **SAVE-1: guardado local (localStorage en HTML5)** — retención
   básica. Sin save, el jugador pierde todo al refrescar. Usar
   `FileAccess` + `user://` en desktop, localStorage en web. Cash,
   EV, zonas, upgrades, empleados. — Esfuerzo **S**.
8. **POLISH-6 + GATE-3: balance de precios validado en navegador** —
   ajustar para meta cada 1-2 min. Validar los 4 beats de §25 con
   smoke manual en navegador. Hoy los precios son hipótesis. —
   Esfuerzo **M**.
9. **POLISH-5: indicador de "meta cercana" siempre visible en HUD** —
   "Próximo: Perfume $120" o "Upgrade Speed $128". Siempre hay una
   meta a la vista. §32.2 meta corta. — Esfuerzo **S**.
10. **POLISH-4: glow/pulso en pads de desbloqueo para llamar la
    atención** — los pads ya pulsan, pero un glow más pronunciado +
    flecha indicadora cuando el jugador tiene cash ≥ precio. —
    Esfuerzo **S**.
11. **EMP-1: rareza de empleados (común/raro/épico/legendario)** —
    cierra capa 4. Extender Cashier/Stocker con campo `rarity` +
    multiplicador de speed + color distintivo. 3+ empleados con
    habilidades. — Esfuerzo **M**.
12. **JUICE-2: música de fondo + SFX placeholders** — §26 "lleno de
    recompensas pequeñas" requiere audio. Música loop + SFX
    recoger/vender/desbloquear. Libres de licencia o sintetizados. —
    Esfuerzo **S**.
13. **POLISH-7: spawn rate de clientes ajustado para caos controlado** —
    hoy spawn cada 3s, max 5. Ajustar para que en Rush Hour haya
    caos y en normal sea manejable. — Esfuerzo **S**.
14. **POLISH-8: animación de clientes (idle/walk/compra)** — los
    clientes son ColorRects que se mueven. Un tween de "bob" al
    caminar + squash al comprar los hace sentir vivos. — Esfuerzo **S**.
15. **EXP-2: landing page mínima** — `exports/html5` sirve el juego
    + un index con título "Trade Empire Rush" + botón "Jugar". Para
    compartir el link. — Esfuerzo **S**.

## Qué más puedo hacer (roadmap a versión 1.0 y más allá)

### Versión 1.0 (post-MVP) — Fase C
Items ya en ROADMAP §FASE C. Prioridad real post-MVP:

- **V1-21 Export Android (APK/AAB) + Google Play Console** — el
  blueprint targeta mobile. Godot 4.3 exporta Android nativo. Setup:
  instalar Android export templates, configurar keystore, crear
  proyecto en Google Play Console, subir AAB a internal testing.
- **V1-22 Export iOS + App Store Connect** — Godot 4.3 exporta iOS.
  Requiere macOS + Xcode + cuenta Apple Developer ($99/año).
- **V1-14 IAP real (Godot in-app purchases)** — gems, remove ads,
  starter pack. Plugin Godot IAP para Android/iOS.
- **V1-15 Ads recompensados reales (AdMob)** — integrar AdMob via
  plugin Godot. Reemplaza MON-1 placeholder.
- **V1-16 Daily Login + Daily Missions + Weekly Goals** — retención
  día a día. Recompensa creciente, misiones, metas semanales.
- **V1-17 Eventos globales** — Global Trade Fair, Black Friday Rush,
  Factory Madness, Luxury Week. Variación de temporada.
- **V1-12 Pase de temporada mensual** — 30 días, misiones, skins,
  empleados, decoraciones, boosts. Monetización recurrente.
- **V1-23 Cloud save** — sync de progreso entre dispositivos. Backend
  (Firebase/Supabase) + auth.
- **V1-7 Ligas semanales completas** — 8 ligas, 30-50 jugadores por
  liga, premios semanales. Competencia real post-RNK-1.
- **V1-1 a V1-6 Contenido 1.0** — farmacia, electrónica, fábrica
  avanzada, bodega+logística+camión, puerto+contenedores, segunda
  ciudad. Escala el imperio.

### Versión 2.0
- Multijugador asíncrono real (ranking con otros jugadores reales,
  no bots).
- Subastas de empleados legendarios entre jugadores.
- Mercado de importación/exportación entre ciudades de distintos
  jugadores.
- Temporadas con leaderboard global reset.
- Clan/gremios de empresarios.

### Versión 3.0
- Modo "Imperio Mundial" con mapa global + países + aduanas + aranceles.
- Eventos globales en tiempo real (Black Friday simultáneo para todos).
- Esports de management (torneos de imperio más rentable en 24h).
- Modo historia/campaña con personajes y rivalidades.
- Real-time trading entre jugadores.

### Lanzamiento mobile (Android/iOS)
Pasos concretos:

**Android (más rápido, sin Mac):**
1. Instalar Android export templates en Godot (Editor → Manage
   Export Templates → Download).
2. Instalar Android SDK + JDK (Android Studio o command-line tools).
3. Configurar `keystore` (debug + release): `keytool -genkey -v
   -keystore release.keystore -alias empire_rush -keyalg RSA
   -keysize 2048 -validity 10000`.
4. Crear `export_presets.cfg` preset Android (APK + AAB).
5. Configurar package name `com.tuempresa.empirerush`, version, icons.
6. Crear proyecto en **Google Play Console** ($25 una vez).
7. Subir AAB a **Internal Testing** → Closed Testing → Open Testing
   → Production.
8. Integrar **AdMob** (plugin Godot) para ads recompensados reales.
9. Integrar **Google Play Billing** (plugin Godot IAP) para gems/
   remove ads/starter pack.
10. Configurar **Play Games Services** (login + leaderboards +
    achievements).
11. Listing de Play Store: screenshots, ícono, feature graphic,
    descripción, trailer.

**iOS (requiere Mac + cuenta Apple Developer):**
1. Mismo proyecto Godot, preset iOS.
2. Mac + Xcode + cuenta **Apple Developer** ($99/año).
3. Crear App ID en Apple Developer Portal.
4. Crear provisioning profile (development + distribution).
5. Exportar IPA desde Godot con provisioning profile.
6. Subir IPA a **App Store Connect** via Transporter o Xcode.
7. TestFlight para beta testing.
8. Integrar **AdMob** (plugin Godot iOS) para ads.
9. Integrar **StoreKit** (plugin Godot IAP) para gems/remove ads.
10. Integrar **Game Center** (login + leaderboards + achievements).
11. Listing de App Store: screenshots (6.7" + 5.5"), ícono 1024x1024,
    descripción, trailer, edad rating.

**Comunidad + live ops:**
- Discord/Reddit oficial desde el día 1.
- Roadmap público (este ROADMAP.md sirve).
- Changelog semanal.
- Eventos de temporada cada 4-6 semanas (V1-17).
- Hotfixes rápidos via Play Console / App Store Connect (review
  instantáneo para fixes críticos).
- Telemetría (MET-1 + backend Firebase/Supabase) para iterar con
  data real: D1/D7/D30 retention, session length, churn points,
  arpu, ad watch rate, IAP conversion.

## Métricas a medir desde el día 1
(Blueprint §22 + implementación)

- **Tiempo de primera sesión** — cuánto dura la primera partida
  antes de cerrar. Meta: >5 min. Implementación: MET-1 log al
  cerrar/ocultar tab + backend event.
- **D1/D7/D30 retention** — % de jugadores que vuelven día 1/7/30.
  Meta: D1 >40%, D7 >20%, D30 >10%. Implementación: backend
  (Firebase Analytics / Supabase) con user_id + first_open + daily
  active.
- **Zonas desbloqueadas por sesión** — cuántos pads desbloquea el
  jugador en su primera partida. Meta: ≥2. Implementación: MET-1
  hook en UnlockPad.unlocked.
- **Eventos jugados por sesión** — cuántos Rush Hour/VIP participa.
  Meta: ≥1. Implementación: hook en EVT-1/2 start.
- **Ads vistos por sesión** — ad watch rate. Meta: 30% de jugadores
  ven ≥1 ad. Implementación: hook en MON-1 boost.
- **IAP conversion** — % de jugadores que compran. Meta: 2-5%.
  Implementación: hook en V1-14 purchase.
- **ARPU/ARPPU** — revenue medio por usuario / por pagador.
- **Session length** — duración media. Meta: 8-15 min.
- **Churn points** — en qué momento abandonan. Implementación:
  funnel de eventos (boot → first_pickup → first_sell → first_unlock
  → first_hire → D1 return).
- **Crash rate** — % de sesiones que crashean. Meta: <1%. Godot
  envía crashes a Play Console / Crashlytics.
- **FPS medio en mobile** — performance. Meta: 60 FPS en mid-range
  Android. Implementación: MOB-3 profiler.

## Riesgos y mitigaciones

- **Riesgo: el loop no engancha sin juice** — Mitigación: priorizar
  JUICE-1 + POLISH-1/2/3 antes de cualquier feature nueva. Sin
  juice, todo el trabajo técnico no se traduce en adicción.
- **Riesgo: balance roto (progreso muy lento o muy rápido)** —
  Mitigación: GATE-3 + POLISH-6 con smoke manual en navegador
  validando §25 los 4 beats. Ajustar precios con data real post-
  lanzamiento.
- **Riesgo: "devin huérfano concurrente" siga en rondas futuras** —
  Mitigación: el controller DEBE hacer `taskkill //F //IM devin.exe`
  al START de cada sesión. Es la lección #1 de proceso no aplicada
  (6 rondas seguidas).
- **Riesgo: saltar a Fase C (V1-*) sin cerrar Fase A + B** —
  Mitigación: el ROADMAP re-priorizado bloquea esto explícitamente.
  El prompt del overnight debe reforzar "NO tocar V1-* hasta capa 5
  + 6 + POLISH completas".
- **Riesgo: performance mobile con 10 NPCs + 20 pickups** —
  Mitigación: MOB-3 profiler antes de export Android. ColorRects
  son baratos, pero el .wasm 35MB puede ser pesado para mobile.
- **Riesgo: sin save, el jugador pierde progreso al refrescar** —
  Mitigación: SAVE-1 con localStorage en HTML5 (no solo user://).
  GATE-2 lo valida.
- **Riesgo: contenido 1.0 (V1-1..6) es L y puede tardar muchas
  rondas** — Mitigación: post-MVP, hacer 1 negocio nuevo por ronda
  (M), no todos a la vez.
- **Riesgo: monetización real (IAP/ads) sin usuarios no genera
  revenue** — Mitigación: lanzar MVP free con ads recompensados
  placeholder primero, medir D1/D7, iterar balance, LUEGO agregar
  IAP.
- **Riesgo: el export HTML5 35MB wasm es pesado para mobile web** —
  Mitigación: considerar export Android nativo (APK) para mobile
  en vez de web. El HTML5 es para iteración rápida en desktop.

## Próximos pasos recomendados (esta semana)

1. **Correr 1 ciclo más de overnight (5 rondas)** con el ROADMAP
   re-priorizado: EMP-1 (r16) → JUICE-1+POLISH-1/2/3 (r17-r18) →
   EVT-1/2 (r19) → SAVE-1+RNK-1 (r20). Esto cierra el MVP adictivo.
2. **Smoke manual en navegador** después del ciclo: abrir
   `exports/html5/index.html`, jugar 5 min, verificar §25 los 4
   beats. Si no engancha, iterar POLISH-6 (balance).
3. **Fix del controller**: agregar `taskkill //F //IM devin.exe`
   al START de `overnight/session.ps1` (excepto el controller). Es
   la lección #1 de proceso no aplicada tras 6 rondas.
4. **Compartir el build HTML5** con 3-5 personas (amigos/familia)
   para feedback cualitativo del primer minuto. Medir: ¿entendieron
   qué hacer? ¿jugó más de 2 min? ¿qué los frustró?
5. **Decidir plataforma lanzamiento**: si el target es mobile,
   empezar setup Android export templates + Google Play Console
   en paralelo con el pulido (no bloquea, pero toma días).
6. **Setup telemetría básica**: MET-1 (consola) primero, luego
   Firebase/Supabase para D1/D7 retention. Sin data, no se puede
   iterar con criterio post-lanzamiento.

---

*Informe generado por fine-tuning ronda 15 (2026-07-05 08:53).
Honesto y crítico: el cimiento es sólido, el feel no. 5-7 rondas
más de pulido (juice + eventos + ranking + save + balance) para
"éxito desde el primer lanzamiento".*
