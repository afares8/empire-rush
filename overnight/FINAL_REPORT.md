# Trade Empire Rush — Informe Final del Overnight (rondas 6–10)

> Generado por la sesión de fine-tuning de la ronda 10
> (2026-07-05 07:52). Análisis honesto y crítico del estado real
> del MVP después de 10 rondas de overnight automatizado (5 rondas
> iniciales + 5 rondas post-primer-fine-tuning).

## Fase alcanzada

- **Fase al final de la ronda 10**: **A (construyendo MVP)** — capa 1
  + capa 1.5 (export) + capa 2 completas; capa 3 al 0% en git.
- **Justificación**: en git/main (HEAD = 26b7f48, merge de r8)
  existen 13 items completados: GODOT-1..3, EXP-1, LOOP-1..9. No hay
  `business.gd`, no hay `Business.tscn`, no hay 3 negocios. BIZ-1/2/3
  se implementaron 2 veces (r9, r10) pero el controller las destruyó
  ambas veces. Capas 4/5/6 al 0%. Fase B (pulido) al 0%.
- **¿Avanzó A → B → C correctamente?**: NO — se quedó en Fase A.
  Esto es correcto (no se saltó Fase B), pero el progreso dentro de
  Fase A es lento: en 5 rondas post-fine-tuning solo 4 items nuevos
  entraron a git (LOOP-7/8/9 + EXP-1, todos en r8).
- **¿Se saltó la Fase B (pulido)?**: NO — no se llegó a Fase B. Pero
  el loop actual NECESITA Fase B para ser adictivo (ver abajo).

## Estado del MVP

### Lo que se construyó (en git, verificado headless 2026-07-05 07:50)

- **Capa 1 — Engine + proyecto base**: Godot 4.3 portable,
  `project.godot` válido, autoloads `Economy`/`GameManager`, inputs
  mapeados, `Main.tscn` arranca sin crash.
- **Capa 1.5 — Gate export HTML5**: `export_presets.cfg` + templates
  instaladas. `--export-release "HTML5"` genera `exports/html5/
  index.html` (4.8KB) + index.js (331KB) + index.wasm (35MB) +
  index.pck (62KB) sin errores. **El MVP es jugable en navegador.**
- **Capa 2 — Loop base (9 items)**:
  - LOOP-1: Player CharacterBody2D con WASD, accel/friction, bob +
    squash/stretch placeholder.
  - LOOP-2: Cámara con smoothing exponencial + look-ahead.
  - LOOP-3: Pickup Area2D con stock regenerativo, carry capacity 3,
    indicador visual "xN".
  - LOOP-4: Shelf Area2D con stock/capacity, fill con E, API
    `take_item()`/`has_stock()`.
  - LOOP-5: Client FSM (to_shelf→browse→to_exit) + ClientSpawner
    cada 3s real-time, max 5 concurrentes.
  - LOOP-6: MoneyDrop Area2D con value, pop-in tween, Economy.
    add_cash al recoger.
  - LOOP-7: UnlockPad Area2D con zone_id, price, pulso amarillo,
    prompt "E", API `try_unlock()`, señal `unlocked()`.
  - LOOP-8: HUD CanvasLayer con CashLabel/EmpireLabel/MissionLabel,
    pop de scale al cambiar cash.
  - LOOP-9: MissionGuide con 4 beats (FILL_SHELF→COLLECT_MONEY→
    UNLOCK_ZONE→HIRE_HELP), avanza por señales, no bloquea input.

### Lo que NO se construyó

- **Capa 3 — Contenido MVP**: BIZ-1/2/3/4/5 todos pendientes. Los 3
  negocios (ropa/perfume/market) se implementaron 2 veces pero se
  perdieron por el reset destructivo del controller.
- **Capa 4 — Automatización**: AUTO-1/2, UPG-1..5, EMP-1 pendientes.
- **Capa 5 — Eventos + ranking + monetización + save + juice**: EVT-
  1/2/3, RNK-1, MON-1/2, SAVE-1, OFF-1, JUICE-1/2 pendientes.
- **Capa 6 — Landing + métricas**: EXP-2, MET-1 pendientes.
- **Fase B — Pulido**: POLISH-1..10 todos pendientes.
- **Fase C — Versión 1.0+**: V1-1..23 todos pendientes.

### Export HTML5

- **Estado**: OK
- **Ruta**: `D:\empire-rush\exports\html5\index.html`
- **Verificado**: 2026-07-05 07:50 (headless run OK, 2 pickups, 2
  shelves, ClientSpawner, HUD, MissionGuide, 2 pads cargan sin
  crashes).

### Cómo probarlo

```powershell
# Headless (valida boot sin crash)
D:\empire-rush\godot\godot.exe --headless --path D:\empire-rush --quit-after 60

# Smoke con estantes pre-llenos + pad unlock
$env:DEVIN_SMOKE=1
D:\empire-rush\godot\godot.exe --headless --path D:\empire-rush --quit-after 60

# Export HTML5 (regenera el bundle)
D:\empire-rush\godot\godot.exe --headless --path D:\empire-rush --export-release "HTML5" D:\empire-rush\exports\html5\index.html

# Abrir en navegador (smoke visual manual)
start D:\empire-rush\exports\html5\index.html

# Editor interactivo
D:\empire-rush\godot\godot.exe --path D:\empire-rush
```

## ¿Es adictivo desde el primer minuto? (honesto)

- **Loop se siente**: **PARCIAL** — la mecánica está conectada en
  código (recoger→estante→cliente→dinero→recoger→pad→desbloquear),
  hay HUD, hay mission guide, hay export. Pero le falta todo el
  "feel": juice, contenido, balance, validación visual en navegador.
- **Satisfacción táctil**: **MALA** — recoger dinero no tiene
  partículas, no tiene sonido, no tiene fly-to-HUD. El MoneyDrop
  solo tiene un pop-in tween. Sin audio. Esto viola la regla de oro
  del AGENTS.md ("satisfacción táctil: recoger dinero debe tener
  feedback visual + sonoro inmediato").
- **Progreso visible**: **PARCIAL** — el HUD muestra cash/EV en
  tiempo real con pop de scale, pero no hay progreso visual del
  negocio (no hay estantes más grandes, no hay más clientes
  visibles, no hay tienda más bonita). Solo 1 negocio placeholder.
- **Meta cercana siempre visible**: **PARCIAL** — hay 2 pads de
  desbloqueo con precio visible y pulso amarillo, pero no hay
  indicador de "próximo pad alcanzable" en el HUD (POLISH-5
  pendiente). El mission guide muestra el beat actual pero no la
  meta cercana cuantitativa.
- **Primer minuto (§25)**:
  - 0–10s "Llena tu primer estante": **PARCIAL** — el mission guide
    lo muestra, pero recoger producto y llenar estante requiere
    entender E en rango. Sin tutorial visual claro.
  - 10–20s "Recoge tu dinero": **PARCIAL** — el cliente suelta
    MoneyDrop, el mission guide lo dice, pero sin fly-to-HUD el
    jugador puede no conectar "recoger dinero" con "cash sube".
  - 20–35s "Invierte para crecer": **OK** — el pad de desbloqueo
    está visible con precio, el mission guide lo indica.
  - 35–60s "Contrata ayuda": **ROTO** — el 4to beat del mission
    guide es HIRE_HELP pero no hay empleados (capa 4 pendiente).
    El beat queda colgado. Debería cambiarse a "Desbloquea el
    segundo negocio" hasta que AUTO-1 exista.
- **Cómo se siente (§26)**:
  - ¿Rápido? PARCIAL — el player se mueve bien, pero sin contenido
    el mapa se siente vacío.
  - ¿Satisfactorio? NO — sin juice, recoger dinero es un evento
    silencioso.
  - ¿Cada 10s pasa algo? PARCIAL — los clientes spawnean cada 3s,
    pero sin feedback el "algo" no se siente.
  - ¿Cada 1min desbloquea algo? DEPENDE — el primer pad ($50) es
    alcanzable en ~1min si el jugador optimiza, pero sin balance
    no está claro.
- **Qué es adictivo (§32)**:
  - Progreso visual inmediato: NO (sin juice, sin crecimiento
    visual del negocio).
  - Metas cortas/medianas/largas: PARCIAL (pads = meta corta, EV
    = meta larga, pero no hay meta mediana clara).
  - Dinero visible: PARCIAL (hay MoneyDrop físico + HUD, pero sin
    fly-to-HUD ni sonido).
  - Desbloqueo constante: NO (solo 2 pads, después no hay nada).
  - Automatización progresiva: NO (capa 4 al 0%).
  - Competencia aspiracional: NO (sin ranking).
  - Eventos sorpresa: NO (sin eventos).
- **Qué cansa (§33)**:
  - Repetición excesiva: SÍ — con solo 1 negocio y sin eventos, el
    loop es monótono después de 2 min.
  - Progreso demasiado lento: RIESGO — sin balance, podría ser
    demasiado lento o demasiado rápido.
  - Todo se ve igual: SÍ — solo ColorRects placeholder, sin
    variedad visual entre negocios.
- **Veredicto**: **"Necesita 3–5 rondas más de pulido + contenido,
  CON el controller arreglado"**. El cimiento es sólido (código
  limpio, headless-safe, export verde) pero el MVP no es adictivo
  hoy. La brecha más grande es: (1) contenido (BIZ-1/2/3), (2) juice
  (JUICE-1/POLISH-1/2), (3) validación de feel en navegador. Y por
  encima de todo: (0) el controller debe dejar de destruir trabajo.

## Cómo puedo mejorar el MVP (recomendaciones accionables)

> Ordenadas por impacto/esfuerzo. Las primeras 3 son de proceso
> (sin ellas, el resto no se completa nunca).

1. **FIX-CONTROLLER: commitear WIP cada 10 min + done-marker desde
   el prompt + timeout 90 min + taskkill devin.exe al inicio + git
   reset al inicio de cada ronda** — Sin esto, cada ronda pierde el
   trabajo. Es el blocker #1. Esfuerzo: **S** (1 sesión manual de
   edición de session.ps1/run_overnight.ps1). Impacto: **CRÍTICO**
   (destraba todo lo demás).
2. **Re-hacer BIZ-1/2/3 (3 negocios) siguiendo la abstracción
   `Business` de r10** — Ya está diseñado y validado 2 veces. Con
   el controller arreglado, 1 iteración lo cierra. Impacto: alto
   (variedad visual + meta mediana). Esfuerzo: **S**.
3. **JUICE-1: partículas + sonido placeholder + fly-to-HUD al
   recoger dinero** — Es lo que más impacta la "satisfacción
   táctil" de la regla de oro. Sin esto, recoger dinero se siente
   vacío. Impacto: alto (adictivo). Esfuerzo: **S**.
4. **POLISH-2: tween de cash volando al HUD** — Refuerza "dinero
   visible" (§32.3). Impacto: medio-alto. Esfuerzo: **S**.
5. **POLISH-3: screen shake suave al desbloquear zona** — Hace que
   el desbloqueo se sienta impactante. Impacto: medio. Esfuerzo:
   **S**.
6. **POLISH-4: glow/pulso en pads de desbloqueo** — Ya existe pulso
   amarillo, pero un glow más rico llama más la atención. Impacto:
   medio. Esfuerzo: **S**.
7. **POLISH-5: indicador de "meta cercana" en el HUD** — "Próximo
   pad: $50 / faltan $20". Mantiene la meta siempre visible (§32.2).
   Impacto: medio-alto (retención). Esfuerzo: **S**.
8. **POLISH-6: balance de precios** — Ajustar para que el primer
   pad se alcance en ~1min, el segundo en ~3min, etc. Meta corta
   cada 1–2min. Impacto: alto (evita "progreso demasiado lento"
   §33.2). Esfuerzo: **S**.
9. **POLISH-7: spawn rate de clientes ajustado** — Caos controlado:
   ni vacío ni abrumador. Impacto: medio. Esfuerzo: **S**.
10. **BIZ-4: mini taller/fábrica** — Materia prima → máquina →
    producto → estante. Primera mecánica de producción (no solo
    recoger/vender). Impacto: alto (variedad, evita repetición
    §33.1). Esfuerzo: **M**.
11. **BIZ-5: mini almacén** — Conecta fábrica con estantes.
    Impacto: medio. Esfuerzo: **S**.
12. **AUTO-1: empleado cajero** — Cobra automáticamente. Primera
    automatización (§32.5). Impacto: alto (transición "yo trabajo
    → mi imperio trabaja"). Esfuerzo: **M**.
13. **SAVE-1: guardado local** — Sin save, el jugador pierde todo
    al cerrar. Impacto: alto (retención día 1). Esfuerzo: **S**.
14. **Fix del 4to beat del MissionGuide** — Cambiar HIRE_HELP a
    "Desbloquea el segundo negocio" hasta que AUTO-1 exista. Sin
    esto, el primer minuto queda colgado. Impacto: medio. Esfuerzo:
    **S**.
15. **Smoke en navegador manual** — Abrir `index.html`, jugar 60s,
    validar §25. Hoy nadie lo ha hecho. Impacto: alto (validación
    real). Esfuerzo: **S** (humano, no AI).

## Qué más puedo hacer (roadmap a versión 1.0 y más allá)

### Versión 1.0 (post-MVP) — Fase C

- **V1-1 a V1-23** del ROADMAP (ya listados): farmacia, electrónica,
  fábrica avanzada, bodega + camiones, puerto, segunda ciudad,
  ligas semanales, estatus/títulos, personalización, empleados
  premium, skins, pase de temporada, cofres transparentes, IAP
  real, ads reales, daily login, eventos globales, logros, fatiga
  + reenganche, perfil público, export Android/iOS, cloud save.
- **Prioridad recomendada post-MVP**: SAVE-1 (retención) → AUTO-1/2
  (automatización) → RNK-1 (competencia aspiracional) → EVT-1/2
  (eventos sorpresa) → MON-1 (ads recompensados placeholder) →
  V1-21 (Android) → V1-14 (IAP real) → V1-22 (iOS).

### Versión 2.0

- Farmacia (negocio nuevo).
- Electrónica (negocio nuevo).
- Fábrica avanzada + puerto + contenedores.
- Segunda ciudad + logística inter-ciudad.
- Clanes/conglomerados + visitar imperios.
- Eventos globales + empleados raros + skins premium.
- IA para eventos diarios (§18).

### Versión 3.0

- Países (Dubai, Tokio, Miami, París, Panamá, Estambul, etc.).
- Mall / centro comercial (comprar locales, rentar).
- Bienes raíces + franquicias.
- Ranking mundial avanzado + ligas + temporadas por país.
- Conglomerados + colaboración entre jugadores.
- Personalización avanzada de marca.

### Lanzamiento mobile (Android/iOS)

1. **Export presets**:
   - Android: instalar Android Build System en Godot, configurar
     `keystore` (debug + release), `export_presets.cfg` con
     package name `com.tuempresa.empirerush`, min SDK 24, target
     SDK 34. `--export-release "Android" empire-rush.apk` (o .aab
     para Play Store).
   - iOS: macOS requerido para export. Configurar bundle ID,
     provisioning profile, certificados. `--export-release "iOS"
     empire-rush.ipa`. Sin macOS, usar CI (GitHub Actions con
     macos-latest).
2. **Google Play Console** ($25 USD una vez):
   - Crear app, llenar ficha (descripción, screenshots, icono).
   - Subir .aab a internal testing → closed testing → open testing
     → production.
   - Política de datos (data safety), política de contenido
     (aptó para todos), EULA.
   - Configurar IAP con Google Play Billing (V1-14).
   - Configurar AdMob para ads recompensados (V1-15).
3. **App Store Connect** ($99 USD/año, requiere Mac):
   - Crear app, llenar ficha, screenshots por dispositivo.
   - Subir .ipa via Transporter o Xcode.
   - TestFlight (beta) → review → production.
   - Configurar IAP con StoreKit (V1-14).
   - Configurar ads via AdMob o SKAdNetwork.
4. **Ranking + login**:
   - Google Play Games Services (Android) / Game Center (iOS) para
     ranking nativo + login sin fricción.
   - O backend propio (Supabase/Firebase) para ranking cross-plataforma
     + cloud save (V1-23).
5. **Cloud save**: Supabase/Firebase, sync de `save.json` por user
   ID. Conflict resolution: last-write-wins o merge por timestamps.
6. **Comunidad**: Discord, Reddit, formulario de feedback in-app.
   Mensajes predefinidos (§17) para social sin riesgo.

## Métricas a medir desde el día 1

> BLUEPRINT §23. Implementar como telemetría local (MET-1) primero,
> luego analytics service (Firebase/Amplitude) en mobile.

- **Tutorial completion**: % de jugadores que completan el primer
  minuto (MissionGuide DONE). Meta: >80%. Implementación: flag en
  save.json + log al completar.
- **Tiempo de primera sesión**: segundos desde boot hasta primer
  quit. Meta: >480s (8min). Implementación: timestamp boot + quit
  en save.json.
- **Sesiones por día**: contador por día calendario. Implementación:
  array de fechas en save.json.
- **Retención día 1/3/7**: % de jugadores que vuelven N días después
  del primer boot. Implementación: comparar fecha primer boot vs
  fecha sesiones posteriores.
- **Ads vistos por usuario activo al día**: contador de MON-1
  boosts activados. Meta: ≥3. Implementación: log al activar boost.
- **Compras por usuario**: contador de IAP (V1-14). Implementación:
  log al completar compra.
- **Nivel donde abandonan**: zona/negocio máximo desbloqueado al
  último boot. Implementación: max(zone_unlocked) en save.json.
- **Zonas más desbloqueadas**: ranking de zone_id por frecuencia.
  Implementación: log al unlock.
- **Eventos más jugados**: ranking de event_id por frecuencia.
  Implementación: log al completar evento.
- **Empleados más usados**: ranking de employee_id por tiempo
  activo. Implementación: log al contratar + al despedir.

## Riesgos y mitigaciones

- **Riesgo #1 — El controller destruye trabajo (CRÍTICO)**: 5
  rondas perdidas acumuladas. Mitigación: aplicar FIX-CONTROLLER
  antes de cualquier otra ronda. Sin esto, el overnight nunca
  converge.
- **Riesgo #2 — El loop no engancha en navegador**: todo el smoke
  es headless, nadie validó el feel real. Mitigación: smoke
  manual en navegador después de cada item de capa 3/Fase B.
- **Riesgo #3 — Sin contenido, el loop es monótono**: solo 1
  negocio placeholder. Mitigación: cerrar BIZ-1/2/3 antes de tocar
  juice o capa 4.
- **Riesgo #4 — Sin juice, la satisfacción táctil no existe**:
  recoger dinero es silencioso. Mitigación: JUICE-1 + POLISH-2
  son prioritarios después de BIZ-1/2/3.
- **Riesgo #5 — Sin save, retención = 0**: el jugador pierde todo
  al cerrar. Mitigación: SAVE-1 antes de lanzar a usuarios reales.
- **Riesgo #6 — El 4to beat del MissionGuide está roto**: HIRE_HELP
  sin empleados. Mitigación: cambiar a "Desbloquea el segundo
  negocio" o implementar AUTO-1 primero.
- **Riesgo #7 — Devin huérfano concurrente**: 3 devin.exe vivos
  sobrescribiendo archivos. Mitigación: `taskkill //F //IM
  devin.exe` al inicio de cada ronda.
- **Riesgo #8 — Sin balance, el progreso se siente mal**: precios
  sin tuning. Mitigación: POLISH-6 con playtest en navegador.

## Próximos pasos recomendados (esta semana)

1. **Aplicar FIX-CONTROLLER** (manual, 1 sesión): editar
   `overnight/session.ps1` y `overnight/run_overnight.ps1` para:
   - `git add -A && git commit -m "WIP ronda N iter M"` cada 10 min
     de trabajo (no solo al final).
   - Done-marker escrito desde el prompt del devin (instrucción
     explícita "al terminar, escribe $DEVIN_DONE_MARKER").
   - Timeout subido a 90 min.
   - `taskkill //F //IM devin.exe` al inicio de cada ronda.
   - `git reset --hard HEAD && git clean -fd` al inicio de cada
     ronda (después de commitear WIP de la anterior).
   Commitear este fix como `fix(controller): preserve work across
   timeouts`.
2. **Correr 1 overnight de 5 rondas con el controller arreglado**:
   objetivo = BIZ-1/2/3 + JUICE-1 + POLISH-2/3/5/6 (7 items). Con
   el controller arreglado, 5 rondas × 1-2 iter = 5-10 iter
   deberían cerrar todo esto.
3. **Smoke manual en navegador**: abrir `exports/html5/index.html`,
  jugar 60s, validar §25 (primer minuto). Anotar qué se siente mal.
4. **Decidir: ¿pulir más (Fase B) o lanzar MVP soft?**: después del
  overnight de paso 2, evaluar si el loop engancha. Si sí, lanzar
  soft (compartir index.html con 5 amigos, medir tiempo de sesión).
  Si no, otra ronda de pulido (POLISH-7/8/9/10 + balance).
5. **Implementar SAVE-1 + MET-1** antes de cualquier lanzamiento
  con usuarios reales (sin save, no hay retención; sin métricas,
  no hay aprendizaje).
